import { all } from "@js/app/helpers";
import { renderInForm } from "@reactjs/test/renderers";
import { screen } from "@testing-library/react";
import React from "react";
import { describe, it, expect, beforeEach } from 'vitest'
import { SpecialEventScheduleFields } from "./special_event_schedule_fields";

describe("SpecialEventScheduleFields", () => {
  let rendered;
  const event = {
    dateRange: "Nov 12-13 2020",
    timeSlots: [
      "1605128400::1605132000",
      "1605132000::1605135600",
      "1605215000::1605218800",
      "1605218800::1605222400",
    ],
  };

  describe("when the component is enabled", () => {
    beforeEach(() => {
      rendered = renderInForm(
        <SpecialEventScheduleFields specialEvent={event} />
      );
    });

    it("shows the intro message", () => {
      expect(
        screen.queryByText("I will be open for virtual visitors", {
          exact: false,
        })
      ).toBeInTheDocument();
    });

    it("shows check boxes grouped by date", () => {
      expect(
        screen.queryByText("Wednesday, 11/11/20 PST", { exact: false })
      ).toBeInTheDocument();
      expect(screen.queryByText("1:00 PM - 2:00 PM")).toBeInTheDocument();
      expect(screen.queryByText("2:00 PM - 3:00 PM")).toBeInTheDocument();

      expect(
        screen.queryByText("Thursday, 11/12/20 PST", { exact: false })
      ).toBeInTheDocument();
      expect(screen.queryByText("1:03 PM - 2:06 PM")).toBeInTheDocument();
      expect(screen.queryByText("2:06 PM - 3:06 PM")).toBeInTheDocument();
    });

    it("renders checkboxes enabled", () => {
      const cbs = Array.from(rendered.container.getElementsByTagName("INPUT"));

      expect(cbs).toHaveLength(4);
      expect(all(cbs, (cb) => !cb.disabled)).toBeTruthy();
    });
  });
  describe("when the component is disabled", () => {
    beforeEach(() => {
      rendered = renderInForm(
        <SpecialEventScheduleFields specialEvent={event} disabled={true} />
      );
    });
    it("renders checkboxes disabled", () => {
      const cbs = Array.from(rendered.container.getElementsByTagName("INPUT"));

      expect(cbs).toHaveLength(4);
      expect(all(cbs, (cb) => cb.disabled)).toBeTruthy();
    });
  });
});
