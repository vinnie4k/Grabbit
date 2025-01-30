/**
 * Interface representing a user.
 */
export interface User {
  /**
   * The ID of the user.
   */
  id: string;

  /**
   * The device ID of the user.
   */
  deviceId: string;

  /**
   * The email of the user.
   */
  email: string;

  /**
   * The list of section IDs the user is tracking.
   */
  tracking: string[];
}
