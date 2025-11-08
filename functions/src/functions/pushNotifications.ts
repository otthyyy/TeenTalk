import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const db = admin.firestore();
const messaging = admin.messaging();

/**
 * Sends push notification when a user receives a comment on their post
 */
export const onCommentNotification = functions.firestore
  .document("posts/{postId}/comments/{commentId}")
  .onCreate(async (snap, context) => {
    const commentData = snap.data();
    const {postId} = context.params;

    try {
      // Get post details
      const postDoc = await db.collection("posts").doc(postId).get();
      if (!postDoc.exists) {
        return;
      }

      const postData = postDoc.data()!;
      const postAuthorId = postData.authorId;

      // Don't notify if commenting on own post
      if (commentData.authorId === postAuthorId) {
        return;
      }

      // Get commenter details
      const commenterDoc = await db
        .collection("users")
        .doc(commentData.authorId)
        .get();
      const commenterName = commenterDoc.data()?.displayName || "Someone";

      // Get post author's FCM tokens
      const userPrefsDoc = await db
        .collection("users")
        .doc(postAuthorId)
        .collection("preferences")
        .doc("notifications")
        .get();

      const prefs = userPrefsDoc.data() || {};

      // Check if notifications are enabled
      if (!prefs.commentsEnabled) {
        return;
      }

      // Get FCM tokens
      const userDoc = await db.collection("users").doc(postAuthorId).get();
      const userData = userDoc.data() || {};
      const fcmTokens = userData.fcmTokens || [];

      if (fcmTokens.length === 0) {
        return;
      }

      // Send notifications
      const notificationTitle = `${commenterName} commented on your post`;
      const notificationBody = commentData.content.substring(0, 100);

      const message: admin.messaging.MulticastMessage = {
        tokens: fcmTokens,
        notification: {
          title: notificationTitle,
          body: notificationBody,
        },
        data: {
          type: "comment",
          postId,
          commentId: context.params.commentId,
          commenterId: commentData.authorId,
        },
      };

      await messaging.sendMulticast(message);

      // Store notification in database
      await db
        .collection("users")
        .doc(postAuthorId)
        .collection("notifications")
        .add({
          type: "comment",
          title: notificationTitle,
          body: notificationBody,
          postId,
          commentId: context.params.commentId,
          commenterId: commentData.authorId,
          createdAt: admin.firestore.Timestamp.now(),
          read: false,
        });
    } catch (error) {
      console.error("Error sending comment notification:", error);
    }
  });

/**
 * Sends push notification when a user's post gets a like
 */
export const onPostLikeNotification = functions.firestore
  .document("posts/{postId}/likes/{userId}")
  .onCreate(async (snap, context) => {
    const {postId, userId} = context.params;

    try {
      // Get post details
      const postDoc = await db.collection("posts").doc(postId).get();
      if (!postDoc.exists) {
        return;
      }

      const postData = postDoc.data()!;
      const postAuthorId = postData.authorId;

      // Don't notify if user liked own post
      if (userId === postAuthorId) {
        return;
      }

      // Get user details
      const userDoc = await db.collection("users").doc(userId).get();
      const userName = userDoc.data()?.displayName || "Someone";

      // Get post author's FCM tokens
      const userPrefsDoc = await db
        .collection("users")
        .doc(postAuthorId)
        .collection("preferences")
        .doc("notifications")
        .get();

      const prefs = userPrefsDoc.data() || {};

      // Check if notifications are enabled
      if (!prefs.likesEnabled) {
        return;
      }

      const postAuthorDoc = await db
        .collection("users")
        .doc(postAuthorId)
        .get();
      const postAuthorData = postAuthorDoc.data() || {};
      const fcmTokens = postAuthorData.fcmTokens || [];

      if (fcmTokens.length === 0) {
        return;
      }

      // Send notifications
      const notificationTitle = `${userName} liked your post`;

      const message: admin.messaging.MulticastMessage = {
        tokens: fcmTokens,
        notification: {
          title: notificationTitle,
          body: "Tap to view",
        },
        data: {
          type: "like",
          postId,
          userId,
        },
      };

      await messaging.sendMulticast(message);

      // Store notification in database
      await db
        .collection("users")
        .doc(postAuthorId)
        .collection("notifications")
        .add({
          type: "like",
          title: notificationTitle,
          body: "Tap to view",
          postId,
          userId,
          createdAt: admin.firestore.Timestamp.now(),
          read: false,
        });
    } catch (error) {
      console.error("Error sending like notification:", error);
    }
  });

/**
 * Sends direct message notification
 */
export const onDirectMessageNotification = functions.firestore
  .document("directMessages/{conversationId}/messages/{messageId}")
  .onCreate(async (snap, context) => {
    const messageData = snap.data();
    const {conversationId} = context.params;

    try {
      // Get conversation details
      const conversationDoc = await db
        .collection("directMessages")
        .doc(conversationId)
        .get();
      if (!conversationDoc.exists) {
        return;
      }

      const conversationData = conversationDoc.data()!;
      const participants = conversationData.participantIds || [];

      // Find receiver
      const receiverId = participants.find(
        (id: string) => id !== messageData.senderId
      );
      if (!receiverId) {
        return;
      }

      // Get sender details
      const senderDoc = await db
        .collection("users")
        .doc(messageData.senderId)
        .get();
      const senderName = senderDoc.data()?.displayName || "Someone";

      // Get receiver's FCM tokens
      const receiverDoc = await db
        .collection("users")
        .doc(receiverId)
        .get();
      const receiverData = receiverDoc.data() || {};
      const fcmTokens = receiverData.fcmTokens || [];

      if (fcmTokens.length === 0) {
        return;
      }

      // Send notification
      const message: admin.messaging.MulticastMessage = {
        tokens: fcmTokens,
        notification: {
          title: senderName,
          body: messageData.content.substring(0, 100),
        },
        data: {
          type: "message",
          conversationId,
          messageId: context.params.messageId,
          senderId: messageData.senderId,
        },
      };

      await messaging.sendMulticast(message);
    } catch (error) {
      console.error("Error sending message notification:", error);
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
