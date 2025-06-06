import React, { type PropsWithChildren, type ReactNode } from "react";

export const MauHint = ({ children }: PropsWithChildren): ReactNode => {
  if (children) {
    return <p className="inline-hints">{children}</p>;
  }
  return null;
};
