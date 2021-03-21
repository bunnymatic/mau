import React, { FC } from "react";

interface CloseButtonProps {
  handleClick: () => void;
}

export const CloseButton: FC<CloseButtonProps> = ({ handleClick }) => {
  return (
    <a
      className="close-button"
      title="close"
      href="#"
      onClick={(ev) => {
        ev.preventDefault();
        handleClick();
      }}
    >
      <i className="fa fa-times"></i>
    </a>
  );
};
