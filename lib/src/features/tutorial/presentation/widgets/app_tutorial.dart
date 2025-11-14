import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class TutorialTargets {

  TutorialTargets({
    required this.feedKey,
    required this.createPostKey,
    required this.searchKey,
    required this.messagesNavKey,
    required this.profileNavKey,
    this.safetyKey,
  });
  final GlobalKey feedKey;
  final GlobalKey createPostKey;
  final GlobalKey searchKey;
  final GlobalKey messagesNavKey;
  final GlobalKey profileNavKey;
  final GlobalKey? safetyKey;
}

class AppTutorial {

  AppTutorial({
    required this.context,
    required this.targets,
    required this.onFinish,
    required this.onSkip,
  });
  final BuildContext context;
  final TutorialTargets targets;
  final VoidCallback onFinish;
  final VoidCallback onSkip;

  List<TargetFocus> _createTargets() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return [
      // Step 1: Feed swipe/interaction
      TargetFocus(
        identify: 'feed',
        keyTarget: targets.feedKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _buildContent(
                title: 'Feed Spotted',
                description: 'Scorri per vedere i post condivisi dalla tua scuola. '
                    'Tocca i cuori per mettere mi piace o i commenti per rispondere!',
                icon: Icons.home,
                theme: theme,
                isDark: isDark,
              );
            },
          ),
        ],
      ),

      // Step 2: Create post
      TargetFocus(
        identify: 'create_post',
        keyTarget: targets.createPostKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildContent(
                title: 'Crea un Post',
                description: 'Tocca qui per condividere qualcosa che hai notato! '
                    'Puoi scegliere di postare in modo anonimo per proteggere la tua privacy.',
                icon: Icons.add_circle,
                theme: theme,
                isDark: isDark,
              );
            },
          ),
        ],
      ),

      // Step 3: Search
      TargetFocus(
        identify: 'search',
        keyTarget: targets.searchKey,
        alignSkip: Alignment.bottomLeft,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _buildContent(
                title: 'Cerca nel Feed',
                description: 'Usa la lente per trovare post, parole chiave o argomenti che ti interessano.',
                icon: Icons.search,
                theme: theme,
                isDark: isDark,
              );
            },
          ),
        ],
      ),

      // Step 4: Messages
      TargetFocus(
        identify: 'messages',
        keyTarget: targets.messagesNavKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildContent(
                title: 'Messaggi',
                description: 'Chatta privatamente con altri utenti in modo sicuro. '
                    'I tuoi messaggi sono protetti e privati.',
                icon: Icons.message,
                theme: theme,
                isDark: isDark,
              );
            },
          ),
        ],
      ),

      // Step 5: Profile
      TargetFocus(
        identify: 'profile',
        keyTarget: targets.profileNavKey,
        alignSkip: Alignment.topLeft,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildContent(
                title: 'Profilo',
                description: 'Gestisci il tuo profilo, le impostazioni sulla privacy '
                    'e visualizza la tua attività. Puoi anche riavviare questo tutorial da qui.',
                icon: Icons.person,
                theme: theme,
                isDark: isDark,
              );
            },
          ),
        ],
      ),

      // Step 6: Safety/reporting (if available)
      if (targets.safetyKey != null)
        TargetFocus(
          identify: 'safety',
          keyTarget: targets.safetyKey!,
          alignSkip: Alignment.topLeft,
          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              builder: (context, controller) {
                return _buildContent(
                  title: 'Sicurezza',
                  description: 'Se vedi contenuti inappropriati, puoi segnalarli usando il menu. '
                      'La tua sicurezza è la nostra priorità!',
                  icon: Icons.shield,
                  theme: theme,
                  isDark: isDark,
                );
              },
            ),
          ],
        ),
    ];
  }

  Widget _buildContent({
    required String title,
    required String description,
    required IconData icon,
    required ThemeData theme,
    required bool isDark,
  }) {
    return Semantics(
      label: '$title. $description',
      container: true,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? theme.colorScheme.surface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 28,
                    semanticLabel: title,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.5,
                color: isDark 
                    ? Colors.white.withOpacity(0.9) 
                    : theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void show() {
    final tutorial = TutorialCoachMark(
      targets: _createTargets(),
      colorShadow: Colors.black87,
      paddingFocus: 10,
      opacityShadow: 0.8,
      textSkip: 'SALTA',
      skipWidget: Semantics(
        button: true,
        label: 'Salta tutorial',
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'SALTA',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ),
      onFinish: onFinish,
      onSkip: () {
        onSkip();
        return true;
      },
      onClickTarget: (target) {},
      onClickTargetWithTapPosition: (target, tapDetails) {},
      onClickOverlay: (target) {},
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      tutorial.show(context: context);
    });
  }
}
