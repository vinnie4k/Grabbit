// Firebase SDK
const { onRequest } = require("firebase-functions/v2/https");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");

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
 * Remove from the list of tracked courses in the database
 *
 * @param trackedCourse the course to untrack
 * @param {string} deviceId the device ID to remove from tracked courses
 */
async function removeTrackedCourses(trackedCourse, deviceId) {
  const ref = db.collection("courses").doc(String(trackedCourse.section_id));
  const doc = await ref.get();
  const deviceIds = await doc.data().device_ids;

  if (doc.exists && deviceIds.length == 1 && deviceIds[0] == deviceId) {
    // Remove document
    await ref.delete();
  } else if (
    doc.exists &&
    deviceIds.length > 1 &&
    deviceIds.includes(deviceId)
  ) {
    // Update device IDs
    await ref.update({
      device_ids: FieldValue.arrayRemove(deviceId),
    });
  }
}

/**
 * Add to the list of tracked courses in the database
 *
 * @param trackedCourse the course to track
 * @param {string} deviceId the device ID to add to tracked courses
 */
async function addTrackedCourses(trackedCourse, deviceId) {
  const ref = db.collection("courses").doc(String(trackedCourse.section_id));
  const doc = await ref.get();

  if (!doc.exists) {
    // Add new document
    trackedCourse["device_ids"] = [deviceId];
    await ref.set(trackedCourse);
  } else {
    // Update device IDs
    await ref.update({
      device_ids: FieldValue.arrayUnion(deviceId),
    });
  }
}

// ======= Routes =======

/**
 * This route removes a course from being tracked for a given user ID
 *
 * - course_id (Integer): the course's ID
 * - course_title (String): the course title (e.g. "Multivariable Calculus")
 * - device_id (String): the device's ID
 * - number (Integer): the course's number (e.g. 1920)
 * - pattern (String): the date pattern (e.g. "MWF")
 * - section_id (Integer): the section's ID
 * - section_title (String): the section title (e.g. "LEC 001")
 * - status (String): "O" for open, "C" for closed
 * - subject (String): the course's subject (e.g. "MATH")
 * - time_end (String): the course's end time
 * - time_start (String): the course's start time
 * - user_id (String): the user's ID
 */
app.post("/untrack/", async (req, res) => {
  const courseId = req.body.course_id;
  const courseTitle = req.body.course_title;
  const deviceId = req.body.device_id;
  const number = req.body.number;
  const pattern = req.body.pattern;
  const sectionId = req.body.section_id;
  const sectionTitle = req.body.section_title;
  const status = req.body.status;
  const subject = req.body.subject;
  const timeEnd = req.body.time_end;
  const timeStart = req.body.time_start;
  const userId = req.body.user_id;

  if (
    userId == null ||
    deviceId == null ||
    courseId == null ||
    sectionId == null ||
    number == null ||
    subject == null ||
    status == null ||
    timeEnd == null ||
    timeStart == null ||
    pattern == null ||
    courseTitle == null ||
    sectionTitle == null
  ) {
    return constants.errorResponse(
      "Invalid course information specified",
      404,
      res
    );
  }

  const trackedCourse = {
    course_id: courseId,
    course_title: courseTitle,
    number: number,
    pattern: pattern,
    section_id: sectionId,
    section_title: sectionTitle,
    status: status,
    subject: subject,
    time_end: timeEnd,
    time_start: timeStart,
  };

  const trackedCourseCopy = {};
  Object.assign(trackedCourseCopy, trackedCourse);

  try {
    await db
      .collection("users")
      .doc(userId)
      .update({
        tracking: FieldValue.arrayRemove(trackedCourse),
      });

    // Update Tracked Courses
    await removeTrackedCourses(trackedCourse, deviceId);

    return constants.successResponse(trackedCourseCopy, 200, res);
  } catch (error) {
    return constants.errorResponse("Unable to untrack the course", 500, res);
  }
});

/**
 * This route adds a course to be tracked for a given user ID
 *
 * - course_id (Integer): the course's ID
 * - course_title (String): the course title (e.g. "Multivariable Calculus")
 * - device_id (String): the device's ID
 * - number (Integer): the course's number (e.g. 1920)
 * - pattern (String): the date pattern (e.g. "MWF")
 * - section_id (Integer): the section's ID
 * - section_title (String): the section title (e.g. "LEC 001")
 * - status (String): "O" for open, "C" for closed
 * - subject (String): the course's subject (e.g. "MATH")
 * - time_end (String): the course's end time
 * - time_start (String): the course's start time
 * - user_id (String): the user's ID
 */
app.post("/track/", async (req, res) => {
  const courseId = req.body.course_id;
  const courseTitle = req.body.course_title;
  const deviceId = req.body.device_id;
  const number = req.body.number;
  const pattern = req.body.pattern;
  const sectionId = req.body.section_id;
  const sectionTitle = req.body.section_title;
  const status = req.body.status;
  const subject = req.body.subject;
  const timeEnd = req.body.time_end;
  const timeStart = req.body.time_start;
  const userId = req.body.user_id;

  if (
    userId == null ||
    deviceId == null ||
    courseId == null ||
    sectionId == null ||
    number == null ||
    subject == null ||
    status == null ||
    timeEnd == null ||
    timeStart == null ||
    pattern == null ||
    courseTitle == null ||
    sectionTitle == null
  ) {
    return constants.errorResponse(
      "Invalid course information specified",
      404,
      res
    );
  }

  const trackedCourse = {
    course_id: courseId,
    course_title: courseTitle,
    number: number,
    pattern: pattern,
    section_id: sectionId,
    section_title: sectionTitle,
    status: status,
    subject: subject,
    time_end: timeEnd,
    time_start: timeStart,
  };

  const trackedCourseCopy = {};
  Object.assign(trackedCourseCopy, trackedCourse);

  try {
    await db
      .collection("users")
      .doc(userId)
      .update({
        tracking: FieldValue.arrayUnion(trackedCourse),
      });

    // Update Tracked Courses
    await addTrackedCourses(trackedCourse, deviceId);

    return constants.successResponse(trackedCourseCopy, 201, res);
  } catch (error) {
    return constants.errorResponse("Unable to track the course", 500, res);
  }
});

/**
 * This route updates a device ID for a user
 *
 * - device_id (String): the device ID (FCM token)
 * - user_id (String): the user's ID
 */
app.post("/token-update/", async (req, res) => {
  const deviceId = req.body.device_id;
  const userId = req.body.user_id;

  if (userId == null || deviceId == null) {
    return constants.errorResponse(
      "Invalid device ID or user ID specified",
      404,
      res
    );
  }

  const docRef = db.collection("users").doc(userId);
  let doc = await docRef.get();

  if (!doc.exists) {
    return constants.errorResponse("Unable to find the user", 500, res);
  } else {
    // Get old device ID
    const oldData = await docRef.get();
    const oldId = oldData.data().device_id;

    if (oldId == deviceId) {
      return constants.successResponse(oldData.data(), 200, res);
    }

    // Overwrite the device ID
    await docRef.update({ device_id: deviceId });

    // Go through every course and update device ID
    const snapshot = await db
      .collection("courses")
      .where("device_ids", "array-contains", oldId)
      .get();

    snapshot.forEach(async (doc) => {
      await db
        .collection("courses")
        .doc(doc.id)
        .update({ device_ids: FieldValue.arrayRemove(oldId) });
      await db
        .collection("courses")
        .doc(doc.id)
        .update({ device_ids: FieldValue.arrayUnion(deviceId) });
    });

    doc = await docRef.get();

    return constants.successResponse(doc.data(), 201, res);
  }
});

/**
 * This route fetches a user given the user ID and device ID
 *
 * If the user does not exist, create a new user.
 *
 * - device_id (String): the device ID (FCM token)
 * - email (String): the user's email address
 * - user_id (String): the user's ID
 */
app.post("/fetch/", async (req, res) => {
  const deviceId = req.body.device_id;
  const email = req.body.email;
  const userId = req.body.user_id;

  if (userId == null || deviceId == null || email == null) {
    return constants.errorResponse(
      "Invalid device ID, email, or user ID specified",
      404,
      res
    );
  }

  const docRef = db.collection("users").doc(userId);
  let doc = await docRef.get();

  if (!doc.exists) {
    // Create a new user
    const user = {
      id: userId,
      device_id: deviceId,
      email: email,
      tracking: [],
    };

    try {
      await docRef.set(user);
      return constants.successResponse(user, 201, res);
    } catch (error) {
      return constants.errorResponse("Unable to create the user", 500, res);
    }
  }

  return constants.successResponse(doc.data(), 200, res);
});

exports.user = onRequest({ region: "us-east1" }, app);
