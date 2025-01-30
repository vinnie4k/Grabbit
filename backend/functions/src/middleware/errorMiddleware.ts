import { NextFunction, Request, Response } from "express";
import { InvalidArgumentError } from "../utils/errors";

export const errorMiddleware = (
  err: unknown,
  req: Request,
  res: Response,
  next: NextFunction
): Response | void => {
  // User input error
  if (err instanceof InvalidArgumentError) {
    return res.status(400).json({
      name: err.name,
      details: err.message,
    });
  }

  // Handle all other errors
  if (err instanceof Error) {
    return res.status(500).json({
      name: err.name,
      details: err.message,
    });
  }

  next();
};
