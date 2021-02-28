import cx from "classnames";
import React, { FC } from "react";

interface MauButtonProps {
  type?: "button" | "submit";
  primary?: boolean;
  secondary?: boolean;
  onClick?: (event: Event) => void;
  disabled?: boolean;
}

export const MauButton: FC<MauButtonProps> = ({
  type,
  primary,
  secondary,
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
        },
      ])}
      onClick={onClick}
    >
      {children}
    </button>
  );
};
