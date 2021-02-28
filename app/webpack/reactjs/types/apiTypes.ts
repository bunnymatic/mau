/** api request/response shapes **/
import * as modelTypes from "./modelTypes";

interface ArtistsOpenStudiosRegisterForOsResponse {
  success: boolean;
  participating: boolean;
  participant?: modelTypes.OpenStudiosParticipant;
}

interface OpenStudiosParticipantUpdateRequest {
  id: number;
  artistId: number;
  openStudiosPartipicant: modelTypes.OpenStudiosParticipant;
}

type OpenStudiosParticipantUpdateResponse = modelTypes.OpenStudiosParticipant;
