import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const db = admin.firestore();
const messaging = admin.messaging();

/**
 * Sends push notification when a user receives a comment on their post
 */
export const onCommentNotification = functions.firestore
  .document("comments/{commentId}")
  .onCreate(async (snap, context) => {
    const commentData = snap.data();
    const commentId = context.params.commentId;
    const postId = commentData.postId;
    const replyToCommentId = commentData.replyToCommentId;

    try {
      // Get post details
      const postDoc = await db.collection("posts").doc(postId).get();
      if (!postDoc.exists) {
        functions.logger.warn(`Post ${postId} not found for comment ${commentId}`);
        return;
      }

      const postData = postDoc.data()!;
      const postAuthorId = postData.authorId;

      // Get commenter details
      const commenterDoc = await db
        .collection("users")
        .doc(commentData.authorId)
        .get();
      const commenterName = commenterDoc.data()?.displayName || commenterDoc.data()?.nickname || "Someone";

      // Handle reply notification
      if (replyToCommentId) {
        const parentCommentDoc = await db.collection("comments").doc(replyToCommentId).get();
        if (parentCommentDoc.exists) {
          const parentCommentData = parentCommentDoc.data()!;
          const parentCommentAuthorId = parentCommentData.authorId;

          // Don't notify if replying to own comment
          if (commentData.authorId !== parentCommentAuthorId) {
            await sendNotification(
              parentCommentAuthorId,
              `${commenterName} replied to your comment`,
              commentData.content.substring(0, 100),
              "comment_reply",
              {
                postId,
                commentId,
                replyToCommentId,
                authorId: commentData.authorId,
              }
            );
          }
        }
      }

      // Notify post author (but not if they're commenting on their own post or already notified via reply)
      if (commentData.authorId !== postAuthorId && (!replyToCommentId || postAuthorId !== commentData.authorId)) {
        await sendNotification(
          postAuthorId,
          `${commenterName} commented on your post`,
          commentData.content.substring(0, 100),
          "comment",
          {
            postId,
            commentId,
            authorId: commentData.authorId,
          }
        );
      }

      // Handle mentions
      if (commentData.mentionedUserIds && Array.isArray(commentData.mentionedUserIds)) {
        for (const mentionedUserId of commentData.mentionedUserIds) {
          // Don't notify the commenter or if already notified
          if (mentionedUserId !== commentData.authorId && mentionedUserId !== postAuthorId) {
            await sendNotification(
              mentionedUserId,
              `${commenterName} mentioned you in a comment`,
              commentData.content.substring(0, 100),
              "comment_mention",
              {
                postId,
                commentId,
                authorId: commentData.authorId,
              }
            );
          }
        }
      }
    } catch (error) {
      functions.logger.error("Error sending comment notification:", error);
    }
  });

/**
 * Sends push notification when a user's post gets a like
 * Watches for changes in the likedBy array to detect new likes
 */
export const onPostLikeNotification = functions.firestore
  .document("posts/{postId}")
  .onUpdate(async (change, context) => {
    const {postId} = context.params;
    const beforeData = change.before.data();
    const afterData = change.after.data();

    try {
      const beforeLikedBy = beforeData.likedBy || [];
      const afterLikedBy = afterData.likedBy || [];

      // Detect new likes
      const newLikes = afterLikedBy.filter(
        (userId: string) => !beforeLikedBy.includes(userId)
      );

      if (newLikes.length === 0) {
        return;
      }

      const postAuthorId = afterData.authorId;

      // Process each new like
      for (const likerId of newLikes) {
        // Don't notify if user liked own post
        if (likerId === postAuthorId) {
          continue;
        }

        // Check for duplicate notification (prevent spam)
        const recentNotification = await db
          .collection("notifications")
          .where("userId", "==", postAuthorId)
          .where("type", "==", "like")
          .where("data.postId", "==", postId)
          .where("data.likerId", "==", likerId)
          .where("createdAt", ">=", new Date(Date.now() - 60000).toISOString()) // Last minute
          .limit(1)
          .get();

        if (!recentNotification.empty) {
          functions.logger.info(`Skipping duplicate like notification for post ${postId} by user ${likerId}`);
          continue;
        }

        // Get liker details
        const likerDoc = await db.collection("users").doc(likerId).get();
        const likerName = likerDoc.data()?.displayName || likerDoc.data()?.nickname || "Someone";

        await sendNotification(
          postAuthorId,
          `${likerName} liked your post`,
          "Tap to view",
          "like",
          {
            postId,
            likerId,
          }
        );
      }
    } catch (error) {
      functions.logger.error("Error sending like notification:", error);
    }
  });

/**
 * Sends direct message notification
 */
export const onDirectMessageNotification = functions.firestore
  .document("conversations/{conversationId}/messages/{messageId}")
  .onCreate(async (snap, context) => {
    const messageData = snap.data();
    const {conversationId, messageId} = context.params;

    try {
      // Get conversation details
      const conversationDoc = await db
        .collection("conversations")
        .doc(conversationId)
        .get();
      if (!conversationDoc.exists) {
        functions.logger.warn(`Conversation ${conversationId} not found for message ${messageId}`);
        return;
      }

      const conversationData = conversationDoc.data()!;
      const participants = conversationData.participantIds || [];

      // Find receiver(s)
      const recipientIds = participants.filter((id: string) => id !== messageData.senderId);
      if (recipientIds.length === 0) {
        functions.logger.warn(`No recipients found for message ${messageId} in conversation ${conversationId}`);
        return;
      }

      // Get sender details
      const senderDoc = await db
        .collection("users")
        .doc(messageData.senderId)
        .get();
      const senderName = senderDoc.data()?.displayName || senderDoc.data()?.nickname || "Someone";

      for (const recipientId of recipientIds) {
        await sendNotification(
          recipientId,
          senderName,
          messageData.content ? messageData.content.substring(0, 100) : "New message",
          "message",
          {
            conversationId,
            messageId,
            senderId: messageData.senderId,
          }
        );
      }
    } catch (error) {
      functions.logger.error("Error sending message notification:", error);
    }
  });

/**
 * Registers FCM token for push notifications
 */
export const registerFCMToken = functions.https.onCall(
  async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "User must be authenticated"
      );
    }

    const {token} = data;

    if (!token) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "FCM token is required"
      );
    }

    try {
      const userRef = db.collection("users").doc(context.auth.uid);
      const userDoc = await userRef.get();
      const userData = userDoc.data() || {};

      const tokens = userData.fcmTokens || [];

      // Add token if not already exists
      if (!tokens.includes(token)) {
        tokens.push(token);
      }

      await userRef.update({
        fcmTokens: tokens,
        lastFCMUpdate: admin.firestore.Timestamp.now(),
      });

      return {
        success: true,
        message: "FCM token registered",
      };
    } catch (error) {
      console.error("Error registering FCM token:", error);
      throw new functions.https.HttpsError(
        "internal",
        "Failed to register FCM token"
      );
    }
  }
);

/**
 * Unregisters FCM token
 */
export const unregisterFCMToken = functions.https.onCall(
  async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "User must be authenticated"
      );
    }

    const {token} = data;

    if (!token) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "FCM token is required"
      );
    }

    try {
      const userRef = db.collection("users").doc(context.auth.uid);
      const userDoc = await userRef.get();
      const userData = userDoc.data() || {};

      let tokens = userData.fcmTokens || [];
      tokens = tokens.filter((t: string) => t !== token);

      await userRef.update({
        fcmTokens: tokens,
      });

      return {
        success: true,
        message: "FCM token unregistered",
      };
    } catch (error) {
      console.error("Error unregistering FCM token:", error);
      throw new functions.https.HttpsError(
        "internal",
        "Failed to unregister FCM token"
      );
    }
  }
);

/**
 * Helper function to send notification to a user
 * Stores notification in Firestore and sends FCM push notification
 */
async function sendNotification(
  userId: string,
  title: string,
  body: string,
  type: string,
  data: Record<string, string>
): Promise<void> {
  try {
    // Store notification in top-level notifications collection
    await db.collection("notifications").add({
      userId,
      type,
      title,
      body,
      data,
      createdAt: new Date().toISOString(),
      read: false,
    });

    functions.logger.info(`Created notification for user ${userId}: ${type}`);

    // Get user's FCM tokens
    const userDoc = await db.collection("users").doc(userId).get();
    if (!userDoc.exists) {
      functions.logger.warn(`User ${userId} not found for notification`);
      return;
    }

    const userData = userDoc.data()!;
    let fcmTokens = userData.fcmTokens || [];

    if (fcmTokens.length === 0) {
      functions.logger.info(`User ${userId} has no FCM tokens registered`);
      return;
    }

    // Filter out duplicate tokens
    fcmTokens = Array.from(new Set(fcmTokens));

    // Prepare FCM messages
    const messages = fcmTokens.map((token: string) => ({
      token,
      notification: {
        title,
        body,
      },
      data: {
        type,
        ...data,
      },
      android: {
        priority: "high" as const,
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
            badge: 1,
          },
        },
      },
    }));

    // Send messages and handle failures
    const response = await messaging.sendEach(messages);

    functions.logger.info(
      `Sent ${response.successCount} notifications to user ${userId}, ${response.failureCount} failed`
    );

    // Remove invalid tokens
    const invalidTokens: string[] = [];
    response.responses.forEach((resp, idx) => {
      if (!resp.success) {
        const error = resp.error;
        functions.logger.error(`Failed to send to token ${idx}:`, error);

        // Check for invalid token errors
        if (
          error?.code === "messaging/invalid-registration-token" ||
          error?.code === "messaging/registration-token-not-registered"
        ) {
          invalidTokens.push(fcmTokens[idx]);
        }
      }
    });

    // Clean up invalid tokens
    if (invalidTokens.length > 0) {
      const updatedTokens = fcmTokens.filter(
        (token: string) => !invalidTokens.includes(token)
      );
      await db.collection("users").doc(userId).update({
        fcmTokens: updatedTokens,
      });
      functions.logger.info(
        `Removed ${invalidTokens.length} invalid tokens for user ${userId}`
      );
    }
  } catch (error) {
    functions.logger.error(
      `Error sending notification to user ${userId}:`,
      error
    );
  }
}
