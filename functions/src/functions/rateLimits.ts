import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const db = admin.firestore();

// Rate limit configuration
const RATE_LIMITS = {
  POSTS_PER_DAY: 50,
  COMMENTS_PER_HOUR: 30,
  MESSAGES_PER_HOUR: 100,
  
  // Trust score thresholds
  LOW_TRUST_THRESHOLD: 0.3,
  REPEATED_VIOLATION_COUNT: 3,
};

// Error codes for client
export const RATE_LIMIT_ERROR_CODES = {
  POSTS_EXCEEDED: "rate-limit-exceeded-posts",
  COMMENTS_EXCEEDED: "rate-limit-exceeded-comments",
  MESSAGES_EXCEEDED: "rate-limit-exceeded-messages",
};

interface RateLimitData {
  userId: string;
  postsToday: number;
  commentsThisHour: number;
  messagesThisHour: number;
  resetPostsAt: admin.firestore.Timestamp;
  resetCommentsAt: admin.firestore.Timestamp;
  resetMessagesAt: admin.firestore.Timestamp;
  violationCount?: number;
  lastViolationAt?: admin.firestore.Timestamp;
  trustScore?: number;
  updatedAt: admin.firestore.Timestamp;
}

/**
 * Helper function to get or create rate limit document
 */
async function getRateLimitDoc(userId: string): Promise<admin.firestore.DocumentSnapshot> {
  const docRef = db.collection("rateLimits").doc(userId);
  const doc = await docRef.get();

  if (!doc.exists) {
    const now = new Date();
    const nextMidnight = new Date(now);
    nextMidnight.setHours(24, 0, 0, 0);
    const nextHour = new Date(now);
    nextHour.setMinutes(60, 0, 0);

    const initialData: RateLimitData = {
      userId,
      postsToday: 0,
      commentsThisHour: 0,
      messagesThisHour: 0,
      resetPostsAt: admin.firestore.Timestamp.fromDate(nextMidnight),
      resetCommentsAt: admin.firestore.Timestamp.fromDate(nextHour),
      resetMessagesAt: admin.firestore.Timestamp.fromDate(nextHour),
      violationCount: 0,
      trustScore: 1.0,
      updatedAt: admin.firestore.Timestamp.now(),
    };

    await docRef.set(initialData);
    return docRef.get();
  }

  return doc;
}

/**
 * Helper function to reset counters if time window has passed
 */
function shouldResetCounter(
  resetAt: admin.firestore.Timestamp,
  currentTime: Date
): boolean {
  return resetAt.toDate() <= currentTime;
}

/**
 * Callable function to check rate limit before creating content
 */
export const checkRateLimit = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated"
    );
  }

  const {contentType} = data;
  const userId = context.auth.uid;

  if (!contentType || !["post", "comment", "message"].includes(contentType)) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Valid contentType is required (post, comment, or message)"
    );
  }

  try {
    const doc = await getRateLimitDoc(userId);
    const rateLimitData = doc.data() as RateLimitData;
    const now = new Date();

    let canCreate = true;
    let currentCount = 0;
    let limit = 0;
    let resetAt = null;
    let errorCode = "";

    switch (contentType) {
    case "post":
      if (shouldResetCounter(rateLimitData.resetPostsAt, now)) {
        // Counter expired, reset it
        currentCount = 0;
      } else {
        currentCount = rateLimitData.postsToday;
      }
      limit = RATE_LIMITS.POSTS_PER_DAY;
      resetAt = rateLimitData.resetPostsAt;
      canCreate = currentCount < limit;
      errorCode = RATE_LIMIT_ERROR_CODES.POSTS_EXCEEDED;
      break;

    case "comment":
      if (shouldResetCounter(rateLimitData.resetCommentsAt, now)) {
        currentCount = 0;
      } else {
        currentCount = rateLimitData.commentsThisHour;
      }
      limit = RATE_LIMITS.COMMENTS_PER_HOUR;
      resetAt = rateLimitData.resetCommentsAt;
      canCreate = currentCount < limit;
      errorCode = RATE_LIMIT_ERROR_CODES.COMMENTS_EXCEEDED;
      break;

    case "message":
      if (shouldResetCounter(rateLimitData.resetMessagesAt, now)) {
        currentCount = 0;
      } else {
        currentCount = rateLimitData.messagesThisHour;
      }
      limit = RATE_LIMITS.MESSAGES_PER_HOUR;
      resetAt = rateLimitData.resetMessagesAt;
      canCreate = currentCount < limit;
      errorCode = RATE_LIMIT_ERROR_CODES.MESSAGES_EXCEEDED;
      break;
    }

    if (!canCreate) {
      return {
        allowed: false,
        errorCode,
        currentCount,
        limit,
        resetAt: resetAt?.toDate().toISOString(),
        trustScore: rateLimitData.trustScore || 1.0,
      };
    }

    return {
      allowed: true,
      currentCount,
      limit,
      resetAt: resetAt?.toDate().toISOString(),
      trustScore: rateLimitData.trustScore || 1.0,
    };
  } catch (error) {
    functions.logger.error("Error checking rate limit:", error);
    throw new functions.https.HttpsError("internal", "Failed to check rate limit");
  }
});

/**
 * Firestore trigger to track post creation and enforce rate limits
 */
export const onPostCreatedRateLimit = functions.firestore
  .document("posts/{postId}")
  .onCreate(async (snap, context) => {
    const post = snap.data();
    const userId = post.authorId;

    try {
      const docRef = db.collection("rateLimits").doc(userId);
      const doc = await getRateLimitDoc(userId);
      const rateLimitData = doc.data() as RateLimitData;
      const now = new Date();

      if (shouldResetCounter(rateLimitData.resetPostsAt, now)) {
        // Reset counter and timestamp
        const nextMidnight = new Date(now);
        nextMidnight.setHours(24, 0, 0, 0);

        await docRef.update({
          postsToday: 1,
          resetPostsAt: admin.firestore.Timestamp.fromDate(nextMidnight),
          updatedAt: admin.firestore.Timestamp.now(),
        });
      } else {
        const newCount = rateLimitData.postsToday + 1;

        // Check if user exceeded limit
        if (newCount > RATE_LIMITS.POSTS_PER_DAY) {
          await handleRateLimitViolation(userId, "post", docRef);
        }

        await docRef.update({
          postsToday: admin.firestore.FieldValue.increment(1),
          updatedAt: admin.firestore.Timestamp.now(),
        });
      }
    } catch (error) {
      functions.logger.error("Error tracking post rate limit:", error);
    }
  });

/**
 * Firestore trigger to track comment creation and enforce rate limits
 */
export const onCommentCreatedRateLimit = functions.firestore
  .document("comments/{commentId}")
  .onCreate(async (snap, context) => {
    const comment = snap.data();
    const userId = comment.authorId;

    try {
      const docRef = db.collection("rateLimits").doc(userId);
      const doc = await getRateLimitDoc(userId);
      const rateLimitData = doc.data() as RateLimitData;
      const now = new Date();

      if (shouldResetCounter(rateLimitData.resetCommentsAt, now)) {
        const nextHour = new Date(now);
        nextHour.setMinutes(60, 0, 0);

        await docRef.update({
          commentsThisHour: 1,
          resetCommentsAt: admin.firestore.Timestamp.fromDate(nextHour),
          updatedAt: admin.firestore.Timestamp.now(),
        });
      } else {
        const newCount = rateLimitData.commentsThisHour + 1;

        if (newCount > RATE_LIMITS.COMMENTS_PER_HOUR) {
          await handleRateLimitViolation(userId, "comment", docRef);
        }

        await docRef.update({
          commentsThisHour: admin.firestore.FieldValue.increment(1),
          updatedAt: admin.firestore.Timestamp.now(),
        });
      }
    } catch (error) {
      functions.logger.error("Error tracking comment rate limit:", error);
    }
  });

/**
 * Firestore trigger to track message creation and enforce rate limits
 */
export const onMessageCreatedRateLimit = functions.firestore
  .document("conversations/{conversationId}/messages/{messageId}")
  .onCreate(async (snap, context) => {
    const message = snap.data();
    const userId = message.senderId;

    try {
      const docRef = db.collection("rateLimits").doc(userId);
      const doc = await getRateLimitDoc(userId);
      const rateLimitData = doc.data() as RateLimitData;
      const now = new Date();

      if (shouldResetCounter(rateLimitData.resetMessagesAt, now)) {
        const nextHour = new Date(now);
        nextHour.setMinutes(60, 0, 0);

        await docRef.update({
          messagesThisHour: 1,
          resetMessagesAt: admin.firestore.Timestamp.fromDate(nextHour),
          updatedAt: admin.firestore.Timestamp.now(),
        });
      } else {
        const newCount = rateLimitData.messagesThisHour + 1;

        if (newCount > RATE_LIMITS.MESSAGES_PER_HOUR) {
          await handleRateLimitViolation(userId, "message", docRef);
        }

        await docRef.update({
          messagesThisHour: admin.firestore.FieldValue.increment(1),
          updatedAt: admin.firestore.Timestamp.now(),
        });
      }
    } catch (error) {
      functions.logger.error("Error tracking message rate limit:", error);
    }
  });

/**
 * Handle rate limit violations and update user trust score
 */
async function handleRateLimitViolation(
  userId: string,
  contentType: string,
  rateLimitDocRef: admin.firestore.DocumentReference
): Promise<void> {
  try {
    const doc = await rateLimitDocRef.get();
    const data = doc.data() as RateLimitData;
    const violationCount = (data.violationCount || 0) + 1;
    const currentTrustScore = data.trustScore || 1.0;

    // Decrease trust score with each violation
    const newTrustScore = Math.max(0, currentTrustScore - 0.1);

    await rateLimitDocRef.update({
      violationCount: admin.firestore.FieldValue.increment(1),
      lastViolationAt: admin.firestore.Timestamp.now(),
      trustScore: newTrustScore,
    });

    functions.logger.warn(
      `Rate limit violation for user ${userId} (${contentType}). ` +
      `Violation count: ${violationCount}, Trust score: ${newTrustScore}`
    );

    // Flag user if trust score is low or repeated violations
    if (
      newTrustScore <= RATE_LIMITS.LOW_TRUST_THRESHOLD ||
      violationCount >= RATE_LIMITS.REPEATED_VIOLATION_COUNT
    ) {
      await flagUserForModeration(userId, violationCount, newTrustScore);
    }
  } catch (error) {
    functions.logger.error("Error handling rate limit violation:", error);
  }
}

/**
 * Flag user in moderation system for repeated rate limit violations
 */
async function flagUserForModeration(
  userId: string,
  violationCount: number,
  trustScore: number
): Promise<void> {
  try {
    // Create or update user moderation flag
    const userRef = db.collection("users").doc(userId);
    await userRef.update({
      flaggedForReview: true,
      flagReason: "repeated_rate_limit_violations",
      violationCount,
      trustScore,
      flaggedAt: admin.firestore.Timestamp.now(),
    });

    // Create moderation queue item for admin review
    await db.collection("moderationQueue").doc(`user_${userId}`).set({
      contentId: userId,
      contentType: "user",
      authorId: userId,
      reportCount: violationCount,
      status: "flagged",
      reason: "Repeated rate limit violations",
      trustScore,
      isAnonymous: false,
      createdAt: admin.firestore.Timestamp.now(),
      updatedAt: admin.firestore.Timestamp.now(),
    });

    functions.logger.info(
      `User ${userId} flagged for moderation. ` +
      `Violations: ${violationCount}, Trust score: ${trustScore}`
    );
  } catch (error) {
    functions.logger.error("Error flagging user for moderation:", error);
  }
}

/**
 * Callable function to get rate limit status for current user
 */
export const getRateLimitStatus = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated"
    );
  }

  const userId = context.auth.uid;

  try {
    const doc = await getRateLimitDoc(userId);
    const rateLimitData = doc.data() as RateLimitData;
    const now = new Date();

    return {
      posts: {
        count: shouldResetCounter(rateLimitData.resetPostsAt, now) ?
          0 : rateLimitData.postsToday,
        limit: RATE_LIMITS.POSTS_PER_DAY,
        resetAt: rateLimitData.resetPostsAt.toDate().toISOString(),
      },
      comments: {
        count: shouldResetCounter(rateLimitData.resetCommentsAt, now) ?
          0 : rateLimitData.commentsThisHour,
        limit: RATE_LIMITS.COMMENTS_PER_HOUR,
        resetAt: rateLimitData.resetCommentsAt.toDate().toISOString(),
      },
      messages: {
        count: shouldResetCounter(rateLimitData.resetMessagesAt, now) ?
          0 : rateLimitData.messagesThisHour,
        limit: RATE_LIMITS.MESSAGES_PER_HOUR,
        resetAt: rateLimitData.resetMessagesAt.toDate().toISOString(),
      },
      trustScore: rateLimitData.trustScore || 1.0,
      violationCount: rateLimitData.violationCount || 0,
    };
  } catch (error) {
    functions.logger.error("Error getting rate limit status:", error);
    throw new functions.https.HttpsError("internal", "Failed to get rate limit status");
  }
});

/**
 * Admin callable function to get rate limit metrics
 */
export const getRateLimitMetrics = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated"
    );
  }

  const userId = context.auth.uid;
  const userDoc = await db.collection("users").doc(userId).get();

  if (!userDoc.exists || (!userDoc.data()?.isAdmin && !userDoc.data()?.isModerator)) {
    throw new functions.https.HttpsError(
      "permission-denied",
      "Must be an admin or moderator to get rate limit metrics"
    );
  }

  try {
    // Get all rate limit documents
    const snapshot = await db.collection("rateLimits").get();

    let totalViolations = 0;
    let lowTrustUsers = 0;
    let flaggedUsers = 0;

    snapshot.docs.forEach((doc) => {
      const data = doc.data() as RateLimitData;
      totalViolations += data.violationCount || 0;
      if ((data.trustScore || 1.0) <= RATE_LIMITS.LOW_TRUST_THRESHOLD) {
        lowTrustUsers++;
      }
    });

    // Count flagged users
    const flaggedSnapshot = await db
      .collection("moderationQueue")
      .where("contentType", "==", "user")
      .where("status", "==", "flagged")
      .get();
    flaggedUsers = flaggedSnapshot.size;

    return {
      totalUsers: snapshot.size,
      totalViolations,
      lowTrustUsers,
      flaggedUsers,
      limits: {
        postsPerDay: RATE_LIMITS.POSTS_PER_DAY,
        commentsPerHour: RATE_LIMITS.COMMENTS_PER_HOUR,
        messagesPerHour: RATE_LIMITS.MESSAGES_PER_HOUR,
      },
    };
  } catch (error) {
    functions.logger.error("Error getting rate limit metrics:", error);
    throw new functions.https.HttpsError("internal", "Failed to get rate limit metrics");
  }
});

/**
 * Admin callable function to reset rate limits for a user
 */
export const resetUserRateLimits = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated"
    );
  }

  const adminId = context.auth.uid;
  const {targetUserId} = data;

  if (!targetUserId) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "targetUserId is required"
    );
  }

  const userDoc = await db.collection("users").doc(adminId).get();

  if (!userDoc.exists || !userDoc.data()?.isAdmin) {
    throw new functions.https.HttpsError(
      "permission-denied",
      "Must be an admin to reset rate limits"
    );
  }

  try {
    const now = new Date();
    const nextMidnight = new Date(now);
    nextMidnight.setHours(24, 0, 0, 0);
    const nextHour = new Date(now);
    nextHour.setMinutes(60, 0, 0);

    await db.collection("rateLimits").doc(targetUserId).update({
      postsToday: 0,
      commentsThisHour: 0,
      messagesThisHour: 0,
      resetPostsAt: admin.firestore.Timestamp.fromDate(nextMidnight),
      resetCommentsAt: admin.firestore.Timestamp.fromDate(nextHour),
      resetMessagesAt: admin.firestore.Timestamp.fromDate(nextHour),
      violationCount: 0,
      trustScore: 1.0,
      updatedAt: admin.firestore.Timestamp.now(),
      resetBy: adminId,
      resetAt: admin.firestore.Timestamp.now(),
    });

    // Remove moderation flag
    await db.collection("users").doc(targetUserId).update({
      flaggedForReview: false,
      flagReason: null,
      flaggedAt: null,
    });

    functions.logger.info(`Rate limits reset for user ${targetUserId} by admin ${adminId}`);

    return {
      success: true,
      message: "Rate limits reset successfully",
    };
  } catch (error) {
    functions.logger.error("Error resetting rate limits:", error);
    throw new functions.https.HttpsError("internal", "Failed to reset rate limits");
  }
});
