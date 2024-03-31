import { MauCheckboxField } from "@reactjs/components/form_fields";
import * as types from "@reactjs/types";
import cx from "classnames";
import { DateTime } from "luxon";
import React, { FC } from "react";

interface TimeSlot {
  start: string;
  end: string;
}

const parseTimeSlot = (timeSlot: string): TimeSlot => {
  const [start, end] = timeSlot
    .split("::")
    .map((v) =>
      DateTime.fromSeconds(parseInt(v, 10), { zone: "America/Los_Angeles" })
    );
  return { start, end };
};

const formatTimeSlot = (timeslot: TimeSlot): string => {
  const { start, end } = timeslot;
  return `${start.toLocaleString(DateTime.TIME_SIMPLE)} - ${end.toLocaleString(
    DateTime.TIME_SIMPLE
  )}`;
};

interface TimeSlotCheckBoxProps {
  timeslot: TimeSlot;
  name: string;
  disabled?: boolean;
}

const TimeSlotCheckBox: FC<TimeSlotCheckBoxProps> = ({
  timeslot,
  name,
  disabled,
}) => {
  const label = formatTimeSlot(timeslot);
  return (
    <MauCheckboxField
      classes="special-event-schedule__timeslot"
      label={label}
      name={name}
      disabled={disabled}
    />
  );
};

const generateSlotFieldName = (timeslot: string): string =>
  `videoConferenceSchedule[${timeslot}]`;

interface TimeSlotInfo {
  slot: string;
  fieldName: string;
  parsed: TimeSlot;
}

const timeSlotsByDay = (
  timeslots: string[]
): Record<string, TimeSlotInfo[]> => {
  return timeslots.reduce((memo, rawSlot) => {
    const timeSlot = parseTimeSlot(rawSlot);
    const day = timeSlot.start.toFormat("cccc, L/d/yy ZZZZ");
    const info = {
      parsed: timeSlot,
      slot: rawSlot,
      fieldName: generateSlotFieldName(rawSlot),
    };

    memo[day] ||= [];
    memo[day].push(info);
    return memo;
  }, {});
};

interface SpecialEventScheduleFieldsProps {
  specialEvent: types.SpecialEventDetails;
  disabled?: boolean;
}

export const SpecialEventScheduleFields: FC<
  SpecialEventScheduleFieldsProps
> = ({ specialEvent, disabled }) => {
  if (!specialEvent?.timeSlots) {
    return null;
  }
  return (
    <div
      className={cx("special-event-schedule", {
        "special-event-schedule--disabled": disabled,
      })}
      data-testid="special-event-schedule"
    >
      <div className="special-event-schedule__label">
        I will be open for virtual visitors the following hours.
      </div>
      <div className="pure-g">
        {Object.entries(timeSlotsByDay(specialEvent.timeSlots)).map(
          ([day, slotInfos]) => {
            return (
              <div
                className="pure-u-1-1 pure-u-sm-1-2 special-event-schedule__section"
                key={day}
              >
                <div className="special-event-schedule__day-title">{day}</div>
                {slotInfos.map(({ parsed: slot, fieldName }) => (
                  <TimeSlotCheckBox
                    key={slot.start}
                    timeslot={slot}
                    name={fieldName}
                    disabled={disabled}
                  />
                ))}
              </div>
            );
          }
        )}
      </div>
    </div>
  );
};
