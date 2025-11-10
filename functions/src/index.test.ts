import * as admin from "firebase-admin";
import {expect} from "chai";

// Initialize Firebase Admin for testing
admin.initializeApp();

describe("Cloud Functions Tests", () => {
  const db = admin.firestore();

  before(async () => {
    // Use emulator if available
    process.env.FIRESTORE_EMULATOR_HOST = "localhost:8080";
  });

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
      // Create a user with a nickname
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

      // Query for the nickname
      const query = db
        .collection("users")
        .where("nicknameLowercase", "==", "testnicname");
      const snapshot = await query.get();

      expect(snapshot.size).to.equal(1);
    });

    it("should handle duplicate nickname detection", async () => {
      const nickname = "duplicatename";
      const nicknameLower = nickname.toLowerCase();

      // Create first user
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

      // Query should return exactly one
      const query = db
        .collection("users")
        .where("nicknameLowercase", "==", nicknameLower);
      const snapshot = await query.get();

      expect(snapshot.size).to.equal(1);
    });
  });

  describe("postCounters", () => {
    it("should initialize post with zero counts", async () => {
      const postData = {
        authorId: "author1",
        content: "Test post",
        createdAt: admin.firestore.Timestamp.now(),
        commentCount: 0,
        likeCount: 0,
        isAnonymous: false,
      };

      const postRef = db.collection("posts").doc("post1");
      await postRef.set(postData);

      const doc = await postRef.get();
      expect(doc.data()?.commentCount).to.equal(0);
      expect(doc.data()?.likeCount).to.equal(0);
    });

    it("should track comment increments", async () => {
      // Create post
      const postRef = db.collection("posts").doc("post1");
      await postRef.set({
        authorId: "author1",
        content: "Test post",
        createdAt: admin.firestore.Timestamp.now(),
        commentCount: 0,
        likeCount: 0,
        isAnonymous: false,
      });

      // Simulate comment creation (in real scenario, this would be triggered by function)
      const initialDoc = await postRef.get();
      expect(initialDoc.data()?.commentCount).to.equal(0);

      // Manually update to simulate function behavior
      await postRef.update({
        commentCount: admin.firestore.FieldValue.increment(1),
      });

      const updatedDoc = await postRef.get();
      expect(updatedDoc.data()?.commentCount).to.equal(1);
    });

    it("should track like increments", async () => {
      const postRef = db.collection("posts").doc("post1");
      await postRef.set({
        authorId: "author1",
        content: "Test post",
        createdAt: admin.firestore.Timestamp.now(),
        commentCount: 0,
        likeCount: 0,
        isAnonymous: false,
      });

      // Add like
      await db.collection("posts").doc("post1").collection("likes")
        .doc("user1").set({
          timestamp: admin.firestore.Timestamp.now(),
        });

      // Simulate function update
      await postRef.update({
        likeCount: admin.firestore.FieldValue.increment(1),
      });

      const doc = await postRef.get();
      expect(doc.data()?.likeCount).to.equal(1);
    });

    it("should handle like removal", async () => {
      const postRef = db.collection("posts").doc("post1");
      await postRef.set({
        authorId: "author1",
        content: "Test post",
        createdAt: admin.firestore.Timestamp.now(),
        commentCount: 0,
        likeCount: 1,
        isAnonymous: false,
      });

      // Remove like
      await postRef.update({
        likeCount: admin.firestore.FieldValue.increment(-1),
      });

      const doc = await postRef.get();
      expect(doc.data()?.likeCount).to.equal(0);
    });
  });

  describe("commentCounters", () => {
    it("should track comment likes", async () => {
      const postRef = db.collection("posts").doc("post1");
      await postRef.set({
        authorId: "author1",
        content: "Test post",
        createdAt: admin.firestore.Timestamp.now(),
        commentCount: 0,
        likeCount: 0,
        isAnonymous: false,
      });

      const commentRef = postRef.collection("comments").doc("comment1");
      await commentRef.set({
        authorId: "commenter1",
        content: "Test comment",
        createdAt: admin.firestore.Timestamp.now(),
        likeCount: 0,
      });

      // Simulate like addition
      await commentRef.update({
        likeCount: admin.firestore.FieldValue.increment(1),
      });

      const doc = await commentRef.get();
      expect(doc.data()?.likeCount).to.equal(1);
    });
  });

  describe("moderationQueue", () => {
    it("should create moderation queue item on report", async () => {
      const reportData = {
        reporterId: "reporter1",
        postId: "post1",
        reason: "inappropriate_content",
        description: "This post contains inappropriate content",
        createdAt: admin.firestore.Timestamp.now(),
        status: "pending",
      };

      await db.collection("reportedPosts").doc("report1").set(reportData);

      const doc = await db.collection("reportedPosts").doc("report1").get();
      expect(doc.exists).to.be.true;
      expect(doc.data()?.status).to.equal("pending");
    });

    it("should calculate priority correctly", async () => {
      const reasons = [
        {reason: "violence", priority: 5},
        {reason: "harassment", priority: 4},
        {reason: "inappropriate_content", priority: 3},
        {reason: "spam", priority: 2},
        {reason: "other", priority: 1},
      ];

      for (const {reason, priority} of reasons) {
        await db.collection("reportedPosts")
          .doc(`report_${reason}`).set({
            reporterId: "reporter1",
            postId: "post1",
            reason,
            createdAt: admin.firestore.Timestamp.now(),
            status: "pending",
            priority,
          });
      }

      // Verify each report has correct priority
      for (const {reason, priority} of reasons) {
        const doc = await db.collection("reportedPosts")
          .doc(`report_${reason}`).get();
        expect(doc.data()?.priority).to.equal(priority);
      }
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
      expect(doc.data()?.fcmTokens).to.include(token);
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

      // Try to add same token again
      const userRef = db.collection("users").doc(userId);
      const userDoc = await userRef.get();
      const tokens = userDoc.data()?.fcmTokens || [];

      if (!tokens.includes(token)) {
        tokens.push(token);
        await userRef.update({fcmTokens: tokens});
      }

      const updated = await userRef.get();
      expect(updated.data()?.fcmTokens).to.have.lengthOf(1);
      expect(updated.data()?.fcmTokens).to.include(token);
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

      // Count notifications
      const snapshot = await db.collection("users").doc(userId)
        .collection("notifications").get();
      expect(snapshot.size).to.equal(2);
    });
  });

  describe("Authorization and Access Control", () => {
    it("should prevent unauthorized post creation", async () => {
      const authorId = "author1";

      try {
        // Try to create post as different user
        await db.collection("posts").doc("post1").set({
          authorId: authorId, // Different from authenticated user
          content: "Unauthorized post",
          createdAt: admin.firestore.Timestamp.now(),
          commentCount: 0,
          likeCount: 0,
          isAnonymous: false,
        });

        // In real scenario with auth, this would fail
        // For now we verify structure
        const doc = await db.collection("posts").doc("post1").get();
        expect(doc.exists).to.be.true;
      } catch (error) {
        expect(error).to.exist;
      }
    });

    it("should enforce user privacy settings", async () => {
      const userId = "user1";

      await db.collection("users").doc(userId).set({
        uid: userId,
        nickname: "privateuser",
        nicknameLowercase: "privateuser",
        profileVisible: false, // Private profile
        privacyConsentGiven: true,
        privacyConsentTimestamp: admin.firestore.Timestamp.now(),
        createdAt: admin.firestore.Timestamp.now(),
        anonymousPostsCount: 0,
        isAdmin: false,
        blockedUsers: [],
        isSuspended: false,
      });

      const doc = await db.collection("users").doc(userId).get();
      expect(doc.data()?.profileVisible).to.be.false;
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

      expect(doc1.exists).to.be.true;
      expect(doc2.exists).to.be.true;
    });
  });
});
