// Firebase SDK
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");
const { logger } = require("firebase-functions");

// Other Dependencies
const express = require("express");
const app = express();
const cors = require("cors");
app.use(cors({ origin: true }));
app.use(express.json());

// Constants
const db = getFirestore();
const constants = require("../supporting/constants");

// ======= Helpers =======

/**
 * Search for a course from the Cornell API and update its tracking status
 *
 * @param trackedCourse the course to search for
 */
exports.updateTrackingStatus = async function (trackedCourse) {
  const response = await fetch(
    `${constants.ROSTER_URL}&subject=${
      trackedCourse.subject
    }&classLevels%5B%5D=${String(trackedCourse.number).charAt(0)}000`
  );

  const data = await response.json();
  const classes = data["data"]["classes"];

  let result = classes.filter((dict) => {
    return dict.crseId == trackedCourse.course_id;
  })[0];

  result = result.enrollGroups[0].classSections.filter((dict) => {
    return dict.classNbr == trackedCourse.section_id;
  })[0];

  // Only notify if closed/waitlisted to open
  if (
    (trackedCourse.status == "C" || trackedCourse.status == "W") &&
    result.openStatus == "O"
  ) {
    await sendNotification(
      `Quick! The section code is ${trackedCourse.section_id}.`,
      `${trackedCourse.subject} ${trackedCourse.number} ${trackedCourse.section_title} is Open!`,
      trackedCourse.device_ids
    );
  }

  // Update database only if there are changes
  if (trackedCourse.status != result.openStatus) {
    await db
      .collection("courses")
      .doc(String(trackedCourse.section_id))
      .update({
        status: result.openStatus,
      });

    trackedCourse.device_ids.forEach(async (deviceId) => {
      const snapshot = await db
        .collection("users")
        .where("device_id", "==", deviceId)
        .get();

      const trackedCourseCopy = {};
      Object.assign(trackedCourseCopy, trackedCourse);
      delete trackedCourseCopy.device_ids;

      snapshot.forEach(async (doc) => {
        const userRef = db.collection("users").doc(doc.id);

        // Delete old status
        await userRef.update({
          tracking: FieldValue.arrayRemove(trackedCourseCopy),
        });

        // Add new status
        trackedCourseCopy.status = result.openStatus;
        await userRef.update({
          tracking: FieldValue.arrayUnion(trackedCourseCopy),
        });
      });
    });
  }

  return;
};

/**
 * Send a push notification
 *
 * @param {string} body the notification body
 * @param {string} title the notification title
 * @param {Array} tokens the device tokens to notify
 */
const sendNotification = async function (body, title, tokens) {
  const message = {
    notification: {
      title: title,
      body: body,
    },
    tokens: tokens,
  };

  try {
    const response = await getMessaging().sendEachForMulticast(message);
    logger.log(`${response.successCount} notifications were sent successfully`);

    // Remove all failed tokens
    if (response.failureCount > 0) {
      logger.log(`${response.failureCount} notifications failed`);
      response.responses.forEach(async (resp, idx) => {
        if (!resp.success) {
          const snapshot = await db
            .collection("courses")
            .where("device_ids", "array-contains", tokens[idx])
            .get();

          snapshot.forEach(async (doc) => {
            await db
              .collection("courses")
              .doc(doc.id)
              .update({
                device_ids: FieldValue.arrayRemove(tokens[idx]),
              });
          });
        }
      });
    }
  } catch (error) {
    logger.log(`error: ${error}`);
  }

  return;
};
