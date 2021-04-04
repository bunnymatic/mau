import * as types from "@reactjs/types";
import cx from "classnames";
import React, { MouseEventHandler, FC } from "react";

interface MauButtonProps {
  type?: "button" | "submit";
  primary?: boolean;
  secondary?: boolean;
  fullWidth?: boolean;
  onClick?: MouseEventHandler<HTMLButtonElement>;
  disabled?: boolean;
}

export const buttonStyleAttrs = (
  style: types.MauButtonStyle
): types.ButtonStyleAttrs => {
  return { [style]: true };
};

export const MauButton: FC<MauButtonProps> = ({
  type,
  primary,
  secondary,
  fullWidth,
  onClick,
  disabled,
  children,
}) => {
  return (
    <button
      role="button"
      type={type}
      disabled={disabled}
      className={cx([
        "pure-button",
        {
          "button-primary": Boolean(primary),
          "button-secondary": Boolean(secondary),
          "button--full-width": Boolean(fullWidth),
        },
      ])}
      onClick={onClick}
    >
      {children}
    </button>
  );
};
