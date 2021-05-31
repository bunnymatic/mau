/** api request/response shapes **/

import { ApplicationEvent } from "./modelTypes";

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
