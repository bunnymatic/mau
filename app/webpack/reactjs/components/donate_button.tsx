import { MauButton } from "@reactjs/components/mau_button";
import { useModalState } from "@reactjs/hooks";
import { getDonateLink } from "@services/venmo_donate_link.service";
import cx from "classnames";
import React, { FC } from "react";

import QrCode from "../../images/mau_venmo_qrcode.jpg";

export const DonateButton: FC = () => {
  const { toggle, isOpen } = useModalState(false);

  return (
    <>
      <MauButton secondary onClick={toggle}>
        Donate
      </MauButton>
      <div
        className={cx("donate-button__qrcode", {
          "donate-button__qrcode--open": isOpen,
        })}
      >
        <a href={getDonateLink()} target="_blank">
          <img className="donate-button__qrcode__image" src={QrCode} />
        </a>
      </div>
    </>
  );
};
