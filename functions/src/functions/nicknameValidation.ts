import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const db = admin.firestore();

/**
 * Validates nickname uniqueness before user creation
 * Called via HTTPS callable function
 */
export const validateNicknameUniqueness = functions.https.onCall(
  async (data, context) => {
    // Require authentication
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "User must be authenticated"
      );
    }

    const {nickname} = data;

    // Validate input
    if (!nickname || typeof nickname !== "string") {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Nickname must be a non-empty string"
      );
    }

    const nicknameToCheck = nickname.toLowerCase();

    try {
      // Query for existing user with same nickname (case-insensitive)
      const querySnapshot = await db
        .collection("users")
        .where("nicknameLowercase", "==", nicknameToCheck)
        .get();

      if (!querySnapshot.empty) {
        // Nickname already exists
        return {
          unique: false,
          message: "Nickname is already taken",
        };
      }

      // Nickname is available
      return {
        unique: true,
        message: "Nickname is available",
      };
    } catch (error) {
      console.error("Error validating nickname:", error);
      throw new functions.https.HttpsError(
        "internal",
        "Failed to validate nickname"
      );
    }
  }
);

/**
 * Triggered on user creation to validate nickname uniqueness
 * Ensures no duplicate nicknames exist
 */
export const onUserCreated = functions.firestore
  .document("users/{userId}")
  .onCreate(async (snap, context) => {
    const userData = snap.data();
    const userId = context.params.userId;

    try {
      const nicknameLowercase = userData.nicknameLowercase;

      // Check for duplicates (excluding current user)
      const duplicateSnapshot = await db
        .collection("users")
        .where("nicknameLowercase", "==", nicknameLowercase)
        .get();

      // If we find more than one document with this nickname (including the one we just created)
      if (duplicateSnapshot.size > 1) {
        // Mark as having a duplicate - this shouldn't happen due to rules
        // but acts as a safety check
        console.warn(`Duplicate nickname detected: ${nicknameLowercase}`);

        // Delete the duplicate entry (keep the first one)
        const docs = duplicateSnapshot.docs;
        for (let i = 1; i < docs.length; i++) {
          await docs[i].ref.delete();
        }
      }
    } catch (error) {
      console.error("Error in onUserCreated:", error);
    }
  });
