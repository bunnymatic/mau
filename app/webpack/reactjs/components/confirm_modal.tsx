import { noop } from "@js/app/helpers";
import { buttonStyleAttrs, MauButton } from "@reactjs/components/mau_button";
import { MauModal, setAppElement } from "@reactjs/components/mau_modal";
import { useModalState } from "@reactjs/hooks";
import * as types from "@reactjs/types";
import cx from "classnames";
import React, { type FC, type ReactNode } from "react";

type ConfirmModalHandler = (success: boolean) => void;

export enum ConfirmModalVariants {
  normal = "normal",
  large = "large",
}

interface ConfirmModalProps {
  id?: string;
  buttonText: string;
  buttonStyle?: types.MauButtonStyle;
  handleConfirm?: ConfirmModalHandler;
  containerClass?: string;
  variant?: "normal" | "large";
  children?: ReactNode;
}

export const ConfirmModal: FC<ConfirmModalProps> = ({
  id,
  buttonStyle,
  buttonText,
  handleConfirm,
  containerClass,
  variant = ConfirmModalVariants.normal,
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
        <div
          className={cx("confirm-modal__content", {
            [containerClass]: Boolean(containerClass),
          })}
        >
          <div
            className={cx("confirm-modal__content--main", {
              "confirm-modal__content--main--large":
                variant === ConfirmModalVariants.large,
            })}
          >
            {children}
          </div>
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
