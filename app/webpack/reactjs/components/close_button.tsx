import React, { type FC, MouseEventHandler } from "react";

interface CloseButtonProps {
  handleClick: MouseEventHandler | (() => void);
}

export const CloseButton: FC<CloseButtonProps> = ({ handleClick }) => {
  return (
    <a
      className="close-button"
      title="close"
      href="#"
      onClick={(ev) => {
        ev.preventDefault();
        handleClick(ev);
      }}
    >
      <i className="fa fa-times"></i>
    </a>
  );
};
