# Legal Documents Update Guide

This guide explains how to update the Privacy Policy and Terms of Service documents displayed in the TeenTalk app.

## Document Locations

Legal documents are stored as Markdown files in the `assets/legal/` directory:

```
assets/legal/
├── privacy_policy_en.md
├── privacy_policy_it.md
├── terms_of_service_en.md
└── terms_of_service_it.md
```

## Supported Languages

Currently, the app supports the following languages:
- **English (en)** - Default fallback language
- **Italian (it)**

If a user's device is set to a language other than Italian, the English version will be displayed by default.

## How to Update Documents

### 1. Local Updates (Development/Testing)

To update legal documents locally:

1. Navigate to `assets/legal/` directory
2. Edit the appropriate `.md` file(s):
   - `privacy_policy_en.md` for English Privacy Policy
   - `privacy_policy_it.md` for Italian Privacy Policy
   - `terms_of_service_en.md` for English Terms of Service
   - `terms_of_service_it.md` for Italian Terms of Service
3. Save your changes
4. Test in the app by:
   - Running the app: `flutter run`
   - Navigating to Profile → Consent & Privacy section
   - Tapping "View Privacy Policy" or "View Terms of Service"
   - Verifying changes are displayed correctly
   - Testing the reload button to ensure assets load properly

### 2. Production Updates

For production updates:

1. **Update the documents:**
   - Make changes to the markdown files as described above
   - Update the "Last Updated" date at the top of each document
   - Ensure formatting is correct (Markdown syntax)

2. **Commit changes:**
   ```bash
   git add assets/legal/
   git commit -m "docs: update legal documents - [brief description]"
   ```

3. **Deploy:**
   - Push changes to your repository
   - Rebuild and deploy the app according to your deployment process
   - The new documents will be included in the app bundle

### 3. Remote Updates (Optional Enhancement)

For future implementation, you can add Firebase Remote Config to update documents without app updates:

**Benefits:**
- Update documents without releasing a new app version
- A/B test different document versions
- Emergency updates for compliance

**Implementation Steps:**
1. Add Firebase Remote Config to `pubspec.yaml`
2. Create Remote Config keys for legal documents:
   - `privacy_policy_en`
   - `privacy_policy_it`
   - `terms_of_service_en`
   - `terms_of_service_it`
3. Modify `LegalDocumentPage` to:
   - First attempt to load from Remote Config
   - Fall back to local assets if remote fetch fails
4. Add cache expiration (e.g., 1 hour)

**Example Remote Config Implementation:**
```dart
// In LegalDocumentPage
Future<String> _loadDocument(String localeCode) async {
  final remoteConfig = FirebaseRemoteConfig.instance;
  
  // Try Remote Config first
  try {
    await remoteConfig.fetchAndActivate();
    final remoteContent = remoteConfig.getString(
      '${widget.documentType.assetBaseName}_${localeCode}'
    );
    if (remoteContent.isNotEmpty) {
      return remoteContent;
    }
  } catch (e) {
    // Log error but continue to fallback
  }
  
  // Fallback to local assets
  return await rootBundle.loadString(_assetPath);
}
```

## Document Format Guidelines

### Markdown Structure

Legal documents should follow this structure:

```markdown
# Document Title

**Last Updated:** Month Year

## 1. Section Title

Content here...

### Subsection Title

More content...

- Bullet point
- Another bullet point

## 2. Next Section

Continue...
```

### Style Guidelines

- **Headers:** Use `#` for main title, `##` for sections, `###` for subsections
- **Bold:** Use `**text**` for emphasis (e.g., section labels)
- **Lists:** Use `-` for unordered lists
- **Links:** Format as `[Link Text](https://example.com)`
- **Line Breaks:** Leave blank lines between sections for proper spacing
- **Email:** Use inline code or plain text: `privacy@teentalk.app`

### Content Guidelines

1. **Clarity:** Write in clear, straightforward language
2. **Legal Accuracy:** Have documents reviewed by legal counsel
3. **GDPR Compliance:** Ensure Privacy Policy addresses all GDPR requirements
4. **Age-Appropriate:** Remember your audience includes teenagers
5. **Contact Information:** Always include contact details for inquiries
6. **Last Updated Date:** Keep dates current with each update

## Localization

### Adding a New Language

To add support for a new language (e.g., Spanish):

1. **Create new document files:**
   ```bash
   cp assets/legal/privacy_policy_en.md assets/legal/privacy_policy_es.md
   cp assets/legal/terms_of_service_en.md assets/legal/terms_of_service_es.md
   ```

2. **Translate the content:**
   - Translate all text while maintaining markdown formatting
   - Have translations reviewed by native speakers
   - Ensure legal accuracy with local counsel if needed

3. **Update the app code:**
   
   In `lib/src/features/legal/presentation/pages/legal_document_page.dart`:
   ```dart
   Future<String> _loadDocument(String localeCode) async {
     // Add 'es' to supported locales
     final normalizedCode = ['it', 'es'].contains(localeCode) 
       ? localeCode 
       : 'en';
     // ... rest of method
   }
   ```

4. **Update localization strings:**
   
   Add translations in:
   - `lib/src/core/localization/app_localizations_es.dart`
   - Update all `legalXxx` string getters

5. **Test the new language:**
   - Change device language to the new locale
   - Verify documents load correctly
   - Check all UI strings are properly translated

## Testing Checklist

Before deploying updated legal documents:

- [ ] Documents render correctly in the app
- [ ] All Markdown formatting displays properly
- [ ] Links work correctly (if any)
- [ ] Scrolling works smoothly for long documents
- [ ] Text is selectable for copying
- [ ] Documents load in all supported languages
- [ ] Fallback to English works for unsupported locales
- [ ] Reload button refreshes content
- [ ] Navigation works from all entry points:
  - [ ] Onboarding consent step
  - [ ] Profile page (Consent & Privacy card)
  - [ ] Direct navigation via deep links

## User Access Points

Users can access legal documents from:

1. **Onboarding Flow:**
   - During account creation
   - Consent step with inline links in checkbox text

2. **Profile Page:**
   - "Consent & Privacy" card
   - "View Privacy Policy" link
   - "View Terms of Service" link

3. **Direct Links (for future use):**
   - `/legal/privacy-policy`
   - `/legal/terms-of-service`
   - Also accessible via shortened URLs: `/legal/privacy`, `/legal/terms`

## Version Control Best Practices

1. **Keep a changelog:**
   - Document what changed in each version
   - Include dates and reasons for changes

2. **Tag releases:**
   ```bash
   git tag -a legal-docs-v1.1 -m "Updated privacy policy for GDPR compliance"
   git push origin legal-docs-v1.1
   ```

3. **Review process:**
   - Have legal team review changes
   - Get approval before merging to main branch
   - Document approval in commit messages

## Compliance Notes

### GDPR Requirements

Ensure Privacy Policy includes:
- What data is collected
- How data is used
- Data retention policies
- User rights (access, deletion, portability)
- Contact information for data protection officer
- Information about third-party services

### COPPA Compliance

For users under 13 (US):
- Parental consent requirements
- What information is collected from minors
- How to review/delete child's information

### Updates Notification

When making significant changes:
1. Update "Last Updated" date
2. Consider in-app notification to existing users
3. Log update in app analytics
4. For major changes, may require users to re-consent

## Support

For questions about legal documents:
- **Legal Team:** legal@teentalk.app
- **Privacy Inquiries:** privacy@teentalk.app
- **Technical Issues:** dev@teentalk.app

## Emergency Updates

If an urgent legal update is needed:

1. **Immediate action:**
   - Update document files
   - Create hotfix branch
   - Fast-track review and approval

2. **Deploy:**
   - Build emergency release
   - Deploy to app stores with expedited review request
   - If implemented: Use Remote Config for instant update

3. **Notify users:**
   - Push notification if critical
   - In-app banner
   - Email notification

---

*Document maintained by: TeenTalk Development Team*  
*Last reviewed: January 2024*
