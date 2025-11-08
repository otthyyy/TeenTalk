import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const db = admin.firestore();

/**
 * Maintains likeCount on comments
 * Triggered when users like comments
 */
export const onCommentLikeAdded = functions.firestore
  .document("posts/{postId}/comments/{commentId}/likes/{userId}")
  .onCreate(async (snap, context) => {
    const {postId, commentId} = context.params;

    try {
      // Update subcollection comment
      await db
        .collection("posts")
        .doc(postId)
        .collection("comments")
        .doc(commentId)
        .update({
          likeCount: admin.firestore.FieldValue.increment(1),
          updatedAt: admin.firestore.Timestamp.now(),
        });

      // Also update top-level comments collection if it exists
      const topLevelCommentRef = db.collection("comments").doc(commentId);
      const topLevelCommentDoc = await topLevelCommentRef.get();

      if (topLevelCommentDoc.exists) {
        await topLevelCommentRef.update({
          likeCount: admin.firestore.FieldValue.increment(1),
          updatedAt: admin.firestore.Timestamp.now(),
        });
      }
    } catch (error) {
      console.error("Error incrementing comment like count:", error);
    }
  });

/**
 * Maintains likeCount on comments when likes are removed
 */
export const onCommentLikeRemoved = functions.firestore
  .document("posts/{postId}/comments/{commentId}/likes/{userId}")
  .onDelete(async (snap, context) => {
    const {postId, commentId} = context.params;

    try {
      // Update subcollection comment
      await db
        .collection("posts")
        .doc(postId)
        .collection("comments")
        .doc(commentId)
        .update({
          likeCount: admin.firestore.FieldValue.increment(-1),
          updatedAt: admin.firestore.Timestamp.now(),
        });

      // Also update top-level comments collection if it exists
      const topLevelCommentRef = db.collection("comments").doc(commentId);
      const topLevelCommentDoc = await topLevelCommentRef.get();

      if (topLevelCommentDoc.exists) {
        await topLevelCommentRef.update({
          likeCount: admin.firestore.FieldValue.increment(-1),
          updatedAt: admin.firestore.Timestamp.now(),
        });
      }
    } catch (error) {
      console.error("Error decrementing comment like count:", error);
    }
  });

/**
 * Synchronizes comment counts from likes subcollections
 * Useful for maintenance and verification
 */
export const syncCommentCounts = functions.https.onCall(
  async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "User must be authenticated"
      );
    }

    const {postId, commentId} = data;

    if (!postId || !commentId) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "postId and commentId are required"
      );
    }

    try {
      const commentRef = db
        .collection("posts")
        .doc(postId)
        .collection("comments")
        .doc(commentId);

      const commentDoc = await commentRef.get();

      if (!commentDoc.exists) {
        throw new functions.https.HttpsError(
          "not-found",
          "Comment not found"
        );
      }

      // Count likes on comment
      const likesSnapshot = await commentRef
        .collection("likes")
        .count()
        .get();
      const likeCount = likesSnapshot.data().count;

      // Update comment with correct count
      await commentRef.update({
        likeCount,
        syncedAt: admin.firestore.Timestamp.now(),
      });

      // Also sync top-level comment if it exists
      const topLevelCommentRef = db.collection("comments").doc(commentId);
      const topLevelCommentDoc = await topLevelCommentRef.get();

      if (topLevelCommentDoc.exists) {
        await topLevelCommentRef.update({
          likeCount,
          syncedAt: admin.firestore.Timestamp.now(),
        });
      }

      return {
        success: true,
        likeCount,
      };
    } catch (error) {
      console.error("Error syncing comment counts:", error);
      throw new functions.https.HttpsError(
        "internal",
        "Failed to sync comment counts"
      );
    }
  }
);
