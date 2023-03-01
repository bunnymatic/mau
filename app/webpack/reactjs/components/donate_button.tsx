import { MauButton } from "@reactjs/components/mau_button";
import { useModalState } from "@reactjs/hooks";
import { getDonateLink } from "@services/venmo_donate_link.service";
import cx from "classnames";
import QrCode from "images/mau_venmo_qrcode.jpg";
import React, { FC, useRef } from "react";

export const DonateButton: FC = () => {
  const { toggle, isOpen } = useModalState(false);
  const qrCodeRef = useRef<HTMLElement>(null);
  const toggleAndScrollIntoView = () => {
    toggle();
    if (!isOpen) {
      qrCodeRef.current?.scrollIntoView();
    }
  };

  return (
    <>
      <MauButton secondary onClick={toggleAndScrollIntoView}>
        Donate
      </MauButton>
      <div
        className={cx("donate-button__qrcode", {
          "donate-button__qrcode--open": isOpen,
        })}
      >
        <a href={getDonateLink()} target="_blank" ref={qrCodeRef}>
          <img className="donate-button__qrcode__image" src={QrCode} />
        </a>
      </div>
    </>
  );
};
