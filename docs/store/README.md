# TeenTalk Store Assets

This directory contains all assets, copy, and documentation required for App Store (iOS) and Google Play Store (Android) submissions.

## Directory Structure

```
docs/store/
├── README.md                           # This file - overview and guidelines
├── SUBMISSION_CHECKLIST.md             # Complete submission checklist
├── ASSET_REQUIREMENTS.md               # Detailed asset specifications
├── SCREENSHOT_GUIDELINES.md            # Screenshot capture and naming guidelines
├── assets/                             # All visual assets
│   ├── app-store/                      # iOS App Store assets
│   │   ├── screenshots/
│   │   │   ├── iphone/
│   │   │   │   ├── en/                 # English iPhone screenshots (6.7", 6.5", 5.5")
│   │   │   │   └── it/                 # Italian iPhone screenshots
│   │   │   └── ipad/
│   │   │       ├── en/                 # English iPad screenshots (12.9", 11")
│   │   │       └── it/                 # Italian iPad screenshots
│   │   ├── feature-graphics/           # App Preview videos, promotional images
│   │   └── app-icons/                  # App icon variants (1024x1024)
│   └── google-play/                    # Google Play Store assets
│       ├── screenshots/
│       │   ├── phone/
│       │   │   ├── en/                 # English phone screenshots
│       │   │   └── it/                 # Italian phone screenshots
│       │   └── tablet/
│       │       ├── en/                 # English tablet screenshots
│       │       └── it/                 # Italian tablet screenshots
│       ├── feature-graphics/           # Feature graphic (1024x500), promo video
│       └── app-icons/                  # High-res icon (512x512)
├── copy/                               # Store listing copy
│   ├── app-store-en.md                 # App Store English listing
│   ├── app-store-it.md                 # App Store Italian listing
│   ├── google-play-en.md               # Google Play English listing
│   ├── google-play-it.md               # Google Play Italian listing
│   └── keywords.md                     # SEO keywords and ASO strategy
├── privacy/                            # Privacy and data usage
│   ├── ios-privacy-labels.md           # iOS App Privacy details
│   ├── google-data-safety.md           # Google Play Data safety section
│   └── privacy-policy-summary.md       # Summary for reviewers
└── automation/                         # Screenshot automation scripts
    ├── capture_screenshots.sh          # Shell script for automated capture
    └── README.md                       # Automation setup guide
```

## Quick Start

### 1. Review Requirements
- Read [`ASSET_REQUIREMENTS.md`](ASSET_REQUIREMENTS.md) for platform-specific specifications
- Review [`SCREENSHOT_GUIDELINES.md`](SCREENSHOT_GUIDELINES.md) for capture instructions

### 2. Generate Screenshots
- Use sample data (test accounts with realistic content)
- Follow naming conventions in screenshot guidelines
- Capture both light and dark mode variants
- Ensure device frames and status bar are clean

### 3. Create Feature Graphics
- Use brand colors (Purple #8B5CF6, Pink #EC4899, Cyan #06B6D4)
- Design in Figma or similar tool
- Export at required resolutions
- Maintain consistency across platforms

### 4. Localize Store Copy
- Draft descriptions in English first
- Translate to Italian (review with native speaker)
- Include keywords naturally in descriptions
- Ensure compliance with platform character limits

### 5. Complete Privacy Documentation
- Fill out iOS Privacy Labels
- Complete Google Play Data Safety section
- Reference existing privacy policy and Crashlytics statement

### 6. Submit for Review
- Use [`SUBMISSION_CHECKLIST.md`](SUBMISSION_CHECKLIST.md) to verify all requirements
- Prepare test accounts for reviewers
- Document any special setup instructions

## Asset Specifications Summary

### App Store (iOS)

| Asset Type | Size | Format | Required |
|------------|------|--------|----------|
| iPhone 6.7" screenshots | 1290 x 2796 px | PNG/JPG | 3-10 images |
| iPhone 6.5" screenshots | 1242 x 2688 px | PNG/JPG | 3-10 images |
| iPad 12.9" screenshots | 2048 x 2732 px | PNG/JPG | 3-10 images |
| App icon | 1024 x 1024 px | PNG (no alpha) | 1 image |
| App Preview (optional) | Up to 30s | MP4/MOV | 1-3 videos |

### Google Play Store

| Asset Type | Size | Format | Required |
|------------|------|--------|----------|
| Phone screenshots | 1080 x 1920 px (min) | PNG/JPG | 2-8 images |
| 7" Tablet screenshots | 1200 x 1920 px (min) | PNG/JPG | Recommended |
| 10" Tablet screenshots | 1920 x 1200 px (min) | PNG/JPG | Recommended |
| Feature graphic | 1024 x 500 px | PNG/JPG | 1 image |
| High-res icon | 512 x 512 px | PNG (32-bit) | 1 image |
| Promo video (optional) | YouTube link | YouTube URL | 1 video |

## Store Listing Character Limits

### App Store
- **App Name**: 30 characters
- **Subtitle**: 30 characters
- **Promotional Text**: 170 characters (updateable without review)
- **Description**: 4,000 characters
- **Keywords**: 100 characters (comma-separated, no spaces)
- **What's New**: 4,000 characters

### Google Play
- **App Name**: 50 characters
- **Short Description**: 80 characters
- **Full Description**: 4,000 characters

## Brand Guidelines

### Colors
- **Primary**: Vibrant Purple (#8B5CF6)
- **Secondary**: Vibrant Pink (#EC4899)
- **Tertiary**: Vibrant Cyan (#06B6D4)
- **Accent**: Vibrant Yellow (#FBBF24)

### Typography
- **Headlines**: Bold, Weight 700
- **Body**: Regular, Weight 400
- **Emphasis**: Vibrant purple for key features

### Voice & Tone
- **Friendly**: Conversational, approachable
- **Youth-focused**: Modern, energetic
- **Safe**: Emphasize privacy and community guidelines
- **Inclusive**: Welcome all teens regardless of background

## Review Process

### App Store Review
- **Timeline**: 24-48 hours typically
- **Common rejections**:
  - Incomplete app metadata
  - Inadequate privacy policy
  - Missing parental consent for under-18 apps
  - Bugs or crashes during review
- **Test account**: Provide fully set up account with sample data

### Google Play Review
- **Timeline**: Few hours to 7 days
- **Common rejections**:
  - Misleading store listing
  - Inappropriate content
  - Privacy policy issues
  - Permissions not justified
- **Testing instructions**: Include notes for reviewers

## Localization Notes

### Italian Translation
- Use formal "lei" for user-facing copy (respectful but friendly)
- Adapt cultural references (e.g., school system differences)
- Review with native Italian teen for authenticity
- Check character limits post-translation (Italian often longer)

### English (Primary)
- US English spelling and conventions
- Clear, concise language (avoid jargon)
- SEO-optimized keywords
- ADA-friendly descriptions

## Content Guidelines

### Do's
✅ Highlight key features (social feed, messaging, privacy)
✅ Emphasize safety features and moderation
✅ Use real screenshots with authentic sample data
✅ Show diverse representation in user content
✅ Mention COPPA/GDPR compliance for parent trust

### Don'ts
❌ Use placeholder or Lorem Ipsum text in screenshots
❌ Show real user data or PII
❌ Make unverifiable claims ("best app ever")
❌ Include copyrighted content without permission
❌ Show inappropriate content for teen audience

## Testing Accounts for Reviewers

Create test accounts with:
- **Email**: reviewer1@teentalk.test (and reviewer2@)
- **Password**: TeenTalk2024Review!
- **Profile**: Complete onboarding, age 16+
- **Sample data**: 
  - 5-10 posts in feed
  - 2-3 comments on posts
  - 1-2 direct message conversations
  - Profile with photo and bio

Include credentials in App Store Connect / Google Play Console notes for reviewers.

## Related Documentation

- [Privacy Statement (Crashlytics)](../PRIVACY_STATEMENT_CRASHLYTICS.md)
- [Design System](../../DESIGN_SYSTEM.md)
- [Beta Program Setup](../../BETA_PROGRAM_SETUP.md)
- [Deployment Notes](../../DEPLOYMENT_NOTES.md)

## Contacts

For questions or review:
- **Product Lead**: [Name]
- **Design Lead**: [Name]
- **Localization**: [Name]
- **Legal/Privacy**: [Email]

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | TBD | Initial App Store and Play Store submission |

---

**Next Steps**: Start with screenshot capture using [`SCREENSHOT_GUIDELINES.md`](SCREENSHOT_GUIDELINES.md), then proceed to feature graphics and store copy.
