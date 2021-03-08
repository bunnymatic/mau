import * as types from "@reactjs/types";
import { randomBoolean } from "@test/support/faker_helpers";
import faker from "faker";
import { Factory } from "rosie";

export const openStudiosParticipantFactory = Factory.define<types.OpenStudiosParticipant>(
  "openStudiosParticipant"
)
  .attr("id", 1)
  .attr("userId", 2)
  .attr("openStudiosEventId", 3)
  .attr("showEmail", randomBoolean)
  .attr("showPhoneNumber", randomBoolean)
  .attr("shopUrl", faker.internet.url)
  .attr("videoConferenceUrl", faker.internet.url)
  .attr("youtubeUrl", `http://www.youtube.com/watch?${faker.lorem.word()}`);
