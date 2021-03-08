import { DateTime } from "luxon";
import * as types from "@reactjs/types";

export const parseTimeSlot = (timeSlot: string): types.TimeSlot => {
  const [start, end] = timeSlot
    .split("::")
    .map((v) => DateTime.fromSeconds(parseInt(v, 10)));
  return { start, end };
};
