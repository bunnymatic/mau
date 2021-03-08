import { DateTime } from 'luxon';
import { MauCheckboxField } from "@reactjs/components/mau_checkbox_field";
import { parseTimeSlot } from '@js/app/time_utils';
import * as types from "@reactjs/types";
import React, {FC} from 'react';

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

const generateSlotFieldName = (timeslot: string): string =>
  `videoConferenceSchedule[${timeslot}]`;

const formatTimeSlot = (timeslot: types.TimeSlot): string => {
  const { start, end } = timeslot;
  return `${start.toLocaleString(DateTime.TIME_SIMPLE)} - ${end.toLocaleString(
    DateTime.TIME_SIMPLE
  )} ${start.toLocaleString(DateTime.DATE_MED)} `;
};

const TimeSlotCheckBox: FC<TimeSlotCheckBoxProps> = ({ timeslot, name }) => {
  const label = formatTimeSlot(timeslot);
  return <MauCheckboxField label={label} name={name} />;
};

export const SpecialEventScheduleFields: FC<SpecialEventScheduleFieldsProps> = ({
  specialEvent,
}) => {
  if (!specialEvent?.timeSlots) {
    return null;
  }
  const slots = specialEvent.timeSlots;

  return (
    <div className="open-studios-info-form__special-event-schedule">
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