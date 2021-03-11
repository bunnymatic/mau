import { DateTime } from "luxon";
export type Nullable<T> = T | null;

export interface TimeSlot {
  start: DateTime;
  end: DateTime;
}

export type MauButtonStyle = "primary" | "secondary";
export type MauButtonStyleAttr = Record<MauButtonStyle, Boolean>;
