import * as types from "@reactjs/types";
import React, { FC } from "react";

interface ConfirmRegistrationContentProps {
  location: string;
  event: types.OpenStudiosEvent;
}

export const ConfirmRegistrationContent: FC<
  ConfirmRegistrationContentProps
> = ({ event, location }) => {
  return (
    <>
      <p>
        You are about to register as a participating artist for Open Studios,{" "}
        {event.dateRange}.
      </p>
      <p>Which means you will:</p>
      <ul>
        <li> Hang some art at your studio - {location}</li>
        <li>
          Open your studio to the public {event.dateRange}, {event.startTime} -{" "}
          {event.endTime}.
        </li>
        <li> Promote your art and studio as part of the event.</li>
      </ul>
      <p>Would you like to continue?</p>
    </>
  );
};
