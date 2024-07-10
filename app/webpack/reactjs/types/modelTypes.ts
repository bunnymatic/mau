/** models **/
import { Nullable } from "./utilTypes";

export type IdType = number;

interface ActiveRecordModel {
  id: IdType;
}

export interface CmsDocument extends ActiveRecordModel {
  page: string;
  section: string;
  cmsid: number;
}

export interface Artist extends ActiveRecordModel {
  slug: string;
}

export interface Studio extends ActiveRecordModel {
  slug: string;
}

export interface ArtPiece extends ActiveRecordModel {
  title: string;
  dimensions: string;
  year: string;
  price: string;
}

export interface JsonApiModel<T, R> {
  id: string;
  type: string;
  attributes: T;
  relationships: R;
}

type ImageSizes = "small" | "medium" | "large" | "original";

// JsonAPI models look pretty different
interface ArtPieceAttributes {
  artist_name: string;
  favorites_count: number;
  price: Nullable<number>;
  display_price: Nullable<string>;
  year: Nullable<string>;
  dimensions: Nullable<string>;
  title: string;
  artist_id: number;
  image_urls: Record<ImageSizes, string>;
  sold_at: Nullable<string>;
}

interface ArtPieceRelationships {
  artist: Object;
  tags: Object;
  medium: Object;
}

export interface JsonApiArtPiece
  extends JsonApiModel<ArtPieceAttributes, ArtPieceRelationships> {}

export interface OpenStudiosParticipant extends ActiveRecordModel {
  userId: IdType;
  openStudiosEventId: IdType;
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

export interface EmailAttributes {
  id: IdType;
  name?: string;
  email: string;
  createdAt: string;
  updatedAt: string;
}

interface GenericEvent {
  id: number;
  data?: Record<string, string | Record<string, string>>;

  createdAt: string;
  message: string;
  updatedAt: string;
}

interface OpenStudiosSignupEvent extends GenericEvent {}

interface UserChangedEvent extends GenericEvent {}

export interface ApplicationEvent {
  genericEvent?: GenericEvent;
  userChangedEvent?: UserChangedEvent;
  openStudiosSignupEvent?: OpenStudiosSignupEvent;
}
