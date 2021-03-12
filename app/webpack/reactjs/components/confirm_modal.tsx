import { noop } from "@js/app/helpers";
import { buttonStyleAttrs, MauButton } from "@reactjs/components/mau_button";
import { MauModal, setAppElement } from "@reactjs/components/mau_modal";
import { useModalState } from "@reactjs/hooks/useModalState";
import * as types from "@reactjs/types";
import React, { FC } from "react";

type ConfirmModalHandler = (success: boolean) => void;

interface ConfirmModalProps {
  id?: string;
  buttonText: string;
  buttonStyle?: types.MauButtonStyle;
  handleConfirm?: ConfirmModalHandler;
}

export const ConfirmModal: FC<ConfirmModalProps> = ({
  id,
  buttonStyle,
  buttonText,
  handleConfirm,
  children,
}) => {
  const { isOpen, open, close } = useModalState();
  setAppElement("body");

  const submit = (answer: boolean) => (_event: MouseEvent) => {
    (handleConfirm ?? noop)(answer);
    close();
  };

  return (
    <>
      <div id={id} className="mau-modal confirm-modal__trigger">
        <MauButton
          {...buttonStyleAttrs(buttonStyle)}
          onClick={(ev) => {
            ev.preventDefault();
            open();
          }}
        >
          {buttonText}
        </MauButton>
      </div>
      <MauModal isOpen={isOpen}>
        <div className="confirm-modal__content">
          <div className="confirm-modal__content--main">{children}</div>
          <div className="confirm-modal__actions">
            <div className="confirm-modal__action-item">
              <MauButton primary onClick={submit(true)}>
                Yes
              </MauButton>
            </div>
            <div className="confirm-modal__action-item">
              <MauButton secondary onClick={submit(false)}>
                No
              </MauButton>
            </div>
          </div>
        </div>
      </MauModal>
    </>
  );
};
