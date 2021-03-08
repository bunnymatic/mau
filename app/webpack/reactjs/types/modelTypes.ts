/** models **/
import { Nullable } from "./utilTypes";

export interface OpenStudiosParticipant {
  id: number;
  userId: number;
  openStudiosEventId: number;
  showEmail: Nullable<boolean>;
  showPhoneNumber: Nullable<boolean>;
  shopUrl: Nullable<string>;
  videoConferenceUrl: Nullable<string>;
  videoConferenceSchedule: Nullable<Record<string, boolean>>;
  youtubeUrl: Nullable<string>;
}

// Note: this does *not* match the Ruby model OpenStudiosEvent but
// matches the response shape we use in `open_studios_status.html.slim` when we build
// the react component.  Not sure if this should be somewhere else but for now...

export interface OpenStudiosEvent {
  dateRange: string;
  startTime: string;
  endTime: string;
  specialEvent: SpecialEventDetails;
}

export interface DateInfo {
  startTime: string;
  endTime: string;
  startDate: string;
  endDate: string;
}

export interface SpecialEventDetails extends DateInfo {
  dateRange: string;
  timeSlots: string[];
}
