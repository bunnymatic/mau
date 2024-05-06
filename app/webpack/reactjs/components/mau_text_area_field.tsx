import { FieldError } from "@reactjs/components/field_error";
import { MauHint } from "@reactjs/components/mau_hint";
import { ErrorMessage, Field } from "formik";
import React, { FC, JSX } from "react";

interface MauTextAreaFieldProps {
  id?: string;
  name: string;
  label: string;
  placeholder?: string;
  className?: string;
  hint?: string | JSX.Element;
  required?: boolean;
}

export const MauTextAreaField: FC<MauTextAreaFieldProps> = ({
  id,
  name,
  label,
  required,
  placeholder,
  className,
  hint,
}) => {
  const classes = className ?? "";
  return (
    <div className={`string input optional ${classes}`}>
      <label htmlFor={name}>{label}</label>
      <Field
        as="textarea"
        name={name}
        placeholder={placeholder}
        required={required}
        id={id || name}
      />
      <ErrorMessage component={FieldError} name={name} />
      <MauHint>{hint}</MauHint>
    </div>
  );
};
