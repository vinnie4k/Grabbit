const { getFirestore } = require("firebase-admin/firestore");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { logger } = require("firebase-functions");

// Constants
const db = getFirestore();
const tracking = require("../controllers/tracking");

// ======= Scheduled Functions =======

/**
 * This scheduled function fetches class roster updates every 60 seconds
 */
exports.fetchUpdates = onSchedule("* * * * *", async () => {
  logger.log("Fetched courses");

  // Update each document in `courses` collection
  const docs = await db.collection("courses").get();
  docs.forEach(async (doc) => {
    const data = doc.data();
    await tracking.updateTrackingStatus(
      data.course_id,
      data.device_ids,
      data.number,
      data.section_id,
      data.section_title,
      data.status,
      data.subject
    );
  });
});

// /**
//  * This scheduled function fetches class roster updates every 5 seconds
//  */
// exports.fetchUpdates = onSchedule("* * * * *", async () => {
//   setInterval(async function () {
//     logger.log("Fetched courses");

//     // Update each document in `courses` collection
//     const docs = await db.collection("courses").get();
//     docs.forEach(async (doc) => {
//       const data = doc.data();
//       await tracking.updateTrackingStatus(
//         data.course_id,
//         data.device_ids,
//         data.number,
//         data.section_id,
//         data.section_title,
//         data.status,
//         data.subject
//       );
//     });
//   }, 5000);
// });
