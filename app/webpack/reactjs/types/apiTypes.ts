/** api request/response shapes **/

import { ApplicationEvent, IdType, OpenStudiosParticipant } from "./modelTypes";

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

export interface OpenStudiosParticipantUpdateRequest {
  id: IdType;
  artistId: IdType;
  openStudiosParticipant: OpenStudiosParticipant;
}

export type ImageSize = "small" | "medium" | "large" | "original";
