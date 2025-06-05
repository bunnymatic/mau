import React, { type ReactNode } from "react";

// This is fully css animated and controlled
// by _spinner.scss
export const Spinner = (): ReactNode => {
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
