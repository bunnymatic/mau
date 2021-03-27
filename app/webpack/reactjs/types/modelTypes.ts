/** models **/
import { Nullable } from "./utilTypes";

interface ActiveRecordModel {
  id: number;
}

export interface CmsDocument {
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

interface JsonApiVersion {
  version: string;
}

export interface JsonApiCollection<T, R> {
  data: JsonApiModel<T, R>[];
  included: unknown[];
  jsonapi: JsonApiVersion;
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
