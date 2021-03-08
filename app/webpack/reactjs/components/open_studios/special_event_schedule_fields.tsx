import { MauCheckboxField } from "@reactjs/components/mau_checkbox_field";
import * as types from "@reactjs/types";
import { DateTime } from "luxon";
import React, { FC } from "react";

interface SpecialEventScheduleFieldsProps {
  specialEvent: types.SpecialEventDetails;
}

interface TimeSlot {
  start: string;
  end: string;
}

interface TimeSlotCheckBoxProps {
  timeslot: TimeSlot;
  name: string;
}

export const parseTimeSlot = (timeSlot: string): types.TimeSlot => {
  const [start, end] = timeSlot
    .split("::")
    .map((v) => DateTime.fromSeconds(parseInt(v, 10)));
  return { start, end };
};

const generateSlotFieldName = (timeslot: string): string =>
  `videoConferenceSchedule[${timeslot}]`;

export const formatTimeSlot = (timeslot: types.TimeSlot): string => {
  const { start, end } = timeslot;
  return `${start.toLocaleString(DateTime.TIME_SIMPLE)} - ${end.toLocaleString(
    DateTime.TIME_SIMPLE
  )} ${start.toLocaleString(DateTime.DATE_MED)} `;
};

const TimeSlotCheckBox: FC<TimeSlotCheckBoxProps> = ({ timeslot, name }) => {
  const label = formatTimeSlot(timeslot);
  return (
    <MauCheckboxField
      classes="open-studios-info-form__special-event-schedule__timeslot"
      label={label}
      name={name}
    />
  );
};

export const SpecialEventScheduleFields: FC<SpecialEventScheduleFieldsProps> = ({
  specialEvent,
}) => {
  if (!specialEvent?.timeSlots) {
    return null;
  }
  const slots = specialEvent.timeSlots;

  return (
    <div
      className="open-studios-info-form__special-event-schedule"
      data-testid="open-studios-info-form__special-event-schedule"
    >
      <div className="open-studios-info-form__special-event-schedule__label">
        I will be open for virtual visitors the following hours.
      </div>
      {slots.map((slot: string) => {
        const parsed = parseTimeSlot(slot);
        const slotName = generateSlotFieldName(slot);
        return (
          <TimeSlotCheckBox key={slotName} timeslot={parsed} name={slotName} />
        );
      })}
    </div>
  );
};
