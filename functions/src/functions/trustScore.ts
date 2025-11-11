import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const db = admin.firestore();

/**
 * Trust Score Configuration
 * Score ranges from 0-100
 */
export const TRUST_SCORE_CONFIG = {
  // Initial score for new users
  INITIAL_SCORE: 50,
  
  // Score boundaries for trust levels
  NEWCOMER_MAX: 40,
  MEMBER_MAX: 65,
  TRUSTED_MAX: 85,
  // 86-100 is VETERAN
  
  // Score changes for various actions
  POST_APPROVED: 2,
  POST_FLAGGED: -5,
  POST_REMOVED: -10,
  COMMENT_CREATED: 1,
  REPORT_UPHELD_REPORTER: 3, // Reward for valid reports
  REPORT_UPHELD_AUTHOR: -8, // Penalty for author of flagged content
  REPORT_DISMISSED_REPORTER: -2, // Penalty for false reports
  POSITIVE_ENGAGEMENT: 1, // Likes, helpful reactions
  BLOCKED_BY_USER: -1, // When someone blocks this user
  
  // Limits
  MIN_SCORE: 0,
  MAX_SCORE: 100,
};

/**
 * Calculate trust level based on score
 */
export function calculateTrustLevel(score: number): string {
  if (score <= TRUST_SCORE_CONFIG.NEWCOMER_MAX) {
    return "newcomer";
  } else if (score <= TRUST_SCORE_CONFIG.MEMBER_MAX) {
    return "member";
  } else if (score <= TRUST_SCORE_CONFIG.TRUSTED_MAX) {
    return "trusted";
  } else {
    return "veteran";
  }
}

/**
 * Clamp score to valid range (0-100)
 */
export function clampScore(score: number): number {
  return Math.max(
    TRUST_SCORE_CONFIG.MIN_SCORE,
    Math.min(TRUST_SCORE_CONFIG.MAX_SCORE, score)
  );
}

/**
 * Compute the resulting trust score/level after applying a delta
 */
export function applyTrustScoreDelta(
  currentScore: number,
  scoreDelta: number
): {
  newScore: number;
  previousScore: number;
  previousLevel: string;
  newLevel: string;
  appliedDelta: number;
} {
  const previousLevel = calculateTrustLevel(currentScore);
  const newScore = clampScore(currentScore + scoreDelta);
  const newLevel = calculateTrustLevel(newScore);

  return {
    newScore,
    previousScore: currentScore,
    previousLevel,
    newLevel,
    appliedDelta: scoreDelta,
  };
}

/**
 * Update user's trust score and level
 */
export async function updateTrustScore(
  userId: string,
  scoreDelta: number,
  reason: string,
  metadata?: Record<string, any>
): Promise<void> {
  const userRef = db.collection("users").doc(userId);
  
  try {
    await db.runTransaction(async (transaction) => {
      const userDoc = await transaction.get(userRef);
      
      if (!userDoc.exists) {
        functions.logger.warn(`User ${userId} not found for trust score update`);
        return;
      }
      
      const userData = userDoc.data()!;
      const currentScore = userData.trustScore || TRUST_SCORE_CONFIG.INITIAL_SCORE;
      const newScore = clampScore(currentScore + scoreDelta);
      const newLevel = calculateTrustLevel(newScore);
      
      // Update user document
      transaction.update(userRef, {
        trustScore: newScore,
        trustLevel: newLevel,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      
      // Log the trust score change
      const historyRef = userRef.collection("trustHistory").doc();
      transaction.set(historyRef, {
        previousScore: currentScore,
        newScore: newScore,
        scoreDelta: scoreDelta,
        previousLevel: userData.trustLevel || "newcomer",
        newLevel: newLevel,
        reason: reason,
        metadata: metadata || {},
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
      });
      
      functions.logger.info(
        `Updated trust score for user ${userId}: ${currentScore} -> ${newScore} (${reason})`
      );
    });
  } catch (error) {
    functions.logger.error(`Error updating trust score for user ${userId}:`, error);
    throw error;
  }
}

/**
 * Initialize trust score for new users
 */
export const onUserCreated = functions.firestore
  .document("users/{userId}")
  .onCreate(async (snap, context) => {
    const userId = context.params.userId;
    const userData = snap.data();
    
    // Only initialize if trustScore is not already set
    if (userData.trustScore === undefined || userData.trustScore === null) {
      try {
        await snap.ref.update({
          trustScore: TRUST_SCORE_CONFIG.INITIAL_SCORE,
          trustLevel: "newcomer",
        });
        
        // Create initial history entry
        await snap.ref.collection("trustHistory").add({
          previousScore: 0,
          newScore: TRUST_SCORE_CONFIG.INITIAL_SCORE,
          scoreDelta: TRUST_SCORE_CONFIG.INITIAL_SCORE,
          previousLevel: "newcomer",
          newLevel: "newcomer",
          reason: "account_created",
          metadata: {},
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
        });
        
        functions.logger.info(`Initialized trust score for user ${userId}`);
      } catch (error) {
        functions.logger.error(`Error initializing trust score for user ${userId}:`, error);
      }
    }
  });

/**
 * Update trust score when a post is created and approved
 */
export const onPostCreatedForTrust = functions.firestore
  .document("posts/{postId}")
  .onCreate(async (snap, context) => {
    const postData = snap.data();
    const postId = context.params.postId;
    const authorId = postData.authorId;
    
    // Award points for creating a post (will be adjusted if flagged)
    try {
      await updateTrustScore(
        authorId,
        TRUST_SCORE_CONFIG.POST_APPROVED,
        "post_created",
        {postId}
      );
    } catch (error) {
      functions.logger.error(`Error updating trust score for post creation ${postId}:`, error);
    }
  });

/**
 * Update trust score when a comment is created
 */
export const onCommentCreatedForTrust = functions.firestore
  .document("comments/{commentId}")
  .onCreate(async (snap, context) => {
    const commentData = snap.data();
    const commentId = context.params.commentId;
    const authorId = commentData.authorId;
    
    // Award small points for helpful engagement
    try {
      await updateTrustScore(
        authorId,
        TRUST_SCORE_CONFIG.COMMENT_CREATED,
        "comment_created",
        {commentId, postId: commentData.postId}
      );
    } catch (error) {
      functions.logger.error(`Error updating trust score for comment creation ${commentId}:`, error);
    }
  });

/**
 * Update trust score when a post is flagged or removed
 */
export const onPostModerated = functions.firestore
  .document("moderationQueue/{contentId}")
  .onUpdate(async (change, context) => {
    const beforeData = change.before.data();
    const afterData = change.after.data();
    const contentId = context.params.contentId;
    
    // Check if status changed to hidden or content was removed
    if (beforeData.status !== "hidden" && afterData.status === "hidden") {
      const authorId = afterData.authorId;
      
      try {
        await updateTrustScore(
          authorId,
          TRUST_SCORE_CONFIG.POST_FLAGGED,
          "post_auto_hidden",
          {contentId, reportCount: afterData.reportCount}
        );
      } catch (error) {
        functions.logger.error(`Error updating trust score for hidden content ${contentId}:`, error);
      }
    }
  });

/**
 * Update trust score when a report is resolved
 */
export const onReportResolved = functions.firestore
  .document("reportedContent/{reportId}")
  .onUpdate(async (change, context) => {
    const beforeData = change.before.data();
    const afterData = change.after.data();
    const reportId = context.params.reportId;
    
    // Only process when status changes to resolved
    if (beforeData.status === "pending" && afterData.status === "resolved") {
      const reporterId = afterData.reporterId;
      const contentAuthorId = afterData.contentAuthorId;
      const action = afterData.action;
      
      try {
        if (action === "upheld" || action === "post_removed") {
          // Report was valid - reward reporter
          await updateTrustScore(
            reporterId,
            TRUST_SCORE_CONFIG.REPORT_UPHELD_REPORTER,
            "report_upheld_reporter",
            {reportId, contentId: afterData.contentId}
          );
          
          // Penalize content author
          await updateTrustScore(
            contentAuthorId,
            TRUST_SCORE_CONFIG.REPORT_UPHELD_AUTHOR,
            "report_upheld_author",
            {reportId, contentId: afterData.contentId, reason: afterData.reason}
          );
        } else if (action === "dismissed") {
          // Report was false - penalize reporter
          await updateTrustScore(
            reporterId,
            TRUST_SCORE_CONFIG.REPORT_DISMISSED_REPORTER,
            "report_dismissed",
            {reportId, contentId: afterData.contentId}
          );
        }
      } catch (error) {
        functions.logger.error(`Error updating trust scores for resolved report ${reportId}:`, error);
      }
    }
  });

/**
 * Update trust score when user is blocked
 */
export const onUserBlocked = functions.firestore
  .document("blocks/{userId}/blockedUsers/{blockedUserId}")
  .onCreate(async (snap, context) => {
    const blockedUserId = context.params.blockedUserId;
    
    try {
      await updateTrustScore(
        blockedUserId,
        TRUST_SCORE_CONFIG.BLOCKED_BY_USER,
        "blocked_by_user",
        {blockedBy: context.params.userId}
      );
    } catch (error) {
      functions.logger.error(`Error updating trust score for blocked user ${blockedUserId}:`, error);
    }
  });

/**
 * Callable function for admins to manually adjust trust scores
 */
export const adjustTrustScore = functions.https.onCall(
  async (data, context) => {
    // Check authentication
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Must be authenticated to adjust trust scores"
      );
    }
    
    // Check admin privileges
    const adminDoc = await db.collection("users").doc(context.auth.uid).get();
    if (!adminDoc.exists || !adminDoc.data()?.isAdmin) {
      throw new functions.https.HttpsError(
        "permission-denied",
        "Must be an admin to adjust trust scores"
      );
    }
    
    const {userId, scoreDelta, reason} = data;
    
    if (!userId || scoreDelta === undefined || !reason) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "userId, scoreDelta, and reason are required"
      );
    }
    
    if (typeof scoreDelta !== "number" || scoreDelta < -100 || scoreDelta > 100) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "scoreDelta must be a number between -100 and 100"
      );
    }
    
    try {
      await updateTrustScore(
        userId,
        scoreDelta,
        `admin_adjustment: ${reason}`,
        {
          adjustedBy: context.auth.uid,
          adminReason: reason,
        }
      );
      
      return {
        success: true,
        message: `Trust score adjusted by ${scoreDelta} for user ${userId}`,
      };
    } catch (error) {
      functions.logger.error(`Error in admin trust score adjustment:`, error);
      throw new functions.https.HttpsError(
        "internal",
        "Failed to adjust trust score"
      );
    }
  }
);

/**
 * Callable function to get trust history for a user
 */
export const getTrustHistory = functions.https.onCall(
  async (data, context) => {
    // Check authentication
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Must be authenticated to view trust history"
      );
    }
    
    const {userId, limit = 50} = data;
    const requestingUserId = context.auth.uid;
    
    // Users can view their own history, admins can view any user's history
    if (requestingUserId !== userId) {
      const adminDoc = await db.collection("users").doc(requestingUserId).get();
      if (!adminDoc.exists || !adminDoc.data()?.isAdmin) {
        throw new functions.https.HttpsError(
          "permission-denied",
          "Can only view your own trust history unless you are an admin"
        );
      }
    }
    
    try {
      const historySnapshot = await db
        .collection("users")
        .doc(userId)
        .collection("trustHistory")
        .orderBy("timestamp", "desc")
        .limit(limit)
        .get();
      
      const history = historySnapshot.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
      }));
      
      // Get current trust score
      const userDoc = await db.collection("users").doc(userId).get();
      const userData = userDoc.data();
      
      return {
        currentScore: userData?.trustScore || TRUST_SCORE_CONFIG.INITIAL_SCORE,
        currentLevel: userData?.trustLevel || "newcomer",
        history,
      };
    } catch (error) {
      functions.logger.error(`Error fetching trust history for user ${userId}:`, error);
      throw new functions.https.HttpsError(
        "internal",
        "Failed to fetch trust history"
      );
    }
  }
);

/**
 * Get trust score configuration (for documentation/debugging)
 */
export const getTrustScoreConfig = functions.https.onCall(
  async (data, context) => {
    // Check authentication
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Must be authenticated to view trust score config"
      );
    }
    
    return {
      config: TRUST_SCORE_CONFIG,
      description: "Trust score ranges from 0-100 with automatic updates based on user behavior",
    };
  }
);
