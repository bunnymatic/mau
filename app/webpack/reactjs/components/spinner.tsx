import React, { FC } from "react";

interface SpinnerProps {}

export const Spinner: FC<SpinnerProps> = () => {
  return (
    <div className="mau-spinner" role="progressbar">
      <div></div>
      <div></div>
      <div></div>
      <div></div>
      <div></div>
      <div></div>
      <div></div>
      <div></div>
      <div></div>
      <div></div>
      <div></div>
      <div></div>
    </div>
  );
};
