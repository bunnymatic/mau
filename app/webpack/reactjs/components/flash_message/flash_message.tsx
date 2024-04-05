import * as types from "@reactjs/types";
import React, { useEffect, type FC, useState } from "react";
import cx from 'classnames';
import { isNil } from "@js/app/typed_helpers";

interface FlashMessageProps {
  type?: types.FlashType;
  message: string;
  timeoutMilliseconds?: number;
}

const DEFAULT_DURATION_MS = 5000;
const FlashMessage: FC<FlashMessageProps> = ({type: inputType, message, timeoutMilliseconds}) => {
  const type = inputType || types.FlashType.Notice;

  const wrapperClasses = cx('flash', `flash__${type}`);
  const closeButtonClasses = cx('fa','fa-icon','fa-times-circle', 'flash__close')
  const prefix = type === types.FlashType.Error ? <>Oops: </> : null;

  const [dismissed, setDismissed] = useState<boolean>(false);
  const dismiss = () => setDismissed(true)
  useEffect(() => {
    let duration;
    if (!isNil<number>(timeoutMilliseconds)) {
      duration = timeoutMilliseconds;
    } else {
      duration = DEFAULT_DURATION_MS
    }
    if (duration <= 0) {
      return;
    }
    const timeout = setTimeout(() => {
      dismiss();
    }, duration)
    return () => clearTimeout(timeout)
  }, [type, message, dismiss, timeoutMilliseconds])

  if (dismissed) {
    return;
  }

  return <div className={wrapperClasses}>
    {prefix}
    { message.split("\n").map((line) => ( <span key={line}>{line}<br/></span> )) }
    <i className={closeButtonClasses} />
  </div>;
}

export { FlashMessage }