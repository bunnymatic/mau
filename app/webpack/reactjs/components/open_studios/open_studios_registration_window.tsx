import Flash from "@js/app/jquery/flash";
import { api } from "@js/services/api";
import { MauButton } from "@reactjs/components/mau_button";
import * as types from "@reactjs/types";
import React, { FC } from "react";

interface OpenStudiosRegWindowCloseFnArgs {
  updated: boolean;
  participant?: types.Nullable<types.OpenStudiosParticipant>;
}
export type OpenStudiosRegWindowCloseFn = (
  args: OpenStudiosRegWindowCloseFnArgs
) => void;

interface OpenStudiosRegistrationWindowProps {
  location: string;
  dateRange: string;
  onClose: OpenStudiosRegWindowCloseFn;
}

export const OpenStudiosRegistrationWindow: FC<OpenStudiosRegistrationWindowProps> = ({
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
