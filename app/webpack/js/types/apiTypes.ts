/** models **/
interface OpenStudiosParticipantType {
  id: number,
  userId: number,
  openStudiosEventId: number
}

/** api request/response shapes **/
interface ArtistsOpenStudiosRegisterForOsResponse {
  success: boolean,
  participating: boolean,
  participant?: OpenStudiosParticipantType
}
