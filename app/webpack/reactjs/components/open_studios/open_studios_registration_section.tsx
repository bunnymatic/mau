import { OpenStudiosInfoForm } from "@reactjs/components/open_studios/open_studios_info_form";
import { RegistrationModal } from "@reactjs/components/open_studios/registration_modal";
import * as types from "@reactjs/types";
import cx from "classnames";
import React, { FC, useState } from "react";

interface OpenStudiosRegistrationSectionProps {
  location: string;
  openStudiosEvent: types.OpenStudiosEvent;
  artistId: number;
  participant: types.OpenStudiosParticipant | null;
}

export const OpenStudiosRegistrationSection: FC<OpenStudiosRegistrationSectionProps> = ({
  location,
  openStudiosEvent,
  artistId,
  participant: initialParticipant,
}) => {
  const [
    participant,
    setParticipant,
  ] = useState<types.OpenStudiosParticipant | null>(initialParticipant);
  const isParticipating = Boolean(participant);

  let message: string;
  if (isParticipating) {
    message = `Yay! You are currently registered for Open Studios on ${openStudiosEvent.dateRange}`;
  } else {
    message = `Will you be participating in Open Studios on ${openStudiosEvent.dateRange}`;
  }
  return (
    <div
      className={cx({
        "open-studios-registration--participating": isParticipating,
      })}
    >
      <p>{message}</p>
      {isParticipating ? (
        <OpenStudiosInfoForm
          artistId={artistId}
          location={location}
          onUpdateParticipant={setParticipant}
          openStudiosEvent={openStudiosEvent}
          participant={participant}
        />
      ) : (
        <RegistrationModal
          artistId={artistId}
          location={location}
          onUpdateParticipant={setParticipant}
          openStudiosEvent={openStudiosEvent}
          buttonText="Yes - Register Me"
          buttonStyle={{ primary: true }}
        />
      )}
    </div>
  );
};
