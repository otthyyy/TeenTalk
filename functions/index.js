/**
 * Cloud Functions for TeenTalk App
 * 
 * This file contains Firebase Cloud Functions for post moderation,
 * user management, and other backend services.
 */

const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
admin.initializeApp();

/**
 * Moderation Pipeline Function
 * 
 * This function is triggered when a new document is created in the
 * moderationQueue collection. It performs basic content analysis
 * and flags posts for manual review if needed.
 */
exports.moderatePost = functions.firestore
  .document('moderationQueue/{moderationId}')
  .onCreate(async (snap, context) => {
    const moderationData = snap.data();
    
    if (!moderationData) {
      console.log('No moderation data found');
      return null;
    }

    const { postId, content, hasImage, status } = moderationData;
    
    console.log(`Starting moderation for post: ${postId}`);
    console.log(`Content: ${content}`);
    console.log(`Has image: ${hasImage}`);
    console.log(`Status: ${status}`);

    // Basic profanity filter (placeholder)
    const profanityWords = ['spam', 'inappropriate', 'badword1', 'badword2'];
    const lowerContent = content.toLowerCase();
    const containsProfanity = profanityWords.some(word => lowerContent.includes(word));

    // Check for suspicious patterns
    const suspiciousPatterns = [
      /\b\d{10,}\b/, // Phone numbers
      /\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b/, // Email addresses
      /http[s]?:\/\/[^\s]+/, // URLs
    ];
    
    const containsSuspiciousContent = suspiciousPatterns.some(pattern => 
      pattern.test(content)
    );

    // Determine moderation action
    let moderationResult = {
      postId: postId,
      originalStatus: status,
      newStatus: 'approved',
      flags: [],
      requiresManualReview: false,
      moderatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    if (containsProfanity) {
      moderationResult.flags.push('profanity');
      moderationResult.requiresManualReview = true;
      moderationResult.newStatus = 'flagged';
    }

    if (containsSuspiciousContent) {
      moderationResult.flags.push('suspicious_content');
      moderationResult.requiresManualReview = true;
      moderationResult.newStatus = 'flagged';
    }

    // For images, we would normally run them through an image moderation service
    // For now, we'll just flag them for manual review
    if (hasImage) {
      moderationResult.flags.push('has_image');
      moderationResult.requiresManualReview = true;
    }

    // Update the moderation queue document
    await snap.ref.update(moderationResult);

    // Update the post if it needs to be moderated
    if (moderationResult.newStatus === 'flagged') {
      try {
        const postRef = admin.firestore().collection('posts').doc(postId);
        await postRef.update({
          isModerated: true,
          moderationFlags: moderationResult.flags,
          moderationStatus: moderationResult.newStatus,
          moderatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        
        console.log(`Post ${postId} has been flagged for moderation`);
      } catch (error) {
        console.error(`Error updating post ${postId}:`, error);
      }
    } else {
      console.log(`Post ${postId} has been approved`);
    }

    // Log moderation activity for analytics
    await admin.firestore().collection('moderationLogs').add({
      postId: postId,
      result: moderationResult,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });

    return moderationResult;
  });

/**
 * Function to handle user anonymous posts count updates
 * This is triggered when a new post is created
 */
exports.updateAnonymousPostsCount = functions.firestore
  .document('posts/{postId}')
  .onCreate(async (snap, context) => {
    const postData = snap.data();
    
    if (!postData || !postData.isAnonymous) {
      return null;
    }

    const authorId = postData.authorId;
    
    try {
      const userRef = admin.firestore().collection('users').doc(authorId);
      await userRef.set({
        anonymousPostsCount: admin.firestore.FieldValue.increment(1),
        lastPostAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });
      
      console.log(`Updated anonymous posts count for user: ${authorId}`);
    } catch (error) {
      console.error(`Error updating anonymous posts count for user ${authorId}:`, error);
    }
  });

/**
 * Cleanup function for old moderation queue items
 * Runs daily to clean up processed items older than 7 days
 */
exports.cleanupModerationQueue = functions.pubsub
  .schedule('every 24 hours')
  .onRun(async (context) => {
    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() - 7);

    try {
      const oldItems = await admin.firestore()
        .collection('moderationQueue')
        .where('createdAt', '<', cutoffDate)
        .where('status', 'in', ['approved', 'rejected'])
        .get();

      const batch = admin.firestore().batch();
      oldItems.forEach(doc => {
        batch.delete(doc.ref);
      });

      await batch.commit();
      console.log(`Cleaned up ${oldItems.size} old moderation queue items`);
    } catch (error) {
      console.error('Error cleaning up moderation queue:', error);
    }
  });

/**
 * Health check function for monitoring
 */
exports.healthCheck = functions.https.onRequest((request, response) => {
  response.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    version: '1.0.0',
  });
});