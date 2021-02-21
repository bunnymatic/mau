import * as types from "@reactjs/types";
import { randomBoolean } from "@test/support/faker_helpers";
import { Factory } from "rosie";
import faker from "faker";

export const openStudiosParticipantFactory = Factory.define<types.OpenStudiosParticipant>(
  "openStudiosParticipant"
)
  .attr("id", 1)
  .attr("userId", 2)
  .attr("openStudiosEventId", 3)
  .attr("showEmail", randomBoolean)
  .attr("showPhoneNumber", randomBoolean)
  .attr("shopUrl", faker.internet.url)
  .attr("videoConferenceUrl", faker.internet.url);
