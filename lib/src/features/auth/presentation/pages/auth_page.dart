import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teen_talk_app/src/core/localization/app_localizations.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: Text(_tabController.index == 0 ? (widget.isSignUp ? localizations?.authSignUp ?? 'Sign Up' : localizations?.authSignIn ?? 'Sign In') : ''),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(
                height: 50,
                child: TabBar(
                  controller: _tabController,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                  tabs: [
                    Tab(text: localizations?.authEmail ?? 'Email'),
                    Tab(text: localizations?.authPhoneNumber ?? 'Phone'),
                    Tab(text: 'Social'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: MediaQuery.of(context).size.height - 220,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    EmailAuthForm(isSignUp: widget.isSignUp),
                    PhoneAuthForm(),
                    SocialAuthButtons(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
