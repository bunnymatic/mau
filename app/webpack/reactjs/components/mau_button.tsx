import cx from 'classnames';
import React, {FC} from 'react';

interface MauButtonProps {
  primary?: boolean;
  secondary?: boolean;
  onClick?: (event: Event) => void
};

export const MauButton:FC<MauButtonProps> = ({primary, secondary, onClick, children}) => {
  return <button className={cx(['pure-button', {"button-primary": Boolean(primary), "button-secondary": Boolean(secondary)}])} onClick={onClick}>{children}</button>
}
