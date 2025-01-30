import { FieldValue } from "firebase-admin/firestore";
import { db } from "..";
import { USER_COLLECTION } from "../utils/constants";
import { User } from "./models";

class UserService {
  /**
   * Fetch a user from the database.
   *
   * If the user does not exist, create a new user.
   *
   * @param id The ID of the user.
   * @param deviceId The device ID of the user.
   * @param email The email of the user.
   */
  static async fetchUser(
    id: string,
    deviceId: string,
    email: string
  ): Promise<User> {
    const ref = db.collection(USER_COLLECTION).doc(id);
    const doc = await ref.get();
    const user = doc.data();

    // If the user does not exist, create a new user
    if (!user) {
      const newUser: User = {
        id,
        deviceId,
        email,
        tracking: [],
      };

      await ref.set(newUser);
      return newUser;
    }

    // If the user exists, update the device ID and email
    await ref.update({ deviceId, email });

    return user as User;
  }

  /**
   * Adds a section to the user's tracking list.
   *
   * @param userId The ID of the user.
   * @param sectionId The ID of the section.
   */
  static async trackSection(userId: string, sectionId: string): Promise<void> {
    const ref = db.collection(USER_COLLECTION).doc(userId);
    await ref.update({
      tracking: FieldValue.arrayUnion(sectionId),
    });
  }

  /**
   * Removes a section from the user's tracking list.
   *
   * @param userId The ID of the user.
   * @param sectionId The ID of the section.
   */
  static async untrackSection(
    userId: string,
    sectionId: string
  ): Promise<void> {
    const ref = db.collection(USER_COLLECTION).doc(userId);
    await ref.update({
      tracking: FieldValue.arrayRemove(sectionId),
    });
  }

  /**
   * Deletes a user from the database.
   *
   * @param userId The ID of the user.
   */
  static async deleteUser(userId: string): Promise<void> {
    const ref = db.collection(USER_COLLECTION).doc(userId);
    await ref.delete();
  }

  /**
   * Fetches the device tokens of the users.
   *
   * @param userIds The IDs of the users.
   * @returns The device tokens of the users.
   */
  static async fetchTokens(userIds: string[]): Promise<string[]> {
    const ref = db.collection(USER_COLLECTION).where("id", "in", userIds);
    const snapshot = await ref.get();
    const users = snapshot.docs.map((doc) => doc.data() as User);

    return users.map((user) => user.deviceId);
  }
}

export default UserService;
