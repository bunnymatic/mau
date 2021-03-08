import { parseTimeSlot } from "./special_event_schedule_fields";
import { DateTime } from "luxon";

describe("parseTimeSlot", () => {
  it("returns timeslots parsed into date times", () => {
    expect(parseTimeSlot("1605135600::1605139200")).toEqual({
      start: DateTime.fromSeconds(1605135600),
      end: DateTime.fromSeconds(1605139200),
    });
  });
});
