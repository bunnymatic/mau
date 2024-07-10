import * as types from "@reactjs/types";
import React, { FC } from "react";

interface MauHintProps {}

export const MauHint: FC<MauHintProps & types.ChildrenProp> = ({
  children,
}) => {
  if (children) {
    return <p className="inline-hints">{children}</p>;
  }
  return null;
};
