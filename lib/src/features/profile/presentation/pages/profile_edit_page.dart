import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models/user_profile.dart';
import '../../data/repositories/user_repository.dart';
import '../providers/user_profile_provider.dart';
import '../../../../core/constants/brescia_schools.dart';
import 'dart:async';

class ProfileEditPage extends ConsumerStatefulWidget {
  const ProfileEditPage({super.key});

  @override
  ConsumerState<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends ConsumerState<ProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  Timer? _debounce;
  
  String? _gender;
  String? _school;
  bool _allowAnonymousPosts = true;
  bool _profileVisible = true;
  bool _isSubmitting = false;
  bool _isCheckingNickname = false;
  bool? _isNicknameAvailable;
  String? _nicknameError;
  bool _canChangeNickname = true;
  int _daysUntilChange = 0;
  String? _originalNickname;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final profileAsync = ref.read(userProfileProvider);
    profileAsync.whenData((profile) async {
      if (profile != null && mounted) {
        setState(() {
          _originalNickname = profile.nickname;
          _nicknameController.text = profile.nickname;
          _gender = profile.gender;
          _school = profile.school;
          _allowAnonymousPosts = profile.allowAnonymousPosts;
          _profileVisible = profile.profileVisible;
        });

        final canChange =
            await ref.read(userRepositoryProvider).canChangeNickname(profile.uid);
        final daysUntil =
            await ref.read(userRepositoryProvider).getDaysUntilNicknameChange(profile.uid);

        if (mounted) {
          setState(() {
            _canChangeNickname = canChange;
            _daysUntilChange = daysUntil;
          });
        }
      }
    });
  }

  void _onNicknameChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    final nickname = value.trim();
    if (nickname == _originalNickname) {
      setState(() {
        _isNicknameAvailable = true;
        _nicknameError = null;
      });
      return;
    }

    if (nickname.isEmpty || nickname.length < 3) {
      setState(() {
        _isNicknameAvailable = null;
        _nicknameError = null;
      });
      return;
    }

    setState(() {
      _isCheckingNickname = true;
      _isNicknameAvailable = null;
      _nicknameError = null;
    });

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      await _checkNicknameAvailability(nickname);
    });
  }

  Future<void> _checkNicknameAvailability(String nickname) async {
    try {
      final isAvailable =
          await ref.read(userRepositoryProvider).isNicknameAvailable(nickname);

      if (mounted) {
        setState(() {
          _isNicknameAvailable = isAvailable;
          _isCheckingNickname = false;
          _nicknameError = isAvailable ? null : 'Nickname already taken';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCheckingNickname = false;
          _nicknameError = 'Error checking nickname';
        });
      }
    }
  }

  String? _validateNickname(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a nickname';
    }

    final nickname = value.trim();
    if (nickname.length < 3) {
      return 'Nickname must be at least 3 characters';
    }

    if (nickname.length > 20) {
      return 'Nickname must be at most 20 characters';
    }

    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(nickname)) {
      return 'Only letters, numbers, and underscores allowed';
    }

    if (_nicknameError != null && nickname != _originalNickname) {
      return _nicknameError;
    }

    return null;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSubmitting) return;

    final profileAsync = ref.read(userProfileProvider);
    final profile = profileAsync.value;
    if (profile == null) return;

    setState(() => _isSubmitting = true);

    try {
      final updates = <String, dynamic>{
        'gender': _gender,
        'school': _school,
        'allowAnonymousPosts': _allowAnonymousPosts,
        'profileVisible': _profileVisible,
      };

      final newNickname = _nicknameController.text.trim();
      if (newNickname != _originalNickname) {
        if (!_canChangeNickname) {
          _showError(
            'You can only change your nickname once every 30 days. '
            'Please wait $_daysUntilChange more days.',
          );
          setState(() => _isSubmitting = false);
          return;
        }

        if (_isNicknameAvailable != true) {
          _showError('Please choose an available nickname');
          setState(() => _isSubmitting = false);
          return;
        }

        updates['nickname'] = newNickname;
      }

      final success =
          await ref.read(userRepositoryProvider).updateUserProfile(profile.uid, updates);

      if (!success && newNickname != _originalNickname) {
        _showError('Nickname is no longer available');
        setState(() => _isSubmitting = false);
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Profile updated successfully'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        context.pop();
      }
    } catch (e) {
      _showError('Failed to update profile: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        elevation: 0,
        actions: [
          if (!_isSubmitting)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: FilledButton.icon(
                onPressed: _saveProfile,
                icon: const Icon(Icons.save, size: 18),
                label: const Text('Save'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
          if (_isSubmitting)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, 
                    size: 64, 
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Profile not found',
                    style: theme.textTheme.titleLarge,
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.account_circle, 
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Basic Information',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _nicknameController,
                            decoration: InputDecoration(
                              labelText: 'Nickname',
                              hintText: 'Enter your display name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.person),
                              suffixIcon: _isCheckingNickname
                                  ? const Padding(
                                      padding: EdgeInsets.all(12.0),
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                    )
                                  : _isNicknameAvailable == true &&
                                          _nicknameController.text.trim() != _originalNickname
                                      ? Icon(Icons.check_circle, color: Colors.green[600])
                                      : _isNicknameAvailable == false
                                          ? const Icon(Icons.error, color: Colors.red)
                                          : null,
                            ),
                            enabled: _canChangeNickname,
                            validator: _validateNickname,
                            onChanged: _onNicknameChanged,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                          ),
                          if (!_canChangeNickname)
                            Padding(
                              padding: const EdgeInsets.only(top: 12.0),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.orange.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.lock_clock, 
                                      color: Colors.orange[700],
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'You can change your nickname again in $_daysUntilChange days',
                                        style: TextStyle(
                                          color: Colors.orange[900],
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _gender,
                            decoration: InputDecoration(
                              labelText: 'Gender (Optional)',
                              hintText: 'Select your gender',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.person_outline),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'male', child: Text('Male')),
                              DropdownMenuItem(value: 'female', child: Text('Female')),
                              DropdownMenuItem(
                                  value: 'non_binary', child: Text('Non-binary')),
                              DropdownMenuItem(
                                  value: 'prefer_not_to_say',
                                  child: Text('Prefer not to say')),
                            ],
                            onChanged: (value) {
                              setState(() => _gender = value);
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _school,
                            decoration: InputDecoration(
                              labelText: 'School (Optional)',
                              hintText: 'Select your school',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.school),
                            ),
                            items: BresciaSchools.schools.map((school) {
                              return DropdownMenuItem(
                                value: school,
                                child: Text(school),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _school = value);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.security, 
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Privacy Settings',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: SwitchListTile(
                              value: _allowAnonymousPosts,
                              onChanged: (value) {
                                setState(() => _allowAnonymousPosts = value);
                              },
                              title: const Text(
                                'Allow Anonymous Posts',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              subtitle: const Text(
                                'Create posts without revealing your nickname',
                                style: TextStyle(fontSize: 12),
                              ),
                              secondary: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.visibility_off,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondaryContainer.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: SwitchListTile(
                              value: _profileVisible,
                              onChanged: (value) {
                                setState(() => _profileVisible = value);
                              },
                              title: const Text(
                                'Profile Visible',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              subtitle: const Text(
                                'Other users can view your profile',
                                style: TextStyle(fontSize: 12),
                              ),
                              secondary: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.secondary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.person,
                                  color: theme.colorScheme.secondary,
                                ),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error', style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
