import { DateTime } from "luxon";
import { ReactNode } from "react";
export type Nullable<T> = T | null;

export interface TimeSlot {
  start: DateTime;
  end: DateTime;
}

export type MauButtonStyle = "primary" | "secondary";
export type MauButtonStyleAttr = Record<MauButtonStyle, Boolean>;
export type ClassNames = string | Array<string> | Record<string, boolean>;
export type ChildrenProp = {
  children?: ReactNode | Array<ReactNode>;
};
