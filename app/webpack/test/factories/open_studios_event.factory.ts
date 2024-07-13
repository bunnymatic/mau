import * as types from "@reactjs/types";
import { Factory } from "rosie";

import { specialEventDetailsFactory } from "./special_event_details.factory";

export const openStudiosEventFactory = Factory.define<types.OpenStudiosEvent>(
  "openStudiosEvent"
)
  .attr("dateRange", "July 10-12 2020")
  .attr("startTime", "12P")
  .attr("endTime", "6P")
  .attr("specialEvent", specialEventDetailsFactory.build());
