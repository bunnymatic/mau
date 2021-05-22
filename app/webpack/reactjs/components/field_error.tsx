import React, { FC } from "react";

interface FieldErrorProps {}

export const FieldError: FC<FieldErrorProps> = ({ children }) => {
  if (Array.isArray(children)) {
    return children.map((child) => <p className="inline-errors">{child}</p>);
  } else {
    return <p className="inline-errors">{children}</p>;
  }
};
