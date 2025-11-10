import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

// Initialize Firebase Admin SDK
admin.initializeApp();

// Import function modules
export * from "./functions/nicknameValidation";
export * from "./functions/postCounters";
export * from "./functions/commentCounters";
export * from "./functions/moderationQueue";
export * from "./functions/pushNotifications";
export * from "./functions/dataCleanup";
export * from "./functions/extendedAnalytics";

// Health check function for emulator testing
export const healthCheck = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated"
    );
  }

  return {
    status: "healthy",
    timestamp: admin.firestore.Timestamp.now(),
    userId: context.auth.uid,
  };
});

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
      .collection("reports")
      .where("status", "==", "pending")
      .count()
      .get();

    const resolvedReports = await admin.firestore()
      .collection("reports")
      .where("status", "==", "resolved")
      .count()
      .get();

    const dismissedReports = await admin.firestore()
      .collection("reports")
      .where("status", "==", "dismissed")
      .count()
      .get();

    const flaggedPosts = await admin.firestore()
      .collection("posts")
      .where("isModerated", "==", true)
      .count()
      .get();

    const flaggedComments = await admin.firestore()
      .collection("comments")
      .where("isModerated", "==", true)
      .count()
      .get();

    return {
      activeReportCount: pendingReports.data().count || 0,
      resolvedReportCount: resolvedReports.data().count || 0,
      dismissedReportCount: dismissedReports.data().count || 0,
      flaggedPostCount: flaggedPosts.data().count || 0,
      flaggedCommentCount: flaggedComments.data().count || 0,
      userBanCount: 0,
    };
  } catch (error) {
    functions.logger.error("Error getting moderation stats:", error);
    throw new functions.https.HttpsError("internal", "Error fetching moderation stats");
  }
});
