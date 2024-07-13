import * as types from "@reactjs/types";
import { Factory } from "rosie";

export const specialEventDetailsFactory =
  Factory.define<types.SpecialEventDetails>("SpecailEventDetails")
    .attr("dateRange", "between now and then")
    .attr("timeSlots", [])
    .attr("startTime", "12:00")
    .attr("endTime", "17:00")
    .attr("startDate", "2024-10-10")
    .attr("endDate", "2024-10-12");
