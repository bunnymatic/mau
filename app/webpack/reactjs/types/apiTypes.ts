/** api request/response shapes **/

import { ApplicationEvent, IdType } from "./modelTypes";
import { Nullable } from "./utilTypes";

export interface ContactArtistFormData {
  name: string;
  phone?: string;
  email?: string;
  message?: string;
  artPieceId: number;
}

export interface ApplicationEventsListResponse {
  applicationEvents: ApplicationEvent[];
}

interface OpenStudiosParticipant {
  openStudiosEventId: IdType;
  showEmail: Nullable<boolean>;
  showPhoneNumber: Nullable<boolean>;
  shopUrl: Nullable<string>;
  videoConferenceUrl: Nullable<string>;
  videoConferenceSchedule: Nullable<Record<string, boolean>>;
  youtubeUrl: Nullable<string>;
}

export interface OpenStudiosParticipantUpdateRequest {
  id: number;
  artistId: number;
  openStudiosParticipant: OpenStudiosParticipant;
}
