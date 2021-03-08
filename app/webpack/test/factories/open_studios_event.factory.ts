import * as types from "@reactjs/types";
import { Factory } from "rosie";

export const openStudiosEventFactory = Factory.define<types.OpenStudiosEvent>(
  "openStudiosEvent"
)
  .attr("dateRange", "between now and then")
  .attr("startTime", "noon")
  .attr("endTime", "after noon");
