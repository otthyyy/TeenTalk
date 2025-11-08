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
