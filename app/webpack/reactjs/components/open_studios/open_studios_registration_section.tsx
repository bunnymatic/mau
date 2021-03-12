import { ConfirmModal } from "@reactjs/components/confirm_modal";
import { OpenStudiosInfoForm } from "@reactjs/components/open_studios/open_studios_info_form";
import { submitRegistration } from "@reactjs/components/open_studios/submit_registration";
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
  openStudiosEvent: event,
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
    message = `Yay! You are currently registered for Open Studios on ${event.dateRange}`;
  } else {
    message = `Will you be participating in Open Studios on ${event.dateRange}`;
  }

  const handleRegistration = (registering: boolean) => {
    return submitRegistration(registering).then((data) => {
      setParticipant(data.participant);
    });
  };
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
          openStudiosEvent={event}
          participant={participant}
        />
      ) : (
        <ConfirmModal
          buttonText="Yes - Register Me"
          buttonStyle="primary"
          handleConfirm={handleRegistration}
        >
          <p>
            This will register you as a participating artist for Open Studios,{" "}
            {event.dateRange}.
          </p>
          <p>Would you like to continue?</p>
        </ConfirmModal>
      )}
    </div>
  );
};
