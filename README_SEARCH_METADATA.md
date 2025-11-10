# Search Metadata Feature

## Quick Start

### For New Users
New users will automatically see the updated onboarding flow:
1. Complete nickname selection
2. Provide personal info (gender, school)
3. **NEW**: Select school year and at least one interest
4. Accept consent and privacy policy
5. Configure privacy preferences

### For Existing Users
Existing users will see a banner on the profile edit page prompting them to complete their profile with school year and interests.

## Usage Examples

### Creating a Profile with Metadata
```dart
final profile = UserProfile(
  uid: 'user-123',
  nickname: 'StudentUser',
  nicknameVerified: true,
  school: 'Liceo Arnaldo',
  schoolYear: '11',
  interests: ['Sports', 'Technology', 'Gaming'],
  clubs: ['Robotics Club', 'Soccer Team'],
  createdAt: DateTime.now(),
  privacyConsentGiven: true,
  privacyConsentTimestamp: DateTime.now(),
);

// Search keywords are automatically generated:
// ['studentuser', 'liceo arnaldo', '11', 'sports', 'technology', 'gaming', 'robotics club', 'soccer team']
```

### Updating Profile Metadata
```dart
final updates = {
  'schoolYear': '12',
  'interests': ['Music', 'Art', 'Photography'],
  'clubs': ['Photography Club'],
};

final success = await userRepository.updateUserProfile(userId, updates);
// Search keywords are automatically regenerated
```

### Accessing Search Keywords
```dart
final keywords = profile.generateSearchKeywords();
// Returns lowercase keywords for search indexing
```

## Components

### New Constants
- `UserInterests.interests` - 21 predefined interest options
- `UserInterests.schoolYears` - 7 school year options
- `UserInterests.clubs` - 21 predefined club options

### New Widgets
- `InterestsStep` - Onboarding step for collecting metadata
- Enhanced `ProfileEditPage` with interests & activities section

### Updated Models
- `UserProfile` - Extended with schoolYear, interests, clubs, searchKeywords
- Auto-generates search keywords when missing
- Validates completeness including new required fields

## Testing

Run the updated tests:
```bash
flutter test test/src/features/profile/domain/models/user_profile_test.dart
```

New test coverage includes:
- Serialization with new fields
- Search keyword generation
- Auto-generation of keywords from Firestore data
- List field handling in equality checks

## Security

Firestore security rules validate:
- School year must be a string
- Interests list must have 1-20 items
- Clubs list must have 0-20 items
- Search keywords list must have 0-50 items

## Migration Notes

- Existing profiles remain valid but incomplete
- `isProfileComplete` now checks for school year and interests
- No breaking changes for existing code
- Backward compatible with profiles missing new fields

## Future Search Implementation

This feature provides the data layer for future search capabilities:
1. Find users by interest: `searchKeywords array-contains 'gaming'`
2. Filter by school year: `schoolYear == '11'`
3. Discover users with similar interests
4. Suggest connections based on shared clubs

## Documentation

See `docs/SEARCH_METADATA.md` for comprehensive documentation.
