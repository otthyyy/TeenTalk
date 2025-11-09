import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../profile/domain/models/user_profile.dart';
import '../../data/models/conversation.dart';
import '../providers/direct_messages_provider.dart';
import '../widgets/conversation_list_item.dart';
import '../widgets/conversation_skeleton_loader.dart';

class MessagesPage extends ConsumerWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(conversationsProvider);
    final unreadCountAsync = ref.watch(unreadCountProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Messages',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Unread count header
          unreadCountAsync.when(
            data: (unreadCount) {
              if (unreadCount == 0) return const SizedBox.shrink();
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  border: Border(
                    bottom: BorderSide(
                      color: theme.colorScheme.surfaceVariant,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.mark_chat_unread_rounded,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      unreadCount == 1
                          ? '1 unread message'
                          : '$unreadCount unread messages',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          // Conversations list
          Expanded(
            child: conversationsAsync.when(
              data: (conversations) {
                final currentUserId = ref.watch(currentUserIdProvider);

                if (currentUserId == null) {
                  return _buildUnauthenticatedState(context, theme);
                }

                if (conversations.isEmpty) {
                  return _buildEmptyState(context, theme);
                }

                return ListView.separated(
                  itemCount: conversations.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    thickness: 0.5,
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                  ),
                  itemBuilder: (context, index) {
                    final conversation = conversations[index];
                    final otherUserId = _resolveOtherParticipant(
                      conversation,
                      currentUserId,
                    );

                    final otherUserProfileAsync = otherUserId != null
                        ? ref.watch(userProfileByIdProvider(otherUserId))
                        : const AsyncValue.data(null);

                    final unreadCount = conversation.unreadCounts != null
                        ? (conversation.unreadCounts![currentUserId] ?? 0)
                        : conversation.unreadCount;

                    final otherUserProfile = otherUserProfileAsync.maybeWhen(
                      data: (profile) => profile,
                      orElse: () => null,
                    );
                    final isProfileLoading = otherUserProfileAsync.isLoading;

                    return ConversationListItem(
                      conversation: conversation,
                      otherUserProfile: otherUserProfile,
                      otherUserId: otherUserId,
                      unreadCount: unreadCount,
                      isProfileLoading: isProfileLoading,
                      onTap: () async {
                        if (otherUserId == null) return;

                        try {
                          await context.push(
                            '/chat/${conversation.id}/$otherUserId',
                          );
                          await ref
                              .read(directMessagesRepositoryProvider)
                              .markConversationAsRead(
                                conversation.id,
                                currentUserId,
                              );
                        } catch (error) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Unable to open chat: ${error is Exception ? error.toString().replaceFirst("Exception:", '').trim() : error}',
                                ),
                              ),
                            );
                          }
                        }
                      },
                    );
                  },
                );
              },
              loading: () => const ConversationSkeletonLoader(),
              error: (error, stackTrace) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to load messages. Please retry.'),
                      ),
                    );
                  }
                });

                return _buildErrorState(context, theme, ref);
              },
            ),
          ),
        ],
      ),
    );
  }

  String? _resolveOtherParticipant(Conversation conversation, String currentUserId) {
    if (conversation.participantIds.isNotEmpty) {
      return conversation.participantIds.firstWhere(
        (id) => id != currentUserId,
        orElse: () => conversation.userId2,
      );
    }
    return conversation.userId1 == currentUserId
        ? conversation.userId2
        : conversation.userId1;
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 80,
              color: theme.colorScheme.surfaceVariant,
            ),
            const SizedBox(height: 24),
            Text(
              'No conversations yet',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Start a conversation with someone to see it here',
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

  Widget _buildUnauthenticatedState(BuildContext context, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: 80,
              color: theme.colorScheme.error.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Sign in required',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Please sign in to view your messages',
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

  Widget _buildErrorState(BuildContext context, ThemeData theme, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 80,
              color: theme.colorScheme.error.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Unable to load messages',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'An error occurred while loading your conversations',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.refresh(conversationsProvider);
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
