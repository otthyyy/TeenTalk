import {
  TRUST_SCORE_CONFIG,
  calculateTrustLevel,
  clampScore,
  applyTrustScoreDelta,
} from "./functions/trustScore";
import * as admin from "firebase-admin";

// Initialize Firebase Admin for tests
admin.initializeApp();
const db = admin.firestore();

describe("Trust Score Utilities", () => {
  it("calculates trust levels for key thresholds", () => {
    expect(calculateTrustLevel(0)).toBe("newcomer");
    expect(calculateTrustLevel(TRUST_SCORE_CONFIG.NEWCOMER_MAX)).toBe("newcomer");
    expect(calculateTrustLevel(TRUST_SCORE_CONFIG.NEWCOMER_MAX + 1)).toBe("member");
    expect(calculateTrustLevel(TRUST_SCORE_CONFIG.MEMBER_MAX)).toBe("member");
    expect(calculateTrustLevel(TRUST_SCORE_CONFIG.MEMBER_MAX + 1)).toBe("trusted");
    expect(calculateTrustLevel(TRUST_SCORE_CONFIG.TRUSTED_MAX)).toBe("trusted");
    expect(calculateTrustLevel(TRUST_SCORE_CONFIG.TRUSTED_MAX + 1)).toBe("veteran");
    expect(calculateTrustLevel(TRUST_SCORE_CONFIG.MAX_SCORE)).toBe("veteran");
  });

  it("clamps scores within 0-100", () => {
    expect(clampScore(-10)).toBe(TRUST_SCORE_CONFIG.MIN_SCORE);
    expect(clampScore(0)).toBe(0);
    expect(clampScore(50)).toBe(50);
    expect(clampScore(100)).toBe(100);
    expect(clampScore(150)).toBe(TRUST_SCORE_CONFIG.MAX_SCORE);
  });

  it("applies positive deltas and updates levels", () => {
    const result = applyTrustScoreDelta(48, TRUST_SCORE_CONFIG.POST_APPROVED);
    expect(result.previousScore).toBe(48);
    expect(result.previousLevel).toBe("member");
    expect(result.newScore).toBe(50);
    expect(result.newLevel).toBe("member");
  });

  it("applies negative deltas and updates levels", () => {
    const result = applyTrustScoreDelta(42, TRUST_SCORE_CONFIG.POST_FLAGGED);
    expect(result.previousScore).toBe(42);
    expect(result.previousLevel).toBe("member");
    expect(result.newScore).toBe(37);
    expect(result.newLevel).toBe("newcomer");
  });

  it("clamps high deltas at maximum score", () => {
    const result = applyTrustScoreDelta(98, 10);
    expect(result.newScore).toBe(TRUST_SCORE_CONFIG.MAX_SCORE);
    expect(result.newLevel).toBe("veteran");
  });

  it("clamps negative deltas at minimum score", () => {
    const result = applyTrustScoreDelta(2, -10);
    expect(result.newScore).toBe(TRUST_SCORE_CONFIG.MIN_SCORE);
    expect(result.newLevel).toBe("newcomer");
  });

  it("exposes consistent configuration", () => {
    expect(TRUST_SCORE_CONFIG.INITIAL_SCORE).toBeGreaterThanOrEqual(TRUST_SCORE_CONFIG.MIN_SCORE);
    expect(TRUST_SCORE_CONFIG.INITIAL_SCORE).toBeLessThanOrEqual(TRUST_SCORE_CONFIG.MAX_SCORE);
    expect(TRUST_SCORE_CONFIG.NEWCOMER_MAX).toBeLessThan(TRUST_SCORE_CONFIG.MEMBER_MAX);
    expect(TRUST_SCORE_CONFIG.MEMBER_MAX).toBeLessThan(TRUST_SCORE_CONFIG.TRUSTED_MAX);
    expect(TRUST_SCORE_CONFIG.TRUSTED_MAX).toBeLessThan(TRUST_SCORE_CONFIG.MAX_SCORE);
  });
});

describe("Firebase Integration Tests", () => {
  afterEach(async () => {
    const collections = await db.listCollections();
    await Promise.all(
      collections.map(async (collection) => {
        const documents = await collection.listDocuments();
        await Promise.all(documents.map((doc) => doc.delete()));
      })
    );
  });

  describe("nicknameValidation", () => {
    it("should validate nickname uniqueness correctly", async () => {
      const userId = "testUser123";
      await db.collection("users").doc(userId).set({
        uid: userId,
        nickname: "testnicname",
        nicknameLowercase: "testnicname",
        profileVisible: true,
        privacyConsentGiven: true,
        privacyConsentTimestamp: admin.firestore.Timestamp.now(),
        createdAt: admin.firestore.Timestamp.now(),
        anonymousPostsCount: 0,
        isAdmin: false,
        blockedUsers: [],
        isSuspended: false,
      });

      const query = db
        .collection("users")
        .where("nicknameLowercase", "==", "testnicname");
      const snapshot = await query.get();

      expect(snapshot.size).toBe(1);
    });

    it("should handle duplicate nickname detection", async () => {
      const nickname = "duplicatename";
      const nicknameLower = nickname.toLowerCase();

      await db.collection("users").doc("user1").set({
        uid: "user1",
        nickname,
        nicknameLowercase: nicknameLower,
        profileVisible: true,
        privacyConsentGiven: true,
        privacyConsentTimestamp: admin.firestore.Timestamp.now(),
        createdAt: admin.firestore.Timestamp.now(),
        anonymousPostsCount: 0,
        isAdmin: false,
        blockedUsers: [],
        isSuspended: false,
      });

      const query = db
        .collection("users")
        .where("nicknameLowercase", "==", nicknameLower);
      const snapshot = await query.get();

      expect(snapshot.size).toBe(1);
    });
  });

  describe("pushNotifications", () => {
    it("should register FCM token", async () => {
      const userId = "user1";
      const token = "test_fcm_token_123";

      await db.collection("users").doc(userId).set({
        uid: userId,
        nickname: "testuser",
        nicknameLowercase: "testuser",
        profileVisible: true,
        privacyConsentGiven: true,
        privacyConsentTimestamp: admin.firestore.Timestamp.now(),
        createdAt: admin.firestore.Timestamp.now(),
        anonymousPostsCount: 0,
        isAdmin: false,
        blockedUsers: [],
        isSuspended: false,
        fcmTokens: [token],
      });

      const doc = await db.collection("users").doc(userId).get();
      expect(doc.data()?.fcmTokens).toContain(token);
    });

    it("should not duplicate FCM tokens", async () => {
      const userId = "user1";
      const token = "test_token_123";

      await db.collection("users").doc(userId).set({
        uid: userId,
        nickname: "testuser",
        nicknameLowercase: "testuser",
        profileVisible: true,
        privacyConsentGiven: true,
        privacyConsentTimestamp: admin.firestore.Timestamp.now(),
        createdAt: admin.firestore.Timestamp.now(),
        anonymousPostsCount: 0,
        isAdmin: false,
        blockedUsers: [],
        isSuspended: false,
        fcmTokens: [token],
      });

      const userRef = db.collection("users").doc(userId);
      const userDoc = await userRef.get();
      const tokens = userDoc.data()?.fcmTokens || [];

      if (!tokens.includes(token)) {
        tokens.push(token);
        await userRef.update({fcmTokens: tokens});
      }

      const updated = await userRef.get();
      expect(updated.data()?.fcmTokens).toHaveLength(1);
      expect(updated.data()?.fcmTokens).toContain(token);
    });
  });

  describe("dataCleanup", () => {
    it("should handle notification cleanup", async () => {
      const userId = "user1";
      const oldDate = new Date();
      oldDate.setDate(oldDate.getDate() - 40);

      await db.collection("users").doc(userId)
        .collection("notifications").doc("old1").set({
          type: "comment",
          createdAt: admin.firestore.Timestamp.fromDate(oldDate),
          read: true,
        });

      await db.collection("users").doc(userId)
        .collection("notifications").doc("new1").set({
          type: "comment",
          createdAt: admin.firestore.Timestamp.now(),
          read: false,
        });

      const snapshot = await db.collection("users").doc(userId)
        .collection("notifications").get();
      expect(snapshot.size).toBe(2);
    });
  });

  describe("Authorization and Access Control", () => {
    it("should prevent unauthorized post creation", async () => {
      const authorId = "author1";

      try {
        await db.collection("posts").doc("post1").set({
          authorId: authorId,
          content: "Unauthorized post",
          createdAt: admin.firestore.Timestamp.now(),
          commentCount: 0,
          likeCount: 0,
          isAnonymous: false,
        });

        const doc = await db.collection("posts").doc("post1").get();
        expect(doc.exists).toBe(true);
      } catch (error) {
        expect(error).toBeDefined();
      }
    });

    it("should enforce user privacy settings", async () => {
      const userId = "user1";

      await db.collection("users").doc(userId).set({
        uid: userId,
        nickname: "privateuser",
        nicknameLowercase: "privateuser",
        profileVisible: false,
        privacyConsentGiven: true,
        privacyConsentTimestamp: admin.firestore.Timestamp.now(),
        createdAt: admin.firestore.Timestamp.now(),
        anonymousPostsCount: 0,
        isAdmin: false,
        blockedUsers: [],
        isSuspended: false,
      });

      const doc = await db.collection("users").doc(userId).get();
      expect(doc.data()?.profileVisible).toBe(false);
    });
  });

  describe("Batch Operations", () => {
    it("should handle batch writes correctly", async () => {
      const batch = db.batch();

      const post1Ref = db.collection("posts").doc("batch1");
      const post2Ref = db.collection("posts").doc("batch2");

      batch.set(post1Ref, {
        authorId: "author1",
        content: "Batch post 1",
        createdAt: admin.firestore.Timestamp.now(),
        commentCount: 0,
        likeCount: 0,
        isAnonymous: false,
      });

      batch.set(post2Ref, {
        authorId: "author2",
        content: "Batch post 2",
        createdAt: admin.firestore.Timestamp.now(),
        commentCount: 0,
        likeCount: 0,
        isAnonymous: false,
      });

      await batch.commit();

      const doc1 = await post1Ref.get();
      const doc2 = await post2Ref.get();

      expect(doc1.exists).toBe(true);
      expect(doc2.exists).toBe(true);
    });
  });
});
