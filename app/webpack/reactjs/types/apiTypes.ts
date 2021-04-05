/** api request/response shapes **/

export interface ContactArtistFormData {
  name: string;
  phone?: string;
  email?: string;
  message?: string;
  artPieceId: number;
}
