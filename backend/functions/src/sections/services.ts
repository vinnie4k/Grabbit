import { FieldValue } from "firebase-admin/firestore";
import { db } from "..";
import { SECTION_COLLECTION } from "../utils/constants";
import { SectionStatus } from "../utils/sectionStatus";
import { Section } from "./models";

export class SectionService {
  /**
   * Fetches all sections from the database.
   *
   * @returns Array of sections
   */
  static async getAllSections(): Promise<Section[]> {
    const ref = db.collection(SECTION_COLLECTION);
    const snapshot = await ref.get();
    const sections = snapshot.docs.map((doc) => doc.data() as Section);
    return sections;
  }

  /**
   * Get multiple sections from the database in a single batch read.
   *
   * @param ids Array of section IDs to fetch
   * @returns Array of sections
   */
  static async getSections(ids: number[]): Promise<Section[]> {
    if (!ids.length) return [];

    // Convert ids to strings since document IDs must be strings
    const docRefs = ids.map((id) =>
      db.collection(SECTION_COLLECTION).doc(id.toString())
    );

    // Get all documents in a single batch
    const docs = await db.getAll(...docRefs);
    const sections = docs
      .filter((doc) => doc.exists)
      .map((doc) => doc.data() as Section);

    return sections;
  }

  /**
   * Adds or updates a section with a user ID.
   *
   * If the section already exists, the user ID will be added to the existing section.
   * If the section does not exist, it will be created with the user ID.
   *
   * @param section The section to track.
   * @param userId The user ID to track.
   */
  static async trackSection(section: Section, userId: string): Promise<void> {
    const ref = db
      .collection(SECTION_COLLECTION)
      .doc(section.sectionId.toString());
    const doc = await ref.get();

    if (doc.exists) {
      await ref.update({
        userIds: FieldValue.arrayUnion(userId),
      });
    } else {
      section.userIds = [userId];
      await ref.set(section);
    }
  }

  /**
   * Removes a user ID from a section.
   *
   * If there are no more user IDs, the section will be deleted.
   *
   * @param sectionId The section ID to remove the user ID from.
   * @param userId The user ID to remove.
   */
  static async untrackSection(
    sectionId: number,
    userId: string
  ): Promise<void> {
    const ref = db.collection(SECTION_COLLECTION).doc(sectionId.toString());
    const doc = await ref.get();

    if (!doc.exists) {
      throw new Error("Section not found");
    }

    const section = doc.data() as Section;

    if (
      section.userIds &&
      section.userIds.length === 1 &&
      section.userIds[0] === userId
    ) {
      // Remove the section if there is only one user ID
      await ref.delete();
    } else {
      // Remove the user ID from the section
      await ref.update({
        userIds: FieldValue.arrayRemove(userId),
      });
    }
  }

  /**
   * Removes a user ID from all sections.
   *
   * @param userId The user ID to remove.
   */
  static async removeUserFromSections(userId: string): Promise<void> {
    const ref = db
      .collection(SECTION_COLLECTION)
      .where("userIds", "array-contains", userId);
    const snapshot = await ref.get();

    const batch = db.batch();

    snapshot.docs.forEach((doc) => {
      const section = doc.data() as Section;
      if (
        section.userIds &&
        section.userIds.length === 1 &&
        section.userIds[0] === userId
      ) {
        // Delete the section if this is the only user
        batch.delete(doc.ref);
      } else {
        // Remove the user from the userIds array
        batch.update(doc.ref, {
          userIds: FieldValue.arrayRemove(userId),
        });
      }
    });

    await batch.commit();
  }

  static async updateSectionStatus(section: Section, newStatus: SectionStatus) {
    const ref = db
      .collection(SECTION_COLLECTION)
      .doc(section.sectionId.toString());
    await ref.update({
      status: newStatus,
    });
  }
}
