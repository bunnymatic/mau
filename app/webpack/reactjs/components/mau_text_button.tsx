import cx from "classnames";
import React, { FC, MouseEventHandler } from "react";

interface MauTextButtonProps {
  onClick: MouseEventHandler<HTMLButtonElement>;
  classes?: string | string[];
  title?: string;
}

export const MauTextButton: FC<MauTextButtonProps> = ({
  children,
  title,
  classes,
  onClick,
}) => {
  return (
    <button
      title={title}
      className={cx("mau-text-button", classes)}
      onClick={onClick}
    >
      {children}
    </button>
  );
};
