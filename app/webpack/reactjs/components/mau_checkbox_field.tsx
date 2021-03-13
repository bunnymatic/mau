import { MauHint } from "@reactjs/components/mau_hint";
import cx from "classnames";
import { Field } from "formik";
import React, { FC, JSX } from "react";

interface MauCheckboxFieldProps {
  name: string;
  label: string;
  hint?: string | JSX.Element;
  id?: string;
  classes?: string;
  disabled?: boolean;
}

export const MauCheckboxField: FC<MauCheckboxFieldProps> = ({
  id,
  name,
  label,
  hint,
  classes,
  disabled,
}) => {
  return (
    <div
      className={cx("boolean input optional", { [classes]: Boolean(classes) })}
    >
      <label htmlFor={name}>
        <Field
          type="checkbox"
          name={name}
          id={id ?? name}
          disabled={disabled}
        />
        <span>{label}</span>
      </label>
      <MauHint>{hint}</MauHint>
    </div>
  );
};
