import { DateTime } from "luxon";

import { parseTimeSlot } from "./time_utils";

describe("time_utils", () => {
  describe("parseTimeSlot", () => {
    beforeEach(() => {
      DateTime.local().setZone("America/Los_Angeles");
    });
    it("returns timeslots parsed into date times", () => {
      expect(parseTimeSlot("1605135600::1605139200")).toEqual({
        start: DateTime.local(2020, 11, 11, 15, 0, 0),
        end: DateTime.local(2020, 11, 11, 16, 0, 0),
      });
    });
  });
});
