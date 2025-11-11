import 'package:teen_talk_app/src/core/localization/app_localizations.dart';

import 'trust_level.dart';

String trustLevelLabel(TrustLevel trustLevel, AppLocalizations? localization) {
  switch (trustLevel) {
    case TrustLevel.newcomer:
      return localization?.trustBadgeNewcomerLabel ?? 'Newcomer';
    case TrustLevel.member:
      return localization?.trustBadgeMemberLabel ?? 'Member';
    case TrustLevel.trusted:
      return localization?.trustBadgeTrustedLabel ?? 'Trusted';
    case TrustLevel.veteran:
      return localization?.trustBadgeVeteranLabel ?? 'Veteran';
  }
}

String trustLevelDescription(TrustLevel trustLevel, AppLocalizations? localization) {
  switch (trustLevel) {
    case TrustLevel.newcomer:
      return localization?.trustBadgeNewcomerDescription ?? 'New to the community';
    case TrustLevel.member:
      return localization?.trustBadgeMemberDescription ?? 'Active community member';
    case TrustLevel.trusted:
      return localization?.trustBadgeTrustedDescription ?? 'Trusted community member';
    case TrustLevel.veteran:
      return localization?.trustBadgeVeteranDescription ?? 'Long-standing community member';
  }
}
