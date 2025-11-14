import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/localization/app_localizations.dart';

enum LegalDocumentType {
  privacyPolicy,
  termsOfService,
}

extension LegalDocumentTypeX on LegalDocumentType {
  String get assetBaseName {
    switch (this) {
      case LegalDocumentType.privacyPolicy:
        return 'privacy_policy';
      case LegalDocumentType.termsOfService:
        return 'terms_of_service';
    }
  }

  String get routeSegment {
    switch (this) {
      case LegalDocumentType.privacyPolicy:
        return 'privacy-policy';
      case LegalDocumentType.termsOfService:
        return 'terms-of-service';
    }
  }

  String title(AppLocalizations? localizations) {
    switch (this) {
      case LegalDocumentType.privacyPolicy:
        return localizations?.legalPrivacyPolicyTitle ?? 'Privacy Policy';
      case LegalDocumentType.termsOfService:
        return localizations?.legalTermsOfServiceTitle ?? 'Terms of Service';
    }
  }
}

LegalDocumentType? legalDocumentTypeFromRouteSegment(String? segment) {
  switch (segment) {
    case 'privacy':
    case 'privacy-policy':
      return LegalDocumentType.privacyPolicy;
    case 'terms':
    case 'terms-of-service':
      return LegalDocumentType.termsOfService;
    default:
      return null;
  }
}

class LegalDocumentPage extends StatefulWidget {
  const LegalDocumentPage({
    super.key,
    required this.documentType,
  });

  static const routeName = 'legal-document';

  final LegalDocumentType documentType;

  @override
  State<LegalDocumentPage> createState() => _LegalDocumentPageState();
}

class LegalDocumentUnavailablePage extends StatelessWidget {
  const LegalDocumentUnavailablePage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.legalUnavailableTitle ?? 'Document not found'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            localizations?.legalUnavailableMessage ??
                'The requested legal document could not be found.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _LegalDocumentPageState extends State<LegalDocumentPage> {
  Future<String>? _documentFuture;
  String? _activeLocaleCode;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final localeCode = Localizations.localeOf(context).languageCode.toLowerCase();
    if (_documentFuture == null || _activeLocaleCode != localeCode) {
      _activeLocaleCode = localeCode;
      _documentFuture = _loadDocument(localeCode);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<String> _loadDocument(String localeCode) async {
    final normalizedCode = localeCode == 'it' ? 'it' : 'en';
    final assetCandidates = <String>[
      'assets/legal/${widget.documentType.assetBaseName}_$normalizedCode.md',
    ];

    if (normalizedCode != 'en') {
      assetCandidates.add('assets/legal/${widget.documentType.assetBaseName}_en.md');
    }

    for (final path in assetCandidates) {
      try {
        return await rootBundle.loadString(path);
      } catch (_) {
        // Try next fallback path.
      }
    }

    throw FlutterError('Missing asset for ${widget.documentType.assetBaseName}');
  }

  void _reloadDocument() {
    final localeCode = _activeLocaleCode;
    if (localeCode == null) return;
    setState(() {
      _documentFuture = _loadDocument(localeCode);
    });
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      final localizations = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            localizations?.legalLinkOpenError ?? 'Unable to open link.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    final markdownStyle = MarkdownStyleSheet.fromTheme(theme).copyWith(
      h1: theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
      ),
      h2: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
      ),
      h3: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      p: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
      listBullet: theme.textTheme.bodyLarge,
      a: TextStyle(
        color: theme.colorScheme.primary,
        decoration: TextDecoration.underline,
      ),
      blockSpacing: 16,
      listIndent: 24,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.documentType.title(localizations)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: localizations?.legalReload ?? 'Reload',
            onPressed: _reloadDocument,
          ),
        ],
      ),
      body: FutureBuilder<String>(
        future: _documentFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _LegalDocumentErrorView(
              message: localizations?.legalLoadError ?? 'Unable to load document.',
              onRetry: _reloadDocument,
            );
          }

          final documentContent = snapshot.data ?? '';
          return Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            child: Markdown(
              controller: _scrollController,
              data: documentContent,
              selectable: true,
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              styleSheet: markdownStyle,
              onTapLink: (text, href, title) {
                if (href != null) {
                  _openLink(href);
                }
              },
            ),
          );
        },
      ),
    );
  }
}

class _LegalDocumentErrorView extends StatelessWidget {
  const _LegalDocumentErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
