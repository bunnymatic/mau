import { DateTime } from "luxon";
import * as types from "@reactjs/types";

const SECONDS_TO_MILLISECONDS = 1000;
export const parseTimeSlot = (timeSlot: string): types.TimeSlot => {
  const [start, end] = timeSlot
    .split("::")
    .map((v) => DateTime.fromMillis(v * SECONDS_TO_MILLISECONDS));
  return { start, end };
};
