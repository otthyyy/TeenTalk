import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/nickname_step.dart';
import '../widgets/personal_info_step.dart';
import '../widgets/consent_step.dart';
import '../widgets/privacy_preferences_step.dart';
import '../../../profile/domain/models/user_profile.dart';
import '../../../profile/data/repositories/user_repository.dart';
import '../../../auth/data/auth_service.dart';
import 'package:go_router/go_router.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  String _nickname = '';
  String? _gender;
  String? _school;
  bool? _isMinor;
  String? _guardianContact;
  bool _parentalConsentGiven = false;
  bool _privacyConsentGiven = false;
  bool _allowAnonymousPosts = true;
  bool _profileVisible = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final user = ref.read(authServiceProvider).currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      if (_isMinor == true && !_parentalConsentGiven) {
        _showError('Parental consent is required for minors');
        setState(() => _isSubmitting = false);
        return;
      }

      if (!_privacyConsentGiven) {
        _showError('Privacy consent is required');
        setState(() => _isSubmitting = false);
        return;
      }

      final now = DateTime.now();
      final profile = UserProfile(
        uid: user.uid,
        nickname: _nickname,
        nicknameVerified: true,
        gender: _gender,
        school: _school,
        anonymousPostsCount: 0,
        createdAt: now,
        privacyConsentGiven: _privacyConsentGiven,
        privacyConsentTimestamp: now,
        isMinor: _isMinor,
        guardianContact: _guardianContact,
        parentalConsentGiven: _isMinor == true ? _parentalConsentGiven : null,
        parentalConsentTimestamp:
            _isMinor == true && _parentalConsentGiven ? now : null,
        allowAnonymousPosts: _allowAnonymousPosts,
        profileVisible: _profileVisible,
      );

      await ref.read(userRepositoryProvider).createUserProfile(profile);

      if (mounted) {
        context.go('/feed');
      }
    } catch (e) {
      _showError('Failed to complete onboarding: ${e.toString()}');
      setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to TeenTalk'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentStep + 1) / 4,
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                NicknameStep(
                  initialNickname: _nickname,
                  onNicknameChanged: (nickname) => _nickname = nickname,
                  onNext: _nextStep,
                ),
                PersonalInfoStep(
                  initialGender: _gender,
                  initialSchool: _school,
                  onGenderChanged: (gender) => setState(() => _gender = gender),
                  onSchoolChanged: (school) => setState(() => _school = school),
                  onNext: _nextStep,
                  onBack: _previousStep,
                ),
                ConsentStep(
                  isMinor: _isMinor,
                  guardianContact: _guardianContact,
                  parentalConsentGiven: _parentalConsentGiven,
                  privacyConsentGiven: _privacyConsentGiven,
                  onIsMinorChanged: (value) => setState(() => _isMinor = value),
                  onGuardianContactChanged: (value) =>
                      setState(() => _guardianContact = value),
                  onParentalConsentChanged: (value) =>
                      setState(() => _parentalConsentGiven = value),
                  onPrivacyConsentChanged: (value) =>
                      setState(() => _privacyConsentGiven = value),
                  onNext: _nextStep,
                  onBack: _previousStep,
                ),
                PrivacyPreferencesStep(
                  allowAnonymousPosts: _allowAnonymousPosts,
                  profileVisible: _profileVisible,
                  onAllowAnonymousPostsChanged: (value) =>
                      setState(() => _allowAnonymousPosts = value),
                  onProfileVisibleChanged: (value) =>
                      setState(() => _profileVisible = value),
                  onComplete: _completeOnboarding,
                  onBack: _previousStep,
                  isSubmitting: _isSubmitting,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
