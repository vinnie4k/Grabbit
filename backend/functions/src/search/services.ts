import { ROSTER_URL } from "../utils/constants";

export class SearchService {
  /**
   * Search for a course from the Cornell API.
   *
   * @param {string} subject The subject of the course in all CAPS (e.g. "MATH").
   * @param {string} number The number of the course (e.g. 1920).
   * @returns A list of formatted classes.
   */
  static async searchClass(subject: string, number: string): Promise<any> {
    // Fetch the class from the Cornell API
    const response = await fetch(
      `${ROSTER_URL}&subject=${subject}&classLevels%5B%5D=${number
        .toString()
        .charAt(0)}000`
    );
    const classes = (await response.json()).data.classes;

    // Filter the classes to only include the ones that match the first given digits
    const result = classes.filter((val: any) => {
      const length = number.toString().length;
      const sub = val.catalogNbr.toString().substring(0, length);
      return sub == number.toString();
    });

    return SearchService.formatCourses(result);
  }

  /**
   * Formats a list of courses to only include the following:
   * - id: Integer
   * - number: String
   * - sections: list of dictionaries representing a section
   * - subject: String
   * - title: String
   *
   * @param {Array} arr The list of courses to be formatted.
   * @returns A list of formatted courses.
   */
  private static formatCourses(arr: any[]): any {
    return arr.map((oldDict) => {
      const newDict: any = {};

      newDict["id"] = oldDict.crseId;
      newDict["number"] = oldDict.catalogNbr;
      newDict["sections"] = oldDict.enrollGroups.flatMap((d: any) =>
        SearchService.formatSections(d.classSections)
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
   * @param {Array} arr The list of sections to be formatted.
   * @returns A list of formatted sections.
   */
  private static formatSections(arr: any[]): any {
    return arr.map((oldDict) => {
      const sectionDict = oldDict;
      const newDict: any = {};

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
}
