import jQuery from "jquery";
import { beforeEach, describe, expect, it } from "vitest";

import ApplicationEventsDetailsForm from "./application_events_details_form";

describe("ApplicationEventsDetailsForm", function () {
  beforeEach(function () {
    document.documentElement.innerHTML =
      '<div id="fixture">' +
      "<form>" +
      '  <input id="query_number_of_records" value="the number of records"/>' +
      '  <input id="query_since" value="the time since" />' +
      "</form>" +
      "</div>";
    new ApplicationEventsDetailsForm("form");
  });

  it("changing since clears number of records", () => {
    jQuery("#query_since").trigger("change");
    expect(jQuery("#query_number_of_records").val()).toEqual("");
    expect(jQuery("#query_since").val()).toEqual("the time since");
  });

  it("changing number of records clears the since field", () => {
    jQuery("#query_number_of_records").trigger("change");
    expect(jQuery("#query_since").val()).toEqual("");
    expect(jQuery("#query_number_of_records").val()).toEqual(
      "the number of records"
    );
  });
});
