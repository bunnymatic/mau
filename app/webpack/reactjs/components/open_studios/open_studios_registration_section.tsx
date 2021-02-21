import { MauModal, setAppElement } from "@reactjs/components/mau_modal";
import { OpenStudiosInfoForm } from "@reactjs/components/open_studios/open_studios_info_form";
import { OpenStudiosRegistration } from "@reactjs/components/open_studios/open_studios_registration";
import { MauButton } from "@reactjs/components/mau_button";
import { mailToLink } from "@js/services/mailer.service";
import { useModalState } from "@reactjs/hooks/useModalState";
import { api } from "@js/services/api";
import * as types from "@reactjs/types";
import Flash from "@js/app/jquery/flash";
import { isNil } from "@js/app/helpers";
import cx from "classnames";
import React, { FC, useState, useEffect } from "react";

interface OpenStudiosRegistrationSectionProps {
  location: string;
  openStudiosEvent: types.OpenStudiosEvent;
  autoRegister: Boolean;
  artistId: number;
  participant: types.OpenStudiosParticipant | null;
}

export const OpenStudiosRegistrationSection: FC<OpenStudiosRegistrationSectionProps> = ({
  location,
  openStudiosEvent,
  autoRegister,
  artistId,
  participant: initialParticipant,
}) => {
  const [participant, setParticipant] = useState<OpenStudiosParticipant | null>(
    initialParticipant
  );
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
        <OpenStudiosRegistration
          artistId={artistId}
          autoRegister={autoRegister}
          location={location}
          onUpdateParticipant={setParticipant}
          openStudiosEvent={openStudiosEvent}
        />
      )}
    </div>
  );
};
