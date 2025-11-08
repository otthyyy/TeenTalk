import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const db = admin.firestore();

/**
 * Maintains commentCount on posts
 * Triggered when comments are added/removed
 */
export const onCommentCreated = functions.firestore
  .document("posts/{postId}/comments/{commentId}")
  .onCreate(async (snap, context) => {
    const {postId} = context.params;

    try {
      await db.collection("posts").doc(postId).update({
        commentCount: admin.firestore.FieldValue.increment(1),
        updatedAt: admin.firestore.Timestamp.now(),
      });

      // Also update top-level comments collection if using for aggregation
      const commentData = snap.data();
      await db.collection("comments").doc(context.params.commentId).set({
        ...commentData,
        postId,
        createdAt: admin.firestore.Timestamp.now(),
      });
    } catch (error) {
      console.error("Error incrementing comment count:", error);
    }
  });

/**
 * Maintains commentCount on posts when comments are deleted
 */
export const onCommentDeleted = functions.firestore
  .document("posts/{postId}/comments/{commentId}")
  .onDelete(async (snap, context) => {
    const {postId, commentId} = context.params;

    try {
      await db.collection("posts").doc(postId).update({
        commentCount: admin.firestore.FieldValue.increment(-1),
        updatedAt: admin.firestore.Timestamp.now(),
      });

      // Delete from top-level comments collection
      await db.collection("comments").doc(commentId).delete();
    } catch (error) {
      console.error("Error decrementing comment count:", error);
    }
  });

/**
 * Maintains likeCount on posts
 * Triggered when users like posts
 */
export const onPostLikeAdded = functions.firestore
  .document("posts/{postId}/likes/{userId}")
  .onCreate(async (snap, context) => {
    const {postId} = context.params;

    try {
      await db.collection("posts").doc(postId).update({
        likeCount: admin.firestore.FieldValue.increment(1),
        updatedAt: admin.firestore.Timestamp.now(),
      });
    } catch (error) {
      console.error("Error incrementing like count:", error);
    }
  });

/**
 * Maintains likeCount on posts when likes are removed
 */
export const onPostLikeRemoved = functions.firestore
  .document("posts/{postId}/likes/{userId}")
  .onDelete(async (snap, context) => {
    const {postId} = context.params;

    try {
      await db.collection("posts").doc(postId).update({
        likeCount: admin.firestore.FieldValue.increment(-1),
        updatedAt: admin.firestore.Timestamp.now(),
      });
    } catch (error) {
      console.error("Error decrementing like count:", error);
    }
  });

/**
 * Synchronizes post counts from subcollections
 * Useful for maintenance and verification
 */
export const syncPostCounts = functions.https.onCall(
  async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "User must be authenticated"
      );
    }

    const {postId} = data;

    if (!postId) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "postId is required"
      );
    }

    try {
      const postRef = db.collection("posts").doc(postId);
      const postDoc = await postRef.get();

      if (!postDoc.exists) {
        throw new functions.https.HttpsError(
          "not-found",
          "Post not found"
        );
      }

      // Count comments
      const commentsSnapshot = await postRef
        .collection("comments")
        .count()
        .get();
      const commentCount = commentsSnapshot.data().count;

      // Count likes
      const likesSnapshot = await postRef
        .collection("likes")
        .count()
        .get();
      const likeCount = likesSnapshot.data().count;

      // Update post with correct counts
      await postRef.update({
        commentCount,
        likeCount,
        syncedAt: admin.firestore.Timestamp.now(),
      });

      return {
        success: true,
        commentCount,
        likeCount,
      };
    } catch (error) {
      console.error("Error syncing post counts:", error);
      throw new functions.https.HttpsError(
        "internal",
        "Failed to sync post counts"
      );
    }
  }
);
