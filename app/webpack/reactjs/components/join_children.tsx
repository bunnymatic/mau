import React, { FC } from "react";

interface JoinChildrenProps {
  separator?: string;
}

export const JoinChildren: FC<JoinChildrenProps> = ({
  separator,
  children,
}) => {
  if (!Array.isArray(children) || children.length < 2) {
    return <>{children}</>;
  }
  return (
    <>{children.reduce((prev, curr) => [prev, separator ?? ", ", curr])}</>
  );
};
