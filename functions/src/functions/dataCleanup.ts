import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const db = admin.firestore();

/**
 * Scheduled function to clean up old notifications (runs daily)
 */
export const cleanupOldNotifications = functions.pubsub
  .schedule("0 2 * * *") // Run at 2 AM UTC daily
  .timeZone("UTC")
  .onRun(async (context) => {
    try {
      const thirtyDaysAgo = new Date();
      thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

      const snapshot = await db.collectionGroup("notifications")
        .where("createdAt", "<", admin.firestore.Timestamp.fromDate(thirtyDaysAgo))
        .get();

      const batch = db.batch();
      let count = 0;

      snapshot.docs.forEach((doc) => {
        batch.delete(doc.ref);
        count++;

        // Firestore batch write limit is 500
        if (count % 500 === 0) {
          batch.commit();
        }
      });

      // Commit remaining deletions
      await batch.commit();

      console.log(`Cleaned up ${count} old notifications`);

      return {status: "success", deletedCount: count};
    } catch (error) {
      console.error("Error cleaning up old notifications:", error);
      return {status: "error", error: String(error)};
    }
  });

/**
 * Scheduled function to clean up old moderation queue items (runs daily)
 */
export const cleanupOldModerationItems = functions.pubsub
  .schedule("0 3 * * *") // Run at 3 AM UTC daily
  .timeZone("UTC")
  .onRun(async (context) => {
    try {
      const ninetyDaysAgo = new Date();
      ninetyDaysAgo.setDate(ninetyDaysAgo.getDate() - 90);

      const snapshot = await db
        .collection("moderationQueue")
        .where("status", "==", "resolved")
        .where("resolvedAt", "<", admin.firestore.Timestamp.fromDate(ninetyDaysAgo))
        .get();

      const batch = db.batch();
      let count = 0;

      snapshot.docs.forEach((doc) => {
        batch.delete(doc.ref);
        count++;

        if (count % 500 === 0) {
          batch.commit();
        }
      });

      await batch.commit();

      console.log(`Cleaned up ${count} old moderation queue items`);

      return {status: "success", deletedCount: count};
    } catch (error) {
      console.error("Error cleaning up old moderation items:", error);
      return {status: "error", error: String(error)};
    }
  });

/**
 * Scheduled function to deactivate old temporary uploads (runs every 6 hours)
 */
export const cleanupTemporaryUploads = functions.pubsub
  .schedule("0 */6 * * *") // Run every 6 hours
  .timeZone("UTC")
  .onRun(async (context) => {
    try {
      const oneDayAgo = new Date();
      oneDayAgo.setDate(oneDayAgo.getDate() - 1);

      const snapshot = await db
        .collectionGroup("uploads")
        .where("createdAt", "<", admin.firestore.Timestamp.fromDate(oneDayAgo))
        .get();

      const batch = db.batch();
      let count = 0;

      snapshot.docs.forEach((doc) => {
        batch.delete(doc.ref);
        count++;

        if (count % 500 === 0) {
          batch.commit();
        }
      });

      await batch.commit();

      console.log(`Cleaned up ${count} temporary upload records`);

      return {status: "success", deletedCount: count};
    } catch (error) {
      console.error("Error cleaning up temporary uploads:", error);
      return {status: "error", error: String(error)};
    }
  });

/**
 * Triggered when a user is deleted to clean up associated data
 */
export const onUserDeleted = functions.auth
  .user()
  .onDelete(async (user) => {
    try {
      const userId = user.uid;

      // Delete user profile and all subcollections
      const userRef = db.collection("users").doc(userId);

      // Delete subcollections
      const subcollections = await userRef.listCollections();
      for (const subcoll of subcollections) {
        const docs = await subcoll.get();
        const batch = db.batch();

        docs.docs.forEach((doc) => {
          batch.delete(doc.ref);
        });

        await batch.commit();
      }

      // Delete user document
      await userRef.delete();

      // Delete user preferences and notifications (top-level collections)
      const prefDocs = await db
        .collection("users")
        .doc(userId)
        .collection("preferences")
        .get();
      const notifDocs = await db
        .collection("users")
        .doc(userId)
        .collection("notifications")
        .get();

      const batch = db.batch();

      prefDocs.docs.forEach((doc) => {
        batch.delete(doc.ref);
      });

      notifDocs.docs.forEach((doc) => {
        batch.delete(doc.ref);
      });

      await batch.commit();

      console.log(`Cleaned up data for deleted user: ${userId}`);
    } catch (error) {
      console.error("Error cleaning up deleted user data:", error);
    }
  });

/**
 * Scheduled function to generate usage statistics (runs weekly)
 */
export const generateUsageStatistics = functions.pubsub
  .schedule("0 4 * * 0") // Run at 4 AM UTC every Sunday
  .timeZone("UTC")
  .onRun(async (context) => {
    try {
      const stats: {[key: string]: number} = {};

      // Count active users
      const usersSnapshot = await db.collection("users").count().get();
      stats.totalUsers = usersSnapshot.data().count;

      // Count total posts
      const postsSnapshot = await db.collection("posts").count().get();
      stats.totalPosts = postsSnapshot.data().count;

      // Count pending reports
      const pendingReportsSnapshot = await db
        .collection("reportedPosts")
        .where("status", "==", "pending")
        .count()
        .get();
      stats.pendingReports = pendingReportsSnapshot.data().count;

      // Store statistics
      await db.collection("statistics").doc(`week_${new Date().toISOString().split("T")[0]}`)
        .set({
          ...stats,
          timestamp: admin.firestore.Timestamp.now(),
        });

      console.log("Generated usage statistics:", stats);

      return {status: "success", stats};
    } catch (error) {
      console.error("Error generating usage statistics:", error);
      return {status: "error", error: String(error)};
    }
  });
