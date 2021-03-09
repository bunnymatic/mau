import { MauButton } from "@reactjs/components/mau_button";
import { MauModal, setAppElement } from "@reactjs/components/mau_modal";
import {
  OpenStudiosRegistrationWindow,
  OpenStudiosRegistrationWindowCloseFn,
} from "@reactjs/components/open_studios/open_studios_registration_window";
import { useModalState } from "@reactjs/hooks/useModalState";
import * as types from "@reactjs/types";
import React, { FC, useEffect } from "react";

interface RegistrationModalProps {
  location: string;
  openStudiosEvent: types.OpenStudiosEvent;
  autoRegister: Boolean;
  artistId: number;
  participant: types.OpenStudiosParticipant;
  buttonText: string;
  buttonStyle?: Record<"primary" | "secondary", Boolean>;
  onUpdateParticipant: (participant: types.OpenStudiosParticipant) => void;
}

export const RegistrationModal: FC<RegistrationModalProps> = ({
  location,
  openStudiosEvent,
  autoRegister,
  onUpdateParticipant,
  buttonText,
  buttonStyle,
}) => {
  const { isOpen, open, close } = useModalState();

  const handleClose: OpenStudiosRegistrationWindowCloseFn = ({
    updated,
    participant,
  }) => {
    if (updated) {
      onUpdateParticipant(participant);
    }
    close();
  };
  useEffect(() => {
    if (autoRegister) {
      open();
    }
  }, [autoRegister]);

  setAppElement("body");
  /* const buttonType = {}
   * if (buttonStyle) {
   *   buttonType[buttonStyle] = true
   * } */
  return (
    <>
      <div id="open-studios-registration-button">
        <MauButton
          {...buttonStyle}
          onClick={(ev) => {
            ev.preventDefault();
            open();
          }}
        >
          {buttonText}
        </MauButton>
      </div>
      <MauModal isOpen={isOpen}>
        <OpenStudiosRegistrationWindow
          onClose={handleClose}
          location={location}
          dateRange={openStudiosEvent?.dateRange}
        />
      </MauModal>
    </>
  );
};
