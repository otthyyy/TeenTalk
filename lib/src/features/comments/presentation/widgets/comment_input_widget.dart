import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/brescia_schools.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/providers/analytics_provider.dart';
import '../../../../core/providers/rate_limit_provider.dart';
import '../../../../core/services/rate_limit_service.dart';
import '../../../../core/widgets/rate_limit_dialog.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/domain/models/user_profile.dart';
import '../../../profile/presentation/providers/user_profile_provider.dart';
import '../providers/comments_provider.dart';

class CommentInputWidget extends ConsumerStatefulWidget {
  final String postId;
  final String? replyToCommentId;
  final String? replyToAuthorNickname;
  final VoidCallback? onCommentPosted;
  final VoidCallback? onCancelReply;

  const CommentInputWidget({
    super.key,
    required this.postId,
    this.replyToCommentId,
    this.replyToAuthorNickname,
    this.onCommentPosted,
    this.onCancelReply,
  });

  @override
  ConsumerState<CommentInputWidget> createState() => _CommentInputWidgetState();
}

class _CommentInputWidgetState extends ConsumerState<CommentInputWidget> {
  final TextEditingController _textController = TextEditingController();
  bool _isAnonymous = false;
  bool _isSubmitting = false;
  bool _hasInitializedPreferences = false;
  bool _hasWarnedNearLimit = false;

  @override
  void initState() {
    super.initState();
    if (widget.replyToAuthorNickname != null) {
      final prefill = '@${widget.replyToAuthorNickname} ';
      _textController.text = prefill;
      _textController.selection = TextSelection.fromPosition(
        TextPosition(offset: prefill.length),
      );
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _initializePreferences(UserProfile? profile) {
    if (_hasInitializedPreferences) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      setState(() {
        _isAnonymous = profile?.allowAnonymousPosts ?? false;
        _hasInitializedPreferences = true;
      });

      final selectedSchool = ref.read(selectedCommentSchoolProvider);
      final preferredSchool = profile?.school;
      if ((selectedSchool == null || selectedSchool.isEmpty) &&
          preferredSchool != null &&
          preferredSchool.isNotEmpty) {
        ref.read(selectedCommentSchoolProvider.notifier).state = preferredSchool;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authStateProvider);
    final profileAsync = ref.watch(userProfileProvider);
    final selectedSchool = ref.watch(selectedCommentSchoolProvider);
    final rateLimitStatus = ref.watch(commentRateLimitStatusProvider);

    return profileAsync.when(
      data: (profile) {
        _initializePreferences(profile);

        final isAuthenticated = authState.user != null && profile != null;
        
        return rateLimitStatus.when(
          data: (status) {
            if (status.isNearLimit && !_hasWarnedNearLimit && isAuthenticated) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  ref.read(analyticsServiceProvider).logRateLimitWarning(
                    contentType: 'comment',
                    remainingSubmissions: math.min(
                      status.remainingPerMinute,
                      status.remainingPerHour,
                    ),
                  );
                  setState(() => _hasWarnedNearLimit = true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        l10n?.rateLimitNearLimitWarning ?? 'Approaching comment limit',
                      ),
                      backgroundColor: theme.colorScheme.tertiary,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              });
            }

            final canSubmit = isAuthenticated &&
                !_isSubmitting &&
                status.canSubmit &&
                _textController.text.trim().isNotEmpty &&
                (selectedSchool != null && selectedSchool.isNotEmpty);

            return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.replyToAuthorNickname != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.reply,
                        size: 18,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Replying to ${widget.replyToAuthorNickname}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: widget.onCancelReply,
                        icon: Icon(
                          Icons.close,
                          size: 16,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                        tooltip: 'Cancel reply',
                      ),
                    ],
                  ),
                ),
              if (!status.canSubmit)
                _buildCommentCooldownBanner(status, theme, l10n)
              else if (status.isNearLimit)
                _buildCommentWarningBanner(theme, l10n),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: widget.replyToCommentId != null
                            ? 'Write a reply...'
                            : 'Write a comment...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: canSubmit ? _submitComment : null,
                    icon: _isSubmitting
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.onPrimary,
                            ),
                          )
                        : const Icon(Icons.send),
                    tooltip: 'Send',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.visibility_off,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Post anonymously',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Switch(
                    value: _isAnonymous,
                    onChanged: isAuthenticated
                        ? (value) {
                            setState(() {
                              _isAnonymous = value;
                            });
                          }
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.school,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'School',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedSchool?.isEmpty == true ? null : selectedSchool,
                      isDense: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 10.0,
                        ),
                      ),
                      hint: const Text('Select your school'),
                      items: BresciaSchools.schools.map((school) {
                        return DropdownMenuItem(
                          value: school,
                          child: Text(
                            school,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: isAuthenticated
                          ? (value) {
                              ref.read(selectedCommentSchoolProvider.notifier).state = value;
                            }
                          : null,
                    ),
                  ),
                ],
              ),
              if (!isAuthenticated) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Sign in to join the conversation.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => const Center(child: Text('Loading...')),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(24.0),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline),
            const SizedBox(height: 8),
            Text('Unable to load profile information: $error'),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentCooldownBanner(RateLimitStatus status, ThemeData theme, AppLocalizations? l10n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.timer_off, size: 18, color: theme.colorScheme.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              status.cooldownDuration != null
                  ? l10n?.cooldownTimer(status.cooldownDuration!.inSeconds) ?? 'Wait...'
                  : l10n?.rateLimitCommentsExceeded ?? 'Too many comments',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentWarningBanner(ThemeData theme, AppLocalizations? l10n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, size: 18, color: theme.colorScheme.onTertiaryContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n?.rateLimitNearLimitWarning ?? 'Nearing limit',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onTertiaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitComment() async {
    final content = _textController.text.trim();
    final school = ref.read(selectedCommentSchoolProvider);
    final authState = ref.read(authStateProvider);
    final userProfile = ref.read(userProfileProvider).value;
    final rateLimitService = ref.read(rateLimitServiceProvider);
    final analyticsService = ref.read(analyticsServiceProvider);

    if (content.isEmpty || school == null || school.isEmpty || authState.user == null || userProfile == null) {
      return;
    }

    final rateLimitStatus = rateLimitService.checkLimit(ContentType.comment);
    if (!rateLimitStatus.canSubmit) {
      await analyticsService.logRateLimitHit(
        contentType: 'comment',
        limitType: rateLimitStatus.reason ?? 'unknown',
        submissionCount: rateLimitService.getSubmissionCount(
          ContentType.comment,
          const Duration(hours: 1),
        ),
      );
      
      if (mounted) {
        RateLimitDialog.show(
          context,
          contentType: 'comment',
          cooldownDuration: rateLimitStatus.cooldownDuration,
        );
      }
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final notifier = ref.read(commentsProvider(widget.postId).notifier);
      await notifier.addComment(
        authorId: authState.user!.uid,
        authorNickname: userProfile.nickname,
        isAnonymous: _isAnonymous,
        content: content,
        school: school,
        replyToCommentId: widget.replyToCommentId,
      );

      rateLimitService.recordSubmission(ContentType.comment);
      
      await analyticsService.logContentSubmission(
        contentType: 'comment',
        isAnonymous: _isAnonymous,
      );

      if (!mounted) return;

      _textController.clear();
      widget.onCommentPosted?.call();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.replyToCommentId != null ? 'Reply posted!' : 'Comment posted!',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      
      final errorMessage = error.toString().toLowerCase();
      
      if (errorMessage.contains('rate') || 
          errorMessage.contains('limit') ||
          errorMessage.contains('too many')) {
        await analyticsService.logRateLimitHit(
          contentType: 'comment',
          limitType: 'backend',
          submissionCount: rateLimitService.getSubmissionCount(
            ContentType.comment,
            const Duration(hours: 1),
          ),
        );
        
        RateLimitDialog.show(
          context,
          contentType: 'comment',
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to post comment: $error'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
