import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

export const getExtendedAnalytics = functions.https.onCall(
  async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Must be authenticated to get analytics"
      );
    }

    const userId = context.auth.uid;
    const userDoc = await admin
      .firestore()
      .collection("users")
      .doc(userId)
      .get();

    if (
      !userDoc.exists ||
      (!userDoc.data()?.isAdmin && !userDoc.data()?.isModerator)
    ) {
      throw new functions.https.HttpsError(
        "permission-denied",
        "Must be an admin or moderator to get analytics"
      );
    }

    const {startDate, endDate, school} = data;

    try {
      const startDateTime = startDate
        ? admin.firestore.Timestamp.fromDate(new Date(startDate))
        : admin.firestore.Timestamp.fromDate(
            new Date(Date.now() - 30 * 24 * 60 * 60 * 1000)
          );
      const endDateTime = endDate
        ? admin.firestore.Timestamp.fromDate(new Date(endDate))
        : admin.firestore.Timestamp.now();

      const dailyMetrics = await getDailyMetrics(
        startDateTime,
        endDateTime,
        school
      );
      const schoolMetrics = await getSchoolMetrics(
        startDateTime,
        endDateTime
      );
      const reportReasons = await getReportReasons(
        startDateTime,
        endDateTime,
        school
      );
      const userStats = await getUserStats(school);
      const contentStats = await getContentStats(
        startDateTime,
        endDateTime,
        school
      );

      return {
        dailyMetrics,
        schoolMetrics,
        reportReasons,
        totalUsers: userStats.totalUsers,
        activeUsers: userStats.activeUsers,
        totalPosts: contentStats.totalPosts,
        totalComments: contentStats.totalComments,
      };
    } catch (error) {
      functions.logger.error("Error getting extended analytics:", error);
      throw new functions.https.HttpsError(
        "internal",
        "Error fetching analytics"
      );
    }
  }
);

function normalizeDate(value: any): Date {
  if (!value) {
    return new Date(0);
  }

  if (value instanceof admin.firestore.Timestamp) {
    return value.toDate();
  }

  if (typeof value.toDate === "function") {
    return value.toDate();
  }

  return new Date(value);
}

async function getDailyMetrics(
  startDate: admin.firestore.Timestamp,
  endDate: admin.firestore.Timestamp,
  school?: string
): Promise<any[]> {
  const metrics: Map<string, any> = new Map();
  const db = admin.firestore();

  let postsQuery: admin.firestore.Query = db
    .collection("posts")
    .where("createdAt", ">=", startDate.toDate().toISOString())
    .where("createdAt", "<=", endDate.toDate().toISOString());

  if (school) {
    postsQuery = postsQuery.where("school", "==", school);
  }

  const postsSnapshot = await postsQuery.get();
  postsSnapshot.docs.forEach((doc) => {
    const data = doc.data();
    const dateStr = normalizeDate(data.createdAt)
      .toISOString()
      .split("T")[0];

    if (!metrics.has(dateStr)) {
      metrics.set(dateStr, {
        date: dateStr,
        postCount: 0,
        commentCount: 0,
        reportCount: 0,
        activeUserCount: 0,
        userIds: new Set(),
      });
    }

    const metric = metrics.get(dateStr);
    metric.postCount++;
    metric.userIds.add(data.authorId);
  });

  let commentsQuery: admin.firestore.Query = db
    .collection("comments")
    .where("createdAt", ">=", startDate.toDate().toISOString())
    .where("createdAt", "<=", endDate.toDate().toISOString());

  if (school) {
    commentsQuery = commentsQuery.where("school", "==", school);
  }

  const commentsSnapshot = await commentsQuery.get();
  commentsSnapshot.docs.forEach((doc) => {
    const data = doc.data();
    const dateStr = normalizeDate(data.createdAt)
      .toISOString()
      .split("T")[0];

    if (!metrics.has(dateStr)) {
      metrics.set(dateStr, {
        date: dateStr,
        postCount: 0,
        commentCount: 0,
        reportCount: 0,
        activeUserCount: 0,
        userIds: new Set(),
      });
    }

    const metric = metrics.get(dateStr);
    metric.commentCount++;
    metric.userIds.add(data.authorId);
  });

  let reportsQuery: admin.firestore.Query = db
    .collection("reports")
    .where("createdAt", ">=", startDate.toDate().toISOString())
    .where("createdAt", "<=", endDate.toDate().toISOString());

  if (school) {
    reportsQuery = reportsQuery.where("school", "==", school);
  }

  const reportsSnapshot = await reportsQuery.get();
  reportsSnapshot.docs.forEach((doc) => {
    const data = doc.data();
    const dateStr = normalizeDate(data.createdAt)
      .toISOString()
      .split("T")[0];

    if (!metrics.has(dateStr)) {
      metrics.set(dateStr, {
        date: dateStr,
        postCount: 0,
        commentCount: 0,
        reportCount: 0,
        activeUserCount: 0,
        userIds: new Set(),
      });
    }

    const metric = metrics.get(dateStr);
    metric.reportCount++;
  });

  return Array.from(metrics.values())
    .map((m) => ({
      date: m.date,
      postCount: m.postCount,
      commentCount: m.commentCount,
      reportCount: m.reportCount,
      activeUserCount: m.userIds.size,
    }))
    .sort((a, b) => a.date.localeCompare(b.date));
}

async function getSchoolMetrics(
  startDate: admin.firestore.Timestamp,
  endDate: admin.firestore.Timestamp
): Promise<any[]> {
  const db = admin.firestore();
  const schoolMap: Map<string, any> = new Map();

  const usersSnapshot = await db.collection("users").get();
  usersSnapshot.docs.forEach((doc) => {
    const data = doc.data();
    const school = data.school || "Unknown";

    if (!schoolMap.has(school)) {
      schoolMap.set(school, {
        schoolName: school,
        userCount: 0,
        postCount: 0,
        reportCount: 0,
      });
    }

    schoolMap.get(school).userCount++;
  });

  const postsSnapshot = await db
    .collection("posts")
    .where("createdAt", ">=", startDate.toDate().toISOString())
    .where("createdAt", "<=", endDate.toDate().toISOString())
    .get();

  postsSnapshot.docs.forEach((doc) => {
    const data = doc.data();
    const school = data.school || "Unknown";

    if (!schoolMap.has(school)) {
      schoolMap.set(school, {
        schoolName: school,
        userCount: 0,
        postCount: 0,
        reportCount: 0,
      });
    }

    schoolMap.get(school).postCount++;
  });

  let reportsQuery: admin.firestore.Query = db
    .collection("reports")
    .where("createdAt", ">=", startDate.toDate().toISOString())
    .where("createdAt", "<=", endDate.toDate().toISOString());

  const reportsSnapshot = await reportsQuery.get();
  reportsSnapshot.docs.forEach((doc) => {
    const data = doc.data();
    const school = data.school || "Unknown";

    if (!schoolMap.has(school)) {
      schoolMap.set(school, {
        schoolName: school,
        userCount: 0,
        postCount: 0,
        reportCount: 0,
      });
    }

    schoolMap.get(school).reportCount++;
  });

  return Array.from(schoolMap.values()).sort(
    (a, b) => b.userCount - a.userCount
  );
}

async function getReportReasons(
  startDate: admin.firestore.Timestamp,
  endDate: admin.firestore.Timestamp,
  school?: string
): Promise<{[key: string]: number}> {
  const db = admin.firestore();
  const reasons: {[key: string]: number} = {};

  let reportsQuery: admin.firestore.Query = db
    .collection("reports")
    .where("createdAt", ">=", startDate.toDate().toISOString())
    .where("createdAt", "<=", endDate.toDate().toISOString());

  if (school) {
    reportsQuery = reportsQuery.where("school", "==", school);
  }

  const reportsSnapshot = await reportsQuery.get();

  reportsSnapshot.docs.forEach((doc) => {
    const data = doc.data();
    const reason = data.reason || "Other";
    reasons[reason] = (reasons[reason] || 0) + 1;
  });

  return reasons;
}

async function getUserStats(school?: string): Promise<{
  totalUsers: number;
  activeUsers: number;
}> {
  const db = admin.firestore();
  let usersQuery: admin.firestore.Query = db.collection("users");

  if (school) {
    usersQuery = usersQuery.where("school", "==", school);
  }

  const usersSnapshot = await usersQuery.get();
  const totalUsers = usersSnapshot.size;

  const thirtyDaysAgo = admin.firestore.Timestamp.fromDate(
    new Date(Date.now() - 30 * 24 * 60 * 60 * 1000)
  );

  const thirtyDaysAgoStr = thirtyDaysAgo.toDate().toISOString();

  let activeUsersQuery: admin.firestore.Query = db
    .collection("posts")
    .where("createdAt", ">=", thirtyDaysAgoStr);

  if (school) {
    activeUsersQuery = activeUsersQuery.where("school", "==", school);
  }

  const activePostsSnapshot = await activeUsersQuery.get();
  const activeUserIds = new Set(
    activePostsSnapshot.docs.map((doc) => doc.data().authorId)
  );

  return {
    totalUsers,
    activeUsers: activeUserIds.size,
  };
}

async function getContentStats(
  startDate: admin.firestore.Timestamp,
  endDate: admin.firestore.Timestamp,
  school?: string
): Promise<{totalPosts: number; totalComments: number}> {
  const db = admin.firestore();

  let postsQuery: admin.firestore.Query = db
    .collection("posts")
    .where("createdAt", ">=", startDate.toDate().toISOString())
    .where("createdAt", "<=", endDate.toDate().toISOString());

  if (school) {
    postsQuery = postsQuery.where("school", "==", school);
  }

  const postsSnapshot = await postsQuery.get();

  let commentsQuery: admin.firestore.Query = db
    .collection("comments")
    .where("createdAt", ">=", startDate.toDate().toISOString())
    .where("createdAt", "<=", endDate.toDate().toISOString());

  if (school) {
    commentsQuery = commentsQuery.where("school", "==", school);
  }

  const commentsSnapshot = await commentsQuery.get();

  return {
    totalPosts: postsSnapshot.size,
    totalComments: commentsSnapshot.size,
  };
}
