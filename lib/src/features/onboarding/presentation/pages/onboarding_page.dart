import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/nickname_step.dart';
import '../widgets/personal_info_step.dart';
import '../widgets/interests_step.dart';
import '../widgets/consent_step.dart';
import '../widgets/privacy_preferences_step.dart';
import '../../../profile/domain/models/user_profile.dart';
import '../../../profile/data/repositories/user_repository.dart';
import '../../../profile/presentation/providers/user_profile_provider.dart';
import '../../../auth/data/auth_service.dart';
import '../../../../core/analytics/analytics_provider.dart';
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
  String? _schoolYear;
  List<String> _interests = [];
  List<String> _clubs = [];
  bool? _isMinor;
  String? _guardianContact;
  bool _parentalConsentGiven = false;
  bool _privacyConsentGiven = false;
  bool _allowAnonymousPosts = true;
  bool _profileVisible = true;
  bool _analyticsEnabled = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analyticsServiceProvider).logOnboardingStarted();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 4) {
      final stepNames = ['nickname', 'personal_info', 'consent', 'privacy'];
      ref.read(analyticsServiceProvider).logOnboardingStepCompleted(
        stepNumber: _currentStep + 1,
        stepName: stepNames[_currentStep],
      );
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

      print('✅ ONBOARDING: Starting completion for uid=${user.uid}');

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

      if (_schoolYear == null || _schoolYear!.trim().isEmpty) {
        _showError('Please select your school year');
        setState(() => _isSubmitting = false);
        return;
      }

      if (_interests.isEmpty) {
        _showError('Please select at least one interest');
        setState(() => _isSubmitting = false);
        return;
      }

      final trimmedNickname = _nickname.trim();
      final interests = List<String>.from(_interests);
      final clubs = List<String>.from(_clubs);
      final now = DateTime.now();
      final profile = UserProfile(
        uid: user.uid,
        nickname: trimmedNickname,
        nicknameVerified: true,
        gender: _gender,
        school: _school,
        schoolYear: _schoolYear,
        interests: interests,
        clubs: clubs,
        searchKeywords: UserProfile.buildSearchKeywords(
          trimmedNickname,
          _school,
          _schoolYear,
          interests,
          clubs,
          _gender,
        ),
        anonymousPostsCount: 0,
        createdAt: now,
        privacyConsentGiven: _privacyConsentGiven,
        privacyConsentTimestamp: now,
        isMinor: _isMinor,
        guardianContact: _guardianContact,
        parentalConsentGiven: _isMinor == true ? _parentalConsentGiven : null,
        parentalConsentTimestamp:
            _isMinor == true && _parentalConsentGiven ? now : null,
        onboardingComplete: true,
        allowAnonymousPosts: _allowAnonymousPosts,
        profileVisible: _profileVisible,
        analyticsEnabled: _analyticsEnabled,
      );

      print('✅ ONBOARDING: Creating profile with data:');
      print('   - uid: ${profile.uid}');
      print('   - nickname: ${profile.nickname}');
      print('   - school: ${profile.school}');
      print('   - schoolYear: ${profile.schoolYear}');
      print('   - interests: ${profile.interests}');
      print('   - onboardingComplete: ${profile.onboardingComplete}');

      await ref.read(userRepositoryProvider).createUserProfile(profile);
      print('✅ ONBOARDING: Profile created successfully in Firestore');

      final analyticsService = ref.read(analyticsServiceProvider);
      await analyticsService.setUserProperties(
        school: _school,
        isMinor: _isMinor ?? false,
        hasParentalConsent: _parentalConsentGiven,
      );
      await analyticsService.logOnboardingCompleted(
        school: _school ?? 'unknown',
        isMinor: _isMinor ?? false,
      );

      if (!_analyticsEnabled) {
        await analyticsService.setEnabled(false);
      }

      // FIX: Prevent onboarding loop by ensuring the profile stream has the updated data
      // before navigation. This fixes a race condition where:
      // 1. Profile is written to Firestore
      // 2. Navigation happens immediately
      // 3. Router checks profile stream which hasn't received the update yet
      // 4. Router sees onboardingComplete=false and redirects back to onboarding
      print('✅ ONBOARDING: Invalidating user profile provider to force refresh');
      ref.invalidate(userProfileProvider);

      print('✅ ONBOARDING: Waiting for profile stream to emit updated data');
      bool profileConfirmed = false;
      try {
        // Wait for the stream to emit the updated profile with onboardingComplete=true
        final refreshedProfile = await ref.read(userProfileProvider.future).timeout(
          const Duration(seconds: 5),
        );
        
        if (refreshedProfile != null && refreshedProfile.onboardingComplete) {
          print('✅ ONBOARDING: Profile confirmed with onboardingComplete=true');
          profileConfirmed = true;
        } else {
          print('⚠️ ONBOARDING: Profile not confirmed: profile=${refreshedProfile != null}, onboardingComplete=${refreshedProfile?.onboardingComplete}');
        }
      } catch (e) {
        print('⚠️ ONBOARDING: Timeout waiting for profile refresh: $e');
      }

      if (!profileConfirmed) {
        print('⚠️ ONBOARDING: Profile not confirmed but proceeding anyway (timeout or error)');
      }

      print('✅ ONBOARDING: Navigating to /feed');
      if (mounted) {
        context.go('/feed');
      }
    } catch (e) {
      print('❌ ONBOARDING ERROR: ${e.toString()}');
      print('   Stack trace: ${StackTrace.current}');
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
            value: (_currentStep + 1) / 5,
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
                InterestsStep(
                  initialSchoolYear: _schoolYear,
                  initialInterests: _interests,
                  initialClubs: _clubs,
                  onSchoolYearChanged: (schoolYear) =>
                      setState(() => _schoolYear = schoolYear),
                  onInterestsChanged: (interests) =>
                      setState(() => _interests = interests),
                  onClubsChanged: (clubs) => setState(() => _clubs = clubs),
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
                  analyticsEnabled: _analyticsEnabled,
                  onAllowAnonymousPostsChanged: (value) =>
                      setState(() => _allowAnonymousPosts = value),
                  onProfileVisibleChanged: (value) =>
                      setState(() => _profileVisible = value),
                  onAnalyticsEnabledChanged: (value) =>
                      setState(() => _analyticsEnabled = value),
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
