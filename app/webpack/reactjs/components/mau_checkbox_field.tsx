import { Field } from "formik";
import { MauHint } from "@reactjs/components/mau_hint";
import cx from "classnames";
import React, { FC } from "react";

interface MauCheckboxFieldProps {
  name: string;
  label: string;
  checked?: boolean;
  hint?: string | JSX.Element;
  id?: string;
  classes?: string;
}

export const MauCheckboxField: FC<MauCheckboxFieldProps> = ({
  id,
  name,
  label,
  checked,
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
