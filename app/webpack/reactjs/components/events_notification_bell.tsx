import { some } from "@js/app/helpers";
import { EmailChangedEventsService } from "@js/services/email_changed_events.service";
import * as types from "@reactjs/types";
import { DateTime } from "luxon";
import React, { FC, useEffect, useState } from "react";

interface EventsNotificationBellProps {}

export const EventsNotificationBell: FC<EventsNotificationBellProps> = () => {
  const since = DateTime.local().minus({ days: 7 });

  const [show, setShow] = useState<boolean>(false);

  useEffect(() => {
    EmailChangedEventsService.list(since)
      .then(function (data: types.ApplicationEvent[]) {
        setShow(some(data));
      })
      .catch(function (err) {
        console.error(err);
      });
  }, []);

  return (
    show && (
      <div className="events-notification-bell">
        <a
          className="events-notification-bell__tooltip admin-tooltip"
          href="/admin/application_events/"
          title="Something happened!"
        >
          <div className="fa fa-bell"></div>
        </a>
      </div>
    )
  );
};
