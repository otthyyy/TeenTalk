import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teen_talk_app/src/core/localization/app_localizations.dart';
import 'package:teen_talk_app/src/core/theme/design_tokens.dart';
import 'package:teen_talk_app/src/core/theme/decorations.dart';
import 'package:teen_talk_app/src/core/theme/teen_talk_scaffold.dart';
import '../widgets/email_auth_form.dart';
import '../widgets/phone_auth_form.dart';
import '../widgets/social_auth_buttons.dart';

class AuthPage extends ConsumerStatefulWidget {
  final bool isSignUp;

  const AuthPage({
    super.key,
    this.isSignUp = false,
  });

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.isSignUp ? 0 : 0,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final tabLabels = [
      localizations?.authEmail ?? 'Email',
      localizations?.authPhoneNumber ?? 'Phone',
      'Social',
    ];

    return TeenTalkScaffold(
      appBar: AppBar(
        title: Text(
          _tabController.index == 0
              ? (widget.isSignUp
                  ? localizations?.authSignUp ?? 'Sign Up'
                  : localizations?.authSignIn ?? 'Sign In')
              : localizations?.appName ?? 'TeenTalk',
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingLg).copyWith(
          top: DesignTokens.spacingLg,
          bottom: DesignTokens.spacing2xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DecoratedBox(
              decoration: AppDecorations.glass(
                isDark: theme.brightness == Brightness.dark,
                borderRadius: DesignTokens.radiusXl,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spacing,
                  vertical: DesignTokens.spacingSm,
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    gradient: DesignTokens.primaryGradient,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorPadding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.spacingXs,
                    vertical: DesignTokens.spacing2xs,
                  ),
                  labelStyle: theme.textTheme.titleSmall?.copyWith(
                    color: DesignTokens.lightOnPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: theme.textTheme.titleSmall,
                  labelColor: DesignTokens.lightOnPrimary,
                  unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.7),
                  tabs: tabLabels
                      .map(
                        (label) => Tab(child: Text(label, textAlign: TextAlign.center)),
                      )
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: DesignTokens.spacingXl),
            SizedBox(
              height: MediaQuery.of(context).size.height - 240,
              child: TabBarView(
                controller: _tabController,
                children: [
                  EmailAuthForm(isSignUp: widget.isSignUp),
                  const PhoneAuthForm(),
                  const SocialAuthButtons(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
