import { identity } from "@js/app/helpers";
import * as types from "@reactjs/types";
import { Factory } from "rosie";

export const emailFactory = Factory.define<types.EmailAttributes>(
  "emailAttributes"
)
  .sequence("email", (n) => `artist+${n}@example.com`)
  .sequence("name", (n) => `Miss ArtGal${n}`)
  .sequence("id", identity);
