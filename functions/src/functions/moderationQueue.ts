import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const db = admin.firestore();

/**
 * Processes reported posts and adds them to moderation queue
 * Triggered when new reports are created
 */
export const onReportCreated = functions.firestore
  .document("reportedPosts/{reportId}")
  .onCreate(async (snap, context) => {
    const reportData = snap.data();
    const reportId = context.params.reportId;

    try {
      // Add to moderation queue
      await db.collection("moderationQueue").doc(reportId).set({
        reportId,
        postId: reportData.postId,
        authorId: reportData.get("authorId"),
        reporterId: reportData.reporterId,
        reason: reportData.reason,
        description: reportData.get("description", ""),
        status: "pending",
        priority: calculatePriority(reportData.reason),
        createdAt: admin.firestore.Timestamp.now(),
        reportedAt: reportData.createdAt,
        resolvedAt: null,
      });

      // Increment report count for post (for admin dashboard)
      await db.collection("posts").doc(reportData.postId).update({
        reportCount: admin.firestore.FieldValue.increment(1),
      });
    } catch (error) {
      console.error("Error adding to moderation queue:", error);
    }
  });

/**
 * Processes moderation actions (approve/reject/delete)
 */
export const processModerationAction = functions.https.onCall(
  async (data, context) => {
    // Only admins can process moderation
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "User must be authenticated"
      );
    }

    const {reportId, action, reason: actionReason} = data;

    if (!reportId || !["approve", "reject", "delete"].includes(action)) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "reportId and valid action are required"
      );
    }

    try {
      const queueItemRef = db.collection("moderationQueue").doc(reportId);
      const queueItemDoc = await queueItemRef.get();

      if (!queueItemDoc.exists) {
        throw new functions.https.HttpsError(
          "not-found",
          "Moderation item not found"
        );
      }

      const queueItem = queueItemDoc.data()!;
      const postId = queueItem.postId;

      if (action === "approve") {
        // Delete the post and mark as removed
        await db.collection("posts").doc(postId).update({
          deleted: true,
          deletedReason: actionReason || "Flagged for content policy violation",
          deletedAt: admin.firestore.Timestamp.now(),
          flaggedAsInappropriate: true,
        });

        // Update report status
        await db.collection("reportedPosts").doc(reportId).update({
          status: "resolved",
          action: "post_removed",
          resolvedAt: admin.firestore.Timestamp.now(),
        });
      } else if (action === "reject") {
        // Dismiss the report
        await db.collection("reportedPosts").doc(reportId).update({
          status: "resolved",
          action: "dismissed",
          resolvedAt: admin.firestore.Timestamp.now(),
        });
      } else if (action === "delete") {
        // Delete both post and report
        await db.collection("posts").doc(postId).delete();
        await db.collection("reportedPosts").doc(reportId).delete();
      }

      // Update moderation queue item
      await queueItemRef.update({
        status: "resolved",
        action,
        resolvedAt: admin.firestore.Timestamp.now(),
        resolvedBy: context.auth!.uid,
      });

      return {
        success: true,
        message: `Report ${action}d successfully`,
      };
    } catch (error) {
      console.error("Error processing moderation action:", error);
      throw new functions.https.HttpsError(
        "internal",
        "Failed to process moderation action"
      );
    }
  }
);

/**
 * Retrieves pending moderation items
 */
export const getPendingModerations = functions.https.onCall(
  async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "User must be authenticated"
      );
    }

    const {limit = 20, offset = 0} = data;

    try {
      const snapshot = await db
        .collection("moderationQueue")
        .where("status", "==", "pending")
        .orderBy("priority", "desc")
        .orderBy("createdAt", "asc")
        .limit(limit)
        .offset(offset)
        .get();

      const items = snapshot.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
      }));

      return {
        items,
        count: items.length,
      };
    } catch (error) {
      console.error("Error retrieving pending moderations:", error);
      throw new functions.https.HttpsError(
        "internal",
        "Failed to retrieve moderation items"
      );
    }
  }
);

/**
 * Calculates priority based on report reason
 * @param {string} reason - The reason for the report
 * @return {number} Priority score (1-5)
 */
function calculatePriority(reason: string): number {
  const priorityMap: {[key: string]: number} = {
    violence: 5,
    harassment: 4,
    inappropriate_content: 3,
    spam: 2,
    other: 1,
  };

  return priorityMap[reason] || 1;
}
