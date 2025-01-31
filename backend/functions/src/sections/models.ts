import { SectionStatus } from "../utils/sectionStatus";

/**
 * Interface representing a section.
 */
export interface Section {
  /**
   * The ID of the course.
   */
  courseId: number;

  /**
   * The title of the course.
   */
  courseTitle: string;

  /**
   * The number of the course.
   */
  number: number;

  /**
   * The pattern of the course.
   */
  pattern: string;

  /**
   * The ID of the section.
   */
  sectionId: number;

  /**
   * The title of the section.
   */
  sectionTitle: string;

  /**
   * The status of the section.
   */
  status: SectionStatus;

  /**
   * The subject of the course.
   */
  subject: string;

  /**
   * The end time of the course.
   */
  timeEnd: string;

  /**
   * The start time of the course.
   */
  timeStart: string;

  /**
   * The list of user IDs that are tracking the section.
   */
  userIds: string[];
}
