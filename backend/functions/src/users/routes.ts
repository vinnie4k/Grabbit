import { Request, Response, Router } from "express";
import { Section } from "../sections/models";
import { SectionService } from "../sections/services";
import { InvalidArgumentError } from "../utils/errors";
import { SectionStatus } from "../utils/sectionStatus";
import { default as UserService } from "./services";

export const userRouter = Router();

/**
 * Delete a user from the database.
 */
userRouter.delete(
  "/delete/:userId",
  async (req: Request, res: Response): Promise<any> => {
    const userId: string = req.params.userId;

    if (!userId) {
      throw new InvalidArgumentError("Invalid arguments supplied");
    }

    await UserService.deleteUser(userId);
    await SectionService.removeUserFromSections(userId);

    return res.status(200).json({ message: "User deleted" });
  }
);

/**
 * Untrack a section for a user.
 */
userRouter.post(
  "/untrack/:userId",
  async (req: Request, res: Response): Promise<any> => {
    const userId: string = req.params.userId;
    const sectionId: number = req.body.sectionId;

    if (!userId || !sectionId) {
      throw new InvalidArgumentError("Invalid arguments supplied");
    }

    await UserService.untrackSection(userId, sectionId);
    await SectionService.untrackSection(sectionId, userId);

    return res.status(200).json({ message: "Section untracked" });
  }
);

/**
 * Track a section for a user.
 */
userRouter.post(
  "/track/:userId",
  async (req: Request, res: Response): Promise<any> => {
    // User
    const userId: string = req.params.userId;

    // Section
    const courseId: number = req.body.courseId;
    const courseTitle: string = req.body.courseTitle;
    const number: number = req.body.number;
    const pattern: string = req.body.pattern;
    const sectionId: number = req.body.sectionId;
    const sectionTitle: string = req.body.sectionTitle;
    const status: SectionStatus = req.body.status;
    const subject: string = req.body.subject;
    const timeEnd: string = req.body.timeEnd;
    const timeStart: string = req.body.timeStart;

    if (
      !userId ||
      !courseId ||
      !courseTitle ||
      !number ||
      !pattern ||
      !sectionId ||
      !sectionTitle ||
      !status ||
      !subject ||
      !timeEnd ||
      !timeStart
    ) {
      throw new InvalidArgumentError("Invalid arguments supplied");
    }

    const section: Section = {
      courseId,
      courseTitle,
      number,
      pattern,
      sectionId,
      sectionTitle,
      status,
      subject,
      timeEnd,
      timeStart,
      userIds: [userId],
    };

    await UserService.trackSection(userId, sectionId);
    await SectionService.trackSection(section, userId);

    return res.status(200).json({ message: "Section tracked" });
  }
);

/**
 * Fetch a user from the database.
 */
userRouter.post(
  "/fetch/:userId",
  async (req: Request, res: Response): Promise<any> => {
    const deviceId: string = req.body.deviceId;
    const email: string = req.body.email;
    const userId: string = req.params.userId;

    if (!deviceId || !email || !userId) {
      throw new InvalidArgumentError("Invalid arguments supplied");
    }

    const user = await UserService.fetchUser(userId, deviceId, email);
    const sections = await SectionService.getSections(user.tracking);

    return res.status(200).json({
      id: user.id,
      deviceId: user.deviceId,
      email: user.email,
      tracking: sections,
    });
  }
);

export default userRouter;
