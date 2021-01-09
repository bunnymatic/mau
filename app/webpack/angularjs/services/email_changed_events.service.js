import { api } from "@js/services/api";
import angular from "angular";

const emailChangedEventsService = function () {
  const filterByChangedEmail = (events) => {
    return (events || []).filter((event) => {
      if (event && event.userChangedEvent && event.userChangedEvent.message) {
        const message = event.userChangedEvent.message;
        return message && /update.*email/.test(message);
      }
      return false;
    });
  };
  return {
    list: function (params) {
      return api.applicationEvents
        .index(params)
        .then((data) => filterByChangedEmail((data || {}).applicationEvents));
    },
  };
};

angular
  .module("mau.services")
  .factory("EmailChangedEventsService", emailChangedEventsService);
