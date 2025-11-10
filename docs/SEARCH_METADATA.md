# Search Metadata Collection

## Overview
This document describes the search metadata feature that extends user profiles with additional fields (school year, interests, clubs) to enable advanced search and discovery functionality.

## New Profile Fields

### schoolYear (String, required)
- Represents the student's current academic year or level
- Options: `9`, `10`, `11`, `12`, `13`, `University`, `Graduate`
- Required during onboarding and profile editing
- Used for connecting users at similar academic levels

### interests (List<String>, required)
- List of user interests selected from a curated list or custom entries
- Minimum: 1 interest required
- Maximum: 20 interests
- Options include: Sports, Music, Art, Gaming, Reading, Science, Technology, Photography, Fashion, Cooking, Dancing, Movies, Travel, Fitness, Writing, Anime/Manga, Theater, Environment, Politics, Volunteering, Other
- Users can add custom interests not in the predefined list
- Used for finding users with similar interests

### clubs (List<String>, optional)
- List of clubs or extracurricular activities the user participates in
- Optional field
- Maximum: 20 clubs
- Options include: Student Council, Drama Club, Music Club, Art Club, Science Club, Math Club, Sports Team, Debate Club, Environmental Club, Robotics Club, Chess Club, Photography Club, Yearbook, Newspaper, Coding Club, Dance Team, Choir, Band, Orchestra, Volunteer Organization, Other
- Users can add custom clubs not in the predefined list
- Used for connecting users in similar activities

### searchKeywords (List<String>, auto-generated)
- Automatically generated list of lowercase keywords for search indexing
- Includes: nickname, school, school year, interests, clubs
- Maximum: 50 keywords
- Auto-updated whenever relevant fields change
- Used for efficient search queries

## Onboarding Flow Updates

The onboarding flow has been extended from 4 steps to 5 steps:

1. **Nickname Selection** (unchanged)
2. **Personal Information** (unchanged) - Gender and School
3. **Interests & School Year** (NEW)
   - Required school year selection
   - Required interests selection (at least 1)
   - Optional clubs selection
   - Custom interest/club input
4. **Consent & Privacy** (unchanged)
5. **Privacy Preferences** (unchanged)

### Step 3: Interests & School Year
- Users must select their school year from a dropdown
- Users must select at least one interest
- Interests can be selected from predefined chips or added as custom entries
- Clubs are optional but can be selected from predefined chips or added as custom entries
- Custom entries are added via text input with a + button
- Visual validation prevents proceeding without required fields

## Profile Edit Page Updates

The profile edit page now includes an "Interests & Activities" section with:
- School year dropdown (required)
- Interests selection using FilterChips (required, at least 1)
- Custom interest input field with add button
- Clubs selection using FilterChips (optional)
- Custom club input field with add button
- Visual display of custom interests/clubs with delete option

### Profile Completion Indicator
- A banner appears at the top if the profile is incomplete
- Prompts existing users to add school year and interests
- Reminds users that completing their profile helps with discoverability

## Data Storage

### Firestore Schema Extension
```dart
{
  // ... existing fields ...
  schoolYear: String?,
  interests: List<String>,
  clubs: List<String>,
  searchKeywords: List<String>,
}
```

### Search Keywords Generation
Keywords are automatically generated from:
- Nickname (lowercased)
- School (lowercased)
- School year (lowercased)
- Each interest (lowercased)
- Each club (lowercased)

Example:
```dart
UserProfile(
  nickname: 'JohnDoe',
  school: 'Liceo Arnaldo',
  schoolYear: '11',
  interests: ['Sports', 'Music'],
  clubs: ['Chess Club'],
)
// Generates searchKeywords:
// ['johndoe', 'liceo arnaldo', '11', 'sports', 'music', 'chess club']
```

## Migration Strategy

### New Users
- Required to complete all new fields during onboarding
- Cannot proceed to the app without school year and at least one interest

### Existing Users
- Existing profiles will have empty lists for interests/clubs and null schoolYear
- `isProfileComplete` getter now checks for presence of school year and interests
- Profile edit page shows a banner prompting users to complete their profile
- Users are not forcefully blocked but encouraged to update

### Backward Compatibility
- UserProfile model handles missing fields gracefully
- Empty lists returned for null interests/clubs in Firestore
- Search keywords auto-generated from available data on profile load

## Security Rules

### Validation
Firestore security rules have been updated to validate:
- `schoolYear` must be a string if present
- `interests` must be a list with 1-20 items if present
- `clubs` must be a list with maximum 20 items if present
- `searchKeywords` must be a list with maximum 50 items if present

### Helper Functions
```javascript
function isValidProfileData(data) {
  return (!('schoolYear' in data) || data.schoolYear is string) &&
         (!('interests' in data) || (data.interests is list && data.interests.size() >= 1 && data.interests.size() <= 20)) &&
         (!('clubs' in data) || (data.clubs is list && data.clubs.size() <= 20)) &&
         (!('searchKeywords' in data) || (data.searchKeywords is list && data.searchKeywords.size() <= 50));
}
```

## Indexing

### Firestore Indexes
While specific search indexes depend on the search implementation, consider creating:
- Composite index on `searchKeywords` (array-contains) + `school` (ascending)
- Composite index on `searchKeywords` (array-contains) + `schoolYear` (ascending)
- Array-contains queries for efficient keyword-based search

## API Updates

### UserRepository
The `UserRepository` class automatically handles search keywords:

```dart
// On profile creation
Future<void> createUserProfile(UserProfile profile) async {
  // Auto-generates and stores searchKeywords
}

// On profile update
Future<bool> updateUserProfile(String uid, Map<String, dynamic> updates) async {
  // Auto-regenerates searchKeywords when relevant fields change
}
```

## Testing

### Unit Tests
Added tests for:
- UserProfile serialization with new fields
- Search keyword generation
- Auto-generation of keywords when missing in Firestore
- List equality in profile comparisons

### Test Coverage
```dart
test('generateSearchKeywords creates proper keywords', () { ... });
test('fromJson auto-generates searchKeywords when missing', () { ... });
test('toJson includes new fields', () { ... });
```

## UI Components

### InterestsStep Widget
New onboarding step widget located at:
`lib/src/features/onboarding/presentation/widgets/interests_step.dart`

Features:
- School year dropdown
- Interest chips (FilterChip widgets)
- Club chips (FilterChip widgets)
- Custom entry text fields
- Validation on proceed

### Profile Edit Enhancements
Updated profile edit page includes:
- Interests & Activities card section
- Custom interest/club management
- Visual indication of custom vs. predefined selections
- Chip deletion for custom entries

## Constants

### UserInterests Class
Located at: `lib/src/core/constants/user_interests.dart`

Provides:
- `interests` - List of 21 predefined interest options
- `schoolYears` - List of 7 school year options
- `clubs` - List of 21 predefined club options

## Future Enhancements

### Search Implementation
- Full-text search using `searchKeywords` array-contains queries
- Filtering by school year, interests, or clubs
- User discovery based on shared interests
- Friend suggestions based on profile similarity

### Analytics
- Track popular interests and clubs
- Identify common interest combinations
- Suggest interests based on user behavior

### Moderation
- Review custom interests/clubs for inappropriate content
- Auto-moderate using profanity filters
- Flag suspicious or spam entries

## Migration Checklist

When deploying this feature:

1. ✅ Deploy updated Firestore security rules
2. ✅ Update client app with new UserProfile model
3. ✅ Add onboarding step for interests/school year
4. ✅ Update profile edit page with new sections
5. ✅ Test profile creation and updates
6. ✅ Verify search keyword generation
7. ✅ Create Firestore indexes for search queries
8. ⏳ Monitor for custom interest/club abuse
9. ⏳ Implement search functionality using keywords
10. ⏳ Add analytics for interest tracking

## Known Limitations

- Search keywords are limited to 50 items (should be sufficient for most profiles)
- Custom interests/clubs are not validated for appropriateness (requires moderation)
- No profanity filtering on custom entries (should be added)
- Search functionality itself is not implemented yet (this feature provides the data layer)

## Documentation Updates

- Updated `ONBOARDING_FLOW.md` with new step
- Created `SEARCH_METADATA.md` (this document)
- Updated API documentation for UserProfile model
- Added inline code documentation for new methods

## Support

For questions or issues related to this feature:
- Check UserProfile model documentation
- Review UserRepository implementation
- Examine InterestsStep widget for UI patterns
- Refer to test files for usage examples
