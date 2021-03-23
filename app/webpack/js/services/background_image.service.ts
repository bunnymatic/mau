import * as CSS from "csstype";

type BackgroundImageStyle = Pick<
  CSS.Properties,
  | "background"
  | "backgroundImage"
  | "backgroundPosition"
  | "backgroundOrigin"
  | "backgroundSize"
  | "backgroundRepeat"
>;

export const backgroundImageStyle = (
  url: string,
  overrides: BackgroundImageStyle = {}
): BackgroundImageStyle => ({
  backgroundImage: 'url("' + url + '")',
  backgroundSize: "cover",
  backgroundPosition: "center center",
  ...overrides,
});
