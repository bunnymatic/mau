import cx from "classnames";
import React, {
  MouseEventHandler,
  type PropsWithChildren,
  type ReactNode,
} from "react";

interface MauTextButtonProps {
  onClick: MouseEventHandler<HTMLButtonElement>;
  classes?: string | string[];
  title?: string;
}

export const MauTextButton = ({
  children,
  title,
  classes,
  onClick,
}: PropsWithChildren<MauTextButtonProps>): ReactNode => {
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
