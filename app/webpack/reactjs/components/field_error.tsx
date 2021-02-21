import React, { FC } from "react";

interface FieldErrorProps {}

export const FieldError: FC<FieldErrorProps> = ({ children }) => {
  return <p className="inline-errors">{children}</p>;
};
