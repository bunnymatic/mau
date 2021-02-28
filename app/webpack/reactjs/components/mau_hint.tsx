import React, { FC } from "react";

interface MauHintProps {}

export const MauHint: FC<MauHintProps> = ({ children }) => {
  if (children) {
    return <div className="inline-hints">{children}</div>;
  }
  return null;
};
