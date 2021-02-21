import React, {FC} from 'react'
import { MauHint } from '@reactjs/components/mau_hint';
import { Field } from 'formik'

interface MauTextFieldProps {
  name: string;
  label: string;
  value?: boolean;
  placeholder: string;
  className?: string;
  hint?: string | JSX.Element;
};

export const MauTextField:FC<MauTextFieldProps> = ({name, label, value, placeholder, className, hint}) => {
  const classes = className ?? ""
  return (<div className={`string input optional ${classes}`}>
    <label htmlFor={name}>
      {label}
    </label>
    <Field type="text" name={name} value={value} placeholder={placeholder} />
    <MauHint>{hint}</MauHint>
  </div>)
}
