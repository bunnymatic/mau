import React, { FC } from "react";

interface SpinnerProps {}

// This is fully css animated and controlled
// by _spinner.scss
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
