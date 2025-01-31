import { CLOSED_MARKER, OPEN_MARKER, WAITLISTED_MARKER } from "./constants";

/**
 * Enum representing the status of a course.
 */
export enum SectionStatus {
  OPEN = OPEN_MARKER,
  CLOSED = CLOSED_MARKER,
  WAITLISTED = WAITLISTED_MARKER,
}
