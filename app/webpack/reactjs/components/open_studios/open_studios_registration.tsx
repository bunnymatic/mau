import Flash from "@js/app/jquery/flash";
import { api } from "@js/services/api";
import { MauButton } from "@reactjs/components/mau_button";
import { MauModal, setAppElement } from "@reactjs/components/mau_modal";
import { useModalState } from "@reactjs/hooks/useModalState";
import * as types from "@reactjs/types";
import React, { FC, useEffect } from "react";

interface OpenStudiosRegWindowCloseFnArgs {
  updated: boolean;
  participant?: types.Nullable<types.OpenStudiosParticipant>;
}
type OpenStudiosRegWindowCloseFn = (
  args: OpenStudiosRegWindowCloseFnArgs
) => void;

interface OpenStudiosRegistrationWindowProps {
  location: string;
  dateRange: string;
  onClose: OpenStudiosRegWindowCloseFn;
}

const OpenStudiosRegistrationWindow: FC<OpenStudiosRegistrationWindowProps> = ({
  dateRange,
  onClose,
}) => {
  const setRegistration = (status: boolean) => {
    const flash = new Flash();
    return api.openStudios
      .submitRegistrationStatus(status)
      .then((data) => {
        onClose({ updated: true, participant: data.participant });
        flash.show({
          notice: "We've updated your registration status",
        });
      })
      .catch(() => {
        onClose({ updated: false });
        flash.show({
          error:
            "We had problems updating your open studios status.  Please try again later",
        });
      });
  };
  const accept = () => setRegistration(true);
  const decline = () => setRegistration(false);

  return (
    <div
      className="open-studios-modal__container"
      id="open-studios-registration-form"
    >
      <div className="open-studios-modal__header popup-header">
        <div className="open-studios-modal__title popup-title">
          Register For Open Studios
        </div>
        <div className="open-studios-modal__close popup-close">
          <a
            href="#"
            onClick={(ev) => {
              ev.preventDefault;
              onClose({ updated: false });
            }}
          >
            <i className="fa fa-times"></i>
          </a>
        </div>
      </div>
      <div className="open-studios-modal__content popup-text">
        <p>Open Studios is {dateRange}.</p>
        <p>Would you like to register as a participating artist?</p>
        <div className="actions open-studios-registration-form__actions">
          <div className="open-studios-registration-form__action-item">
            <MauButton primary onClick={accept}>
              Yes
            </MauButton>
          </div>
          <div className="open-studios-registration-form__action-item">
            <MauButton secondary onClick={decline}>
              No
            </MauButton>
          </div>
        </div>
      </div>
    </div>
  );
};

interface OpenStudiosRegistrationProps {
  location: string;
  openStudiosEvent: types.OpenStudiosEvent;
  autoRegister: Boolean;
  artistId: number;
  participant: types.OpenStudiosParticipant;
  onUpdateParticipant: (participant: types.OpenStudiosParticipant) => void;
}

export const OpenStudiosRegistration: FC<OpenStudiosRegistrationProps> = ({
  location,
  openStudiosEvent,
  autoRegister,
  onUpdateParticipant,
}) => {
  const { isOpen, open, close } = useModalState();

  const handleClose: OpenStudiosRegWindowCloseFn = ({
    updated,
    participant,
  }) => {
    if (updated) {
      onUpdateParticipant(participant);
    }
    close();
  };
  const buttonText = "Yes - Register Me";

  useEffect(() => {
    if (autoRegister) {
      open();
    }
  }, [autoRegister]);

  setAppElement("body");

  return (
    <>
      <div id="open-studios-registration-button">
        <MauButton
          primary
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
