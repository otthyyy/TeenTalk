import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/direct_messages_repository.dart';
import '../providers/direct_messages_provider.dart' as dm_provider;
import '../widgets/message_bubble.dart';
import '../../../profile/presentation/providers/user_profile_provider.dart';
import '../../../offline_sync/services/offline_submission_helper.dart';
import '../../../profile/domain/models/user_profile.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/services/analytics_provider.dart';
import '../../../../common/widgets/trust_badge.dart';
import '../../../profile/domain/models/trust_level_localizations.dart';
import '../../../friends/data/repositories/friends_repository.dart';
import '../../../friends/data/models/friend_entry.dart';
import '../../../friends/presentation/providers/friends_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.otherUserId,
    this.otherUserDisplayName,
  });
  final String conversationId;
  final String otherUserId;
  final String? otherUserDisplayName;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  late final TextEditingController _messageController;
  bool _hasText = false;
  bool _lowTrustWarningShown = false;
  bool _canMessage = true;
  bool _isFriendshipLoading = true;
  bool _friendshipDialogShown = false;
  ProviderSubscription<AsyncValue<List<FriendEntry>>>? _friendsSubscription;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _messageController.addListener(_onTextChanged);
    _markConversationAsRead();
    _checkForLowTrustWarning();
    _checkFriendshipStatus();
    _friendsSubscription = ref.listenManual<AsyncValue<List<FriendEntry>>>(
      friendsListProvider,
      (previous, next) => _handleFriendshipUpdate(next),
      fireImmediately: true,
    );
  }

  void _checkForLowTrustWarning() {
    Future.microtask(() {
      if (!mounted) return;
      final otherUserProfileAsync = ref.read(userProfileByIdProvider(widget.otherUserId));
      otherUserProfileAsync.whenData((otherUserProfile) {
        if (otherUserProfile != null &&
            otherUserProfile.trustLevel.isLowTrust &&
            !_lowTrustWarningShown) {
          _showLowTrustWarning(otherUserProfile);
          _lowTrustWarningShown = true;
        }
      });
    });
  }

  void _onTextChanged() {
    final hasContent = _messageController.text.trim().isNotEmpty;
    if (hasContent != _hasText) {
      setState(() {
        _hasText = hasContent;
      });
    }
  }

  void _markConversationAsRead() {
    Future.microtask(() {
      final currentUserId = ref.read(dm_provider.currentUserIdProvider);
      if (currentUserId != null) {
        final repository = ref.read(directMessagesRepositoryProvider);
        repository.markConversationAsRead(widget.conversationId, currentUserId);
      }
    });
  }

  void _showLowTrustWarning(UserProfile otherUserProfile) {
    if (!mounted) return;

    final localization = AppLocalizations.of(context);
    final analytics = ref.read(analyticsServiceProvider);
    analytics.logLowTrustWarning(widget.otherUserId, 'direct_message');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded, size: 48),
        title: Text(
          localization?.trustLowTrustWarningTitle ?? 'New User',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TrustBadge(
              trustLevel: otherUserProfile.trustLevel,
              showLabel: true,
              size: 20,
            ),
            const SizedBox(height: 16),
            Text(
              localization?.trustLowTrustWarningDescription ??
                  'This user is new to the community. Please be cautious when interacting.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              analytics.logLowTrustWarningDismiss(
                widget.otherUserId,
                'direct_message',
              );
              Navigator.of(context).maybePop();
            },
            child: Text(
              localization?.trustLowTrustWarningCancel ?? 'Cancel',
            ),
          ),
          FilledButton(
            onPressed: () {
              analytics.logLowTrustWarningProceed(
                widget.otherUserId,
                'direct_message',
              );
              Navigator.of(context).maybePop();
            },
            child: Text(
              localization?.trustLowTrustWarningProceed ?? 'Continue',
            ),
          ),
        ],
      ),
    );
  }

  void _checkFriendshipStatus() {
    Future.microtask(() async {
      if (!mounted) return;
      final currentUserId = ref.read(dm_provider.currentUserIdProvider);
      if (currentUserId == null) return;

      final friendsRepository = ref.read(friendsRepositoryProvider);
      final areFriends = await friendsRepository.areFriends(currentUserId, widget.otherUserId);

      if (mounted) {
        setState(() {
          _canMessage = areFriends;
          _isFriendshipLoading = false;
        });

        if (!areFriends && !_friendshipDialogShown && context.mounted) {
          _friendshipDialogShown = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              _showNotFriendsDialog();
            }
          });
        }
      }
    });
  }

  void _handleFriendshipUpdate(AsyncValue<List<FriendEntry>> friendsAsync) {
    friendsAsync.whenData((friends) async {
      final currentUserId = ref.read(dm_provider.currentUserIdProvider);
      if (currentUserId == null) return;

      final isFriend = friends.any((entry) => entry.friendId == widget.otherUserId);
      
      if (_canMessage != isFriend) {
        setState(() {
          _canMessage = isFriend;
        });

        if (!isFriend && !_friendshipDialogShown && mounted && context.mounted) {
          _friendshipDialogShown = true;
          _showNotFriendsDialog();
        }
      }
    });
  }

  @override
  void dispose() {
    _friendsSubscription?.close();
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = ref.watch(dm_provider.currentUserIdProvider);
    final messagesAsync = ref.watch(dm_provider.messagesProvider(widget.conversationId));
    final sendMessageAsync = ref.watch(dm_provider.sendMessageProvider);

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.otherUserDisplayName ?? 'Chat',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (widget.otherUserDisplayName != null)
              Text(
                'Direct Messages',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_isFriendshipLoading)
            const LinearProgressIndicator(minHeight: 2),
          if (!_canMessage && !_isFriendshipLoading)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: theme.colorScheme.errorContainer.withOpacity(0.4),
              child: Row(
                children: [
                  Icon(
                    Icons.lock_outline,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You can only send messages to accepted friends.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 64,
                            color: theme.colorScheme.surfaceContainerHighest,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No messages yet',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start the conversation by sending a message below',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _markConversationAsRead();
                });

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isCurrentUser =
                        message.senderId == currentUserId;

                    return MessageBubble(
                      message: message,
                      isCurrentUser: isCurrentUser,
                      senderName: isCurrentUser
                          ? 'You'
                          : widget.otherUserDisplayName,
                    );
                  },
                );
              },
              loading: () => Center(
                child: CircularProgressIndicator(
                  color: theme.colorScheme.primary,
                ),
              ),
              error: (error, stackTrace) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 64,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading messages',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        style: theme.textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(color: theme.colorScheme.surfaceContainerHighest),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _messageController,
                        enabled: _canMessage && !_isFriendshipLoading,
                        minLines: 1,
                        maxLines: 6,
                        decoration: InputDecoration(
                          hintText: _isFriendshipLoading
                              ? 'Loading...'
                              : _canMessage
                                  ? 'Type a message...'
                                  : 'Friends only',
                          hintStyle: !_canMessage
                              ? TextStyle(
                                  color: theme.colorScheme.error.withOpacity(0.7),
                                )
                              : null,
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (sendMessageAsync.isLoading)
                    const SizedBox(
                      width: 44,
                      height: 44,
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  else
                    InkWell(
                      onTap: !_hasText || !_canMessage ? null : _sendMessage,
                      borderRadius: BorderRadius.circular(24),
                      child: Ink(
                        decoration: BoxDecoration(
                          color: !_hasText || !_canMessage
                              ? theme.colorScheme.surfaceContainerHighest
                              : theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        width: 44,
                        height: 44,
                        child: Icon(
                          Icons.send_rounded,
                          color: !_hasText || !_canMessage
                              ? theme.colorScheme.onSurface.withOpacity(0.4)
                              : theme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final offlineHelper = ref.read(offlineSubmissionHelperProvider);
    final currentUserId = ref.read(dm_provider.currentUserIdProvider);
    
    if (currentUserId == null) return;

    final friendsRepository = ref.read(friendsRepositoryProvider);
    final areFriends = await friendsRepository.areFriends(currentUserId, widget.otherUserId);

    if (!areFriends) {
      if (mounted && context.mounted) {
        _showNotFriendsDialog();
      }
      return;
    }

    final isOnline = await offlineHelper.isOnline();

    if (!isOnline) {
      final queuedId = await offlineHelper.enqueueDirectMessage(
        senderId: currentUserId,
        receiverId: widget.otherUserId,
        text: text,
      );

      _messageController.clear();

      if (mounted && context.mounted) {
        if (queuedId != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Message queued. We'll send it when you're online."),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to queue message.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
      return;
    }

    try {
      final notifier = ref.read(dm_provider.sendMessageProvider.notifier);
      await notifier.sendMessage(
        receiverId: widget.otherUserId,
        text: text,
      );

      _messageController.clear();

      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Message sent'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (error) {
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showNotFriendsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.person_off, size: 48),
        title: const Text('Friends Only'),
        content: const Text(
          'You can only send messages to accepted friends. '
          'Please send a friend request first.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
