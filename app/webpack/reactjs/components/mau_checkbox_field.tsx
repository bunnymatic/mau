import { Field } from "formik";
import React, { FC } from "react";

interface MauCheckboxFieldProps {
  name: string;
  label: string;
  value?: boolean;
}

export const MauCheckboxField: FC<MauCheckboxFieldProps> = ({
  name,
  label,
  value,
}) => {
  return (
    <label>
      <Field type="checkbox" name={name} />
      {label}
    </label>
  );
};
