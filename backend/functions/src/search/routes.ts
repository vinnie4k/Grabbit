import { Request, Response, Router } from "express";
import { InvalidArgumentError } from "../utils/errors";
import { SearchService } from "./services";

export const searchRouter = Router();

/**
 * Search for a course from the Cornell API.
 */
searchRouter.get("/", async (req: Request, res: Response): Promise<any> => {
  const subject = req.query.subject as string | undefined;
  const number = req.query.number as string | undefined;

  if (!subject || !number) {
    throw new InvalidArgumentError("Invalid arguments supplied");
  }

  const result = await SearchService.searchClass(subject, number);
  return res.status(200).json(result);
});

export default searchRouter;
