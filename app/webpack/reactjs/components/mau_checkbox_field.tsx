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
}

export const MauCheckboxField: FC<MauCheckboxFieldProps> = ({
  id,
  name,
  label,
  hint,
  classes,
}) => {
  return (
    <div
      className={cx("boolean input optional", { [classes]: Boolean(classes) })}
    >
      <label htmlFor={name}>
        <Field type="checkbox" name={name} id={id ?? name} />
        <span>{label}</span>
      </label>
      <MauHint>{hint}</MauHint>
    </div>
  );
};
