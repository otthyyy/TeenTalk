import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

const REPORT_THRESHOLD = 3;

/**
 * Cloud Function triggered when a new report is created
 * Checks if content should be auto-hidden based on report count
 */
export const onReportCreated = functions.firestore
  .document("reportedContent/{reportId}")
  .onCreate(async (snap, context) => {
    const report = snap.data();
    const {contentId, contentType, contentAuthorId, reason} = report;

    functions.logger.info(
      `New report created for ${contentType}: ${contentId}`,
      {reportId: context.params.reportId, reason}
    );

    try {
      const moderationRef = admin.firestore()
        .collection("moderationQueue")
        .doc(contentId);
      const moderationDoc = await moderationRef.get();

      if (moderationDoc.exists) {
        const currentReportCount = moderationDoc.data()?.reportCount || 0;
        const newReportCount = currentReportCount + 1;

        functions.logger.info(
          `Updating report count for ${contentId}: ${currentReportCount} -> ${newReportCount}`
        );

        if (newReportCount >= REPORT_THRESHOLD) {
          await moderationRef.update({
            reportCount: admin.firestore.FieldValue.increment(1),
            status: "hidden",
            hiddenAt: admin.firestore.FieldValue.serverTimestamp(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          });

          await createAuditLog(contentId, contentAuthorId, "post_hidden", null, reason);

          functions.logger.info(
            `Content ${contentId} auto-hidden after reaching ${newReportCount} reports`
          );
        } else {
          await moderationRef.update({
            reportCount: admin.firestore.FieldValue.increment(1),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          });
        }
      } else {
        const shouldHide = 1 >= REPORT_THRESHOLD;
        await moderationRef.set({
          contentType,
          authorId: contentAuthorId,
          reportCount: 1,
          status: shouldHide ? "hidden" : "active",
          hiddenAt: shouldHide ? admin.firestore.FieldValue.serverTimestamp() : null,
          isAnonymous: false,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        if (shouldHide) {
          await createAuditLog(contentId, contentAuthorId, "post_hidden", null, reason);
        }
      }

      await createAuditLog(contentId, contentAuthorId, "post_reported", report.reporterId, reason);
    } catch (error) {
      functions.logger.error("Error processing report:", error);
      throw error;
    }
  });

/**
 * Cloud Function triggered when a post is created
 * Creates audit log for anonymous posts
 */
export const onPostCreated = functions.firestore
  .document("posts/{postId}")
  .onCreate(async (snap, context) => {
    const post = snap.data();
    const postId = context.params.postId;
    const {authorId, isAnonymous} = post;

    if (isAnonymous) {
      functions.logger.info(
        `Creating audit log for anonymous post: ${postId}`,
        {authorId}
      );

      try {
        await createAuditLog(postId, authorId, "post_created", authorId, "Anonymous post created");
      } catch (error) {
        functions.logger.error("Error creating audit log:", error);
      }
    }
  });

/**
 * Helper function to create audit logs
 */
async function createAuditLog(
  contentId: string,
  originalAuthorId: string,
  action: string,
  performedBy: string | null,
  reason: string
): Promise<void> {
  try {
    await admin.firestore()
      .collection("moderationQueue")
      .doc(contentId)
      .collection("auditLogs")
      .add({
        contentId,
        originalAuthorId,
        action,
        performedBy,
        reason,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
      });

    functions.logger.info(
      `Audit log created: ${action} for content ${contentId}`
    );
  } catch (error) {
    functions.logger.error("Error creating audit log:", error);
    throw error;
  }
}

/**
 * Scheduled function to clean up old resolved reports
 * Runs daily at midnight
 */
export const cleanupOldReports = functions.pubsub
  .schedule("0 0 * * *")
  .timeZone("UTC")
  .onRun(async (context) => {
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    functions.logger.info("Starting cleanup of old resolved reports");

    try {
      const snapshot = await admin.firestore()
        .collection("reportedContent")
        .where("status", "in", ["resolved", "dismissed"])
        .where("resolvedAt", "<=", admin.firestore.Timestamp.fromDate(thirtyDaysAgo))
        .get();

      if (snapshot.empty) {
        functions.logger.info("No old reports to clean up");
        return;
      }

      const batch = admin.firestore().batch();
      snapshot.docs.forEach((doc) => {
        batch.delete(doc.ref);
      });

      await batch.commit();

      functions.logger.info(`Cleaned up ${snapshot.size} old resolved reports`);
    } catch (error) {
      functions.logger.error("Error cleaning up old reports:", error);
      throw error;
    }
  });

/**
 * Callable function for admins to get moderation stats
 */
export const getModerationStats = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Must be authenticated to get moderation stats"
    );
  }

  const userId = context.auth.uid;
  const userDoc = await admin.firestore().collection("users").doc(userId).get();

  if (!userDoc.exists || (!userDoc.data()?.isAdmin && !userDoc.data()?.isModerator)) {
    throw new functions.https.HttpsError(
      "permission-denied",
      "Must be an admin or moderator to get moderation stats"
    );
  }

  try {
    const pendingReports = await admin.firestore()
      .collection("reportedContent")
      .where("status", "==", "pending")
      .count()
      .get();

    const hiddenContent = await admin.firestore()
      .collection("moderationQueue")
      .where("status", "==", "hidden")
      .count()
      .get();

    const removedContent = await admin.firestore()
      .collection("moderationQueue")
      .where("status", "==", "removed")
      .count()
      .get();

    return {
      pendingReports: pendingReports.data().count,
      hiddenContent: hiddenContent.data().count,
      removedContent: removedContent.data().count,
      reportThreshold: REPORT_THRESHOLD,
    };
  } catch (error) {
    functions.logger.error("Error getting moderation stats:", error);
    throw new functions.https.HttpsError("internal", "Error fetching moderation stats");
  }
});
