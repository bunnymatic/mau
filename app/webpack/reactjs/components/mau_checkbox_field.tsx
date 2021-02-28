import { Field } from "formik";
import { MauHint } from "@reactjs/components/mau_hint";
import React, { FC } from "react";
interface MauCheckboxFieldProps {
  name: string;
  label: string;
  checked?: boolean;
  hint?: string | JSX.Element;
  id?: string;
}

export const MauCheckboxField: FC<MauCheckboxFieldProps> = ({
  id,
  name,
  label,
  checked,
  hint,
}) => {
  return (
    <div className="boolean input optional">
      <label htmlFor={name}>
        <Field type="checkbox" name={name} id={id ?? name} />
        {label}
      </label>
      <MauHint>{hint}</MauHint>
    </div>
  );
};
