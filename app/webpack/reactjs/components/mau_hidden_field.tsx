import { Field } from "formik";
import React, { FC } from "react";

interface MauHiddenFieldProps {
  id?: string;
  name: string;
}

export const MauHiddenField: FC<MauHiddenFieldProps> = ({ id, name }) => {
  return <Field type="hidden" name={name} id={id || name} />;
};
