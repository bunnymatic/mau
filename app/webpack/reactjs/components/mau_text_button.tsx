import React, { FC, MouseEventHandler } from "react";

interface MauTextButtonProps {
  onClick: MouseEventHandler<HTMLButtonElement>;
  title?: string;
}

export const MauTextButton: FC<MauTextButtonProps> = ({
  children,
  title,
  onClick,
}) => {
  return (
    <button title={title} className="mau-text-button" onClick={onClick}>
      {children}
    </button>
  );
};
