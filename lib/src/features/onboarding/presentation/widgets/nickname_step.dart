import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../profile/data/repositories/user_repository.dart';
import 'dart:async';

class NicknameStep extends ConsumerStatefulWidget {
  final String initialNickname;
  final Function(String) onNicknameChanged;
  final VoidCallback onNext;

  const NicknameStep({
    super.key,
    required this.initialNickname,
    required this.onNicknameChanged,
    required this.onNext,
  });

  @override
  ConsumerState<NicknameStep> createState() => _NicknameStepState();
}

class _NicknameStepState extends ConsumerState<NicknameStep> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  Timer? _debounce;
  bool _isChecking = false;
  bool? _isAvailable;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nicknameController.text = widget.initialNickname;
    _nicknameController.addListener(_onNicknameChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _nicknameController.dispose();
    super.dispose();
  }

  void _onNicknameChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    final nickname = _nicknameController.text.trim();
    if (nickname.isEmpty || nickname.length < 3) {
      setState(() {
        _isAvailable = null;
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _isChecking = true;
      _isAvailable = null;
      _errorMessage = null;
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
          _isAvailable = isAvailable;
          _isChecking = false;
          _errorMessage = isAvailable ? null : 'Nickname already taken';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isChecking = false;
          _errorMessage = 'Error checking nickname';
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

    if (_errorMessage != null) {
      return _errorMessage;
    }

    return null;
  }

  void _handleNext() {
    if (_formKey.currentState!.validate() && _isAvailable == true) {
      widget.onNicknameChanged(_nicknameController.text.trim());
      widget.onNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Onboarding step: Choose your nickname. This is how other users will see you.',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              ExcludeSemantics(
                child: Icon(
                  Icons.person_outline,
                  size: 80,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 24),
              Flexible(
                child: Text(
                  'Choose Your Nickname',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Text(
                  'This is how other users will see you',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _nicknameController,
                decoration: InputDecoration(
                  labelText: 'Nickname',
                  hintText: 'Enter a unique nickname',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.account_circle),
                  suffixIcon: _isChecking
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : _isAvailable == true
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : _isAvailable == false
                              ? const Icon(Icons.error, color: Colors.red)
                              : null,
                ),
                validator: _validateNickname,
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              const SizedBox(height: 16),
              Card(
                color: Colors.blue.shade50,
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, size: 20, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            'Nickname Guidelines',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text('• 3-20 characters long'),
                      Text('• Only letters, numbers, and underscores'),
                      Text('• Must be unique'),
                      Text('• Can be changed once per month'),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: (_isAvailable == true && !_isChecking)
                    ? _handleNext
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Next'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
