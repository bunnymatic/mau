import * as types from "@reactjs/types";
import { api } from "@services/api";
import { DateTime } from "luxon";

type EmailChangedEventServiceListArgs = DateTime;

const filterByChangedEmail = (events: types.ApplicationEvent[]) => {
  return (events || []).filter((event) => {
    if (event && event.userChangedEvent && event.userChangedEvent.message) {
      const message = event.userChangedEvent.message;
      return message && /update.*email/.test(message);
    }
    return false;
  });
};

export const EmailChangedEventsService = {
  list: (since: EmailChangedEventServiceListArgs) => {
    return api.applicationEvents
      .index({ since: since.toISO() })
      .then(({ applicationEvents }) =>
        filterByChangedEmail(applicationEvents ?? [])
      );
  },
};
