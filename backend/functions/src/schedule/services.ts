import { getMessaging } from "firebase-admin/messaging";
import { logger } from "firebase-functions/v2";
import { Section } from "../sections/models";
import { SectionService } from "../sections/services";
import UserService from "../users/services";
import { ROSTER_URL } from "../utils/constants";
import { SectionStatus } from "../utils/sectionStatus";

export class ScheduleService {
  /**
   * Fetches the new status of all sections from the database.
   */
  static async fetchUpdates() {
    const sections = await SectionService.getAllSections();
    await this.fetchUpdatesForSections(sections);
  }

  /**
   * Fetches the new status of a section from the Cornell API.
   *
   * @param sections The sections to fetch the new status for.
   */
  private static async fetchUpdatesForSections(sections: Section[]) {
    // Process all sections in parallel
    await Promise.all(
      sections.map(async (section) => {
        try {
          const newStatus = await this.newSectionStatus(section);

          // Only notify if status is from closed/waitlisted to open
          if (
            (section.status == SectionStatus.CLOSED ||
              section.status == SectionStatus.WAITLISTED) &&
            newStatus == SectionStatus.OPEN
          ) {
            // Run notification and database update in parallel
            await Promise.all([
              this.sendNotification(
                `Quick! The section code is ${section.sectionId}.`,
                `${section.subject} ${section.number} ${section.sectionTitle} is Open!`,
                section.userIds
              ),
              SectionService.updateSectionStatus(section, newStatus),
            ]);
          } else {
            // If no notification needed, just update the database
            await SectionService.updateSectionStatus(section, newStatus);
          }
        } catch (error) {
          logger.error(
            `Error fetching updates for section ${section.sectionId}:`,
            error
          );
        }
      })
    );
  }

  /**
   * Sends a notification to the users tracking the section.
   *
   * @param body The body of the notification.
   * @param title The title of the notification.
   * @param userIds The IDs of the users to send the notification to.
   */
  private static async sendNotification(
    body: string,
    title: string,
    userIds: string[]
  ) {
    try {
      const tokens = await UserService.fetchTokens(userIds);
      const message = {
        notification: {
          title,
          body,
        },
        tokens,
      };
      await getMessaging().sendEachForMulticast(message);
    } catch (error) {
      logger.error("Error sending notifications:", error);
    }
  }

  /**
   * Fetches the new status of a section from the Cornell API.
   *
   * @param section The section to fetch the new status for.
   * @returns The new status of the section.
   */
  private static async newSectionStatus(
    section: Section
  ): Promise<SectionStatus> {
    try {
      // Fetch the class from the Cornell API
      const response = await fetch(
        `${ROSTER_URL}&subject=${section.subject}&classLevels%5B%5D=${String(
          section.number
        ).charAt(0)}000`
      );
      const fetchedClasses = (await response.json()).data.classes;

      // Find the course
      const fetchedClass = fetchedClasses.find(
        (c: any) => c.crseId == section.courseId
      );

      // Find the section
      const fetchedSection = fetchedClass.enrollGroups
        .flatMap((group: any) => group.classSections)
        .find((section: any) => section.classNbr == section.sectionId);

      // Convert string to enum
      if (fetchedSection.openStatus == SectionStatus.OPEN) {
        return SectionStatus.OPEN;
      } else if (fetchedSection.openStatus == SectionStatus.CLOSED) {
        return SectionStatus.CLOSED;
      } else {
        return SectionStatus.WAITLISTED;
      }
    } catch (error) {
      throw error; // Re-throw to handle in the calling function
    }
  }
}

export default ScheduleService;
