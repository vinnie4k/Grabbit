import bodyParser from "body-parser";
import cors from "cors";
import express from "express";
import admin from "firebase-admin";
import { getFirestore } from "firebase-admin/firestore";
import { onSchedule } from "firebase-functions/scheduler";
import { onRequest } from "firebase-functions/v2/https";
import { errorMiddleware } from "./middleware/errorMiddleware";
import { ScheduleService } from "./schedule/services";
import searchRouter from "./search/routes";
import { userRouter } from "./users/routes";

// Initialize Firebase Admin SDK
admin.initializeApp({
  credential: admin.credential.cert("./service_account_key.json"),
});

/**
 * The Firestore database.
 */
export const db = getFirestore();

/**
 * The Express application.
 */
export const app = express();
app.use(cors({ origin: true }));
app.use(bodyParser.json());
app.use("/users", userRouter);
app.use("/search", searchRouter);

// Error middleware should be registered last, after all routes
// and should not use app.use() directly
app.use(
  (
    err: unknown,
    req: express.Request,
    res: express.Response,
    next: express.NextFunction
  ) => {
    errorMiddleware(err, req, res, next);
  }
);

/**
 * The API endpoint.
 */
export const api = onRequest({ region: "us-east1" }, app);

/**
 * This scheduled function fetches class roster updates every 60 seconds.
 */
export const fetchUpdates = onSchedule("* * * * *", async () => {
  await ScheduleService.fetchUpdates();
});
