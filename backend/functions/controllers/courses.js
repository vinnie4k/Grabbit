// Firebase SDK
const { onRequest } = require("firebase-functions/v2/https");

// Other Dependencies
const express = require("express");
const app = express();
const cors = require("cors");
app.use(cors({ origin: true }));
app.use(express.json());

// Constants
const constants = require("../supporting/constants");

// ======= Helpers =======

/**
 * Search for a course from the Cornell API
 *
 * @param {string} subject the subject of the course in all CAPS (e.g. "MATH")
 * @param {number} number the number of the course (e.g. 1920)
 * @returns a list of formatted classes
 */
async function searchClass(subject, number) {
  const response = await fetch(
    `${constants.ROSTER_URL}&subject=${subject}&classLevels%5B%5D=${String(
      number
    ).charAt(0)}000`
  );

  const data = await response.json();
  const classes = data["data"]["classes"];

  const result = classes.filter((val) => {
    // First numbers match
    const length = String(number).length;
    const sub = String(val.catalogNbr).substring(0, length);
    return sub == String(number);
  });

  return formatCourses(result);
}

/**
 * Formats a list of courses to only include the following:
 * - id: Integer
 * - number: String
 * - sections: list of dictionaries representing a section
 * - subject: String
 * - title: String
 *
 * @param {Array} arr the list of courses to be formatted
 * @returns a list of formatted courses
 */
function formatCourses(arr) {
  return arr.map((oldDict) => {
    const newDict = {};
    newDict["id"] = oldDict.crseId;
    newDict["number"] = oldDict.catalogNbr;
    newDict["sections"] = oldDict.enrollGroups.flatMap((d) =>
      formatSections(d.classSections)
    );
    newDict["subject"] = oldDict.subject;
    newDict["title"] = oldDict.titleLong;
    return newDict;
  });
}

/**
 * Formats a list of sections to only include the following:
 * - id: Integer
 * - pattern: String
 * - section: String
 * - status: String
 * - timeEnd: String
 * - timeStart: String
 * - type: String
 *
 * @param {Array} arr the list of sections to be formatted
 * @returns a list of formatted sections
 */
function formatSections(arr) {
  return arr.map((oldDict) => {
    const sectionDict = oldDict;
    const newDict = {};
    newDict["id"] = sectionDict.classNbr;
    newDict["pattern"] = sectionDict.meetings[0].pattern;
    newDict["section"] = sectionDict.section;
    newDict["status"] = sectionDict.openStatus;
    newDict["timeEnd"] = sectionDict.meetings[0].timeEnd;
    newDict["timeStart"] = sectionDict.meetings[0].timeStart;
    newDict["type"] = sectionDict.ssrComponent;
    return newDict;
  });
}

// ======= Routes =======

/**
 * This route fetches for courses given a subject and number
 *
 * - subject (String): the course subject (e.g. "MATH")
 * - number (Integer): the course number (e.g. 1920)
 */
app.post("/search/", async (req, res) => {
  const subject = req.body.subject;
  const number = req.body.number;

  if (subject == null || number == null) {
    return constants.errorResponse(
      "Invalid subject or number specified",
      404,
      res
    );
  }

  try {
    const result = await searchClass(subject, number);
    return constants.successResponse(result, 200, res);
  } catch (error) {
    return constants.errorResponse(
      "Invalid subject or number specified",
      404,
      res
    );
  }
});

exports.courses = onRequest({ region: "us-east1" }, app);
