import { routing } from "@js/services";
import { Medium } from "@models/medium.model";
import React, { FC } from "react";

interface MediumLinkProps {
  medium: Medium;
}

export const MediumLink: FC<MediumLinkProps> = ({ medium }) => {
  const path = routing.urlForModel("medium", medium);
  const name = medium.name;

  return (
    <a className="medium-link" href={path}>
      {name}
    </a>
  );
};
