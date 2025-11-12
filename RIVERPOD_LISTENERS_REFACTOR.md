# Riverpod Listeners Refactor

## Overview

This document describes the refactor that moved `ref.listen` calls from global providers to widget lifecycle contexts, resolving Riverpod assertions.

## Problem

`ref.listen` calls defined inside global providers (e.g., `crashlyticsSyncProvider` and `pushNotificationsControllerProvider`) triggered build-time assertions in Riverpod. The framework expects listeners to be set up within widget lifecycle contexts, not in provider bodies.

## Solution

### 1. Created Widget-Level Listeners

**CrashlyticsListener** (`lib/src/core/widgets/crashlytics_listener.dart`)
- `ConsumerStatefulWidget` that subscribes to `authStateProvider` and `userProfileProvider`
- Uses `ref.listenManual` in `initState` (inside `addPostFrameCallback`) to set up listeners
- Calls Crashlytics service methods to set user metadata
- Properly disposes subscriptions in `dispose`
- Wraps child widget without affecting layout or interaction

**PushNotificationsListener** (`lib/src/services/push_notifications_listener.dart`)
- `ConsumerStatefulWidget` that subscribes to `authStateProvider`
- Uses `ref.listenManual` in `initState` (inside `addPostFrameCallback`) to set up listeners
- Calls push notifications service methods on auth changes
- Properly disposes subscriptions in `dispose`
- Wraps child widget without affecting layout or interaction

### 2. Integrated Listeners into App Root

Modified `TeenTalkApp` in `lib/main.dart` to mount the listener widgets:

```dart
return CrashlyticsListener(
  child: PushNotificationsListener(
    child: ScreenshotProtectedContent(
      child: MaterialApp.router(
        // ...
      ),
    ),
  ),
);
```

The listeners are placed near the root of the widget tree, ensuring they are active throughout the app lifecycle.

### 3. Cleaned Up Old Providers

**Removed:**
- `crashlyticsSyncProvider` side effects from `lib/src/core/providers/crashlytics_provider.dart`
- `lib/src/services/push_notifications_controller.dart` (entire file)

**Simplified:**
- `crashlytics_provider.dart` now only exports `crashlyticsServiceProvider`
- Removed all `ref.listen` calls from provider definitions

### 4. Added Tests

Created `test/core/widgets/listeners_test.dart` with comprehensive widget tests:
- Smoke tests to ensure listeners don't throw assertions
- Integration tests to verify both listeners work together
- Tests to verify service methods are called on auth/profile changes

## Benefits

1. **No Riverpod Assertions**: The app no longer throws assertions about calling `ref.listen` outside of widget lifecycle
2. **Proper Lifecycle Management**: Subscriptions are properly created and disposed with widget lifecycle
3. **Preserved Behavior**: Crashlytics and push notification side effects still run when auth/profile changes
4. **Better Separation of Concerns**: Listeners are explicitly managed in widget tree, not hidden in provider definitions
5. **Testability**: Easier to test listener behavior with widget tests

## Implementation Details

### Using `ref.listenManual`

Instead of regular `ref.listen`, we use `ref.listenManual` which returns a `ProviderSubscription` that can be manually disposed:

```dart
_authSubscription = ref.listenManual(
  authStateProvider,
  (previous, next) {
    // Handle state change
  },
  fireImmediately: true,  // Trigger on initial value
);
```

### Lifecycle Management

```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _setupListeners();
  });
}

@override
void dispose() {
  unawaited(_authSubscription?.close());
  unawaited(_profileSubscription?.close());
  super.dispose();
}
```

Using `addPostFrameCallback` ensures the widget is fully built before setting up listeners, avoiding any potential timing issues.

## Migration Guide

If you need to add new global side effects:

1. **DON'T** add `ref.listen` calls inside provider definitions
2. **DO** create a new `ConsumerStatefulWidget` listener
3. **DO** use `ref.listenManual` in `initState` (inside `addPostFrameCallback`)
4. **DO** properly dispose subscriptions in `dispose`
5. **DO** mount the listener near the app root in `main.dart`

## Related Files

- `lib/main.dart` - App root with mounted listeners
- `lib/src/core/widgets/crashlytics_listener.dart` - Crashlytics listener widget
- `lib/src/services/push_notifications_listener.dart` - Push notifications listener widget
- `lib/src/core/providers/crashlytics_provider.dart` - Simplified provider
- `test/core/widgets/listeners_test.dart` - Widget tests for listeners
