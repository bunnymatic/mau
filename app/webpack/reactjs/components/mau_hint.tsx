import React, { FC } from "react";

interface MauHintProps {}

export const MauHint: FC<MauHintProps> = ({ children }) => {
  if (children) {
    return <p className="inline-hints">{children}</p>;
  }
  return null;
};
