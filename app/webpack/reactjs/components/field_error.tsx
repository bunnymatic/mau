import React, { type FC, type ReactNode } from "react";

interface FieldErrorProps {
  children: ReactNode;
}

export const FieldError: FC<FieldErrorProps> = ({ children }) => {
  if (Array.isArray(children)) {
    return children.map((child) => (
      <p className="inline-errors" key={JSON.stringify(child)}>
        {child}
      </p>
    ));
  } else {
    return <p className="inline-errors">{children}</p>;
  }
};
