import React, { FC, ReactNode } from "react";

interface JoinChildrenProps {
  separator?: string;
  children?: ReactNode | ReactNode[];
}

export const JoinChildren: FC<JoinChildrenProps> = ({
  separator,
  children,
}) => {
  if (Array.isArray(children)) {
    return (
      <>{children.reduce((prev, curr) => [prev, separator ?? ", ", curr])}</>
    );
  } else {
    return <>{children}</>;
  }
};
