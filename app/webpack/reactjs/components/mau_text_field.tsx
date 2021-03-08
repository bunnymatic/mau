import { FieldError } from "@reactjs/components/field_error";
import { MauHint } from "@reactjs/components/mau_hint";
import { ErrorMessage, Field } from "formik";
import React, { FC, JSX } from "react";

interface MauTextFieldProps {
  id?: string;
  name: string;
  label: string;
  placeholder: string;
  className?: string;
  hint?: string | JSX.Element;
}

export const MauTextField: FC<MauTextFieldProps> = ({
  id,
  name,
  label,
  placeholder,
  className,
  hint,
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
