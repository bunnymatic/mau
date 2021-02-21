import React, { FC } from "react";
import { MauHint } from "@reactjs/components/mau_hint";
import { FieldError } from "@reactjs/components/field_error";
import { Field, ErrorMessage } from "formik";

interface MauTextFieldProps {
  id?: string;
  name: string;
  label: string;
  placeholder: string;
  className?: string;
  hint?: string | JSX.Element;
  errors?: Record<string, unknown>;
}

export const MauTextField: FC<MauTextFieldProps> = ({
  id,
  name,
  label,
  placeholder,
  className,
  hint,
  errors,
}) => {
  const classes = className ?? "";
  return (
    <div className={`string input optional ${classes}`}>
      <label htmlFor={name}>{label}</label>
      <Field
        type="text"
        name={name}
        placeholder={placeholder}
        id={id || name}
      />
      <ErrorMessage component={FieldError} name={name} />
      <MauHint>{hint}</MauHint>
    </div>
  );
};
