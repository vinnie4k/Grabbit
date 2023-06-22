// Firebase SDK
const { getFirestore } = require("firebase-admin/firestore");
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
 * @param {number} courseId the course's ID
 * @param {Array} deviceIds the tracked device IDs
 * @param {number} number the number of the course (e.g. 1920)
 * @param {number} sectionId the section ID
 * @param {string} sectionTitle the section title (e.g. "LEC 001")
 * @param {status} status the current status of the section
 * @param {string} subject the subject of the course in all CAPS (e.g. "MATH")
 */
exports.updateTrackingStatus = async function (
  courseId,
  deviceIds,
  number,
  sectionId,
  sectionTitle,
  status,
  subject
) {
  const response = await fetch(
    `${constants.ROSTER_URL}&subject=${subject}&classLevels%5B%5D=${String(
      number
    ).charAt(0)}000`
  );

  const data = await response.json();
  const classes = data["data"]["classes"];

  let result = classes.filter((dict) => {
    return dict.crseId == courseId;
  })[0];

  result = result.enrollGroups[0].classSections.filter((dict) => {
    return dict.classNbr == sectionId;
  })[0];

  // Only notify if closed/waitlisted to open
  if ((status == "C" || status == "W") && result.openStatus == "O") {
    await sendNotification(
      `Quick! The section code is ${sectionId}.`,
      `${subject} ${number} ${sectionTitle} is Open!`,
      deviceIds
    );
  }

  // Update database only if there are changes
  if (status != result.openStatus) {
    await db.collection("courses").doc(String(sectionId)).update({
      status: result.openStatus,
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
    logger.log(response.successCount + " notifications were sent successfully");
  } catch (error) {
    logger.log(`error: ${error}`);
  }

  return;
};
