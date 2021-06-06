import { routing } from "@js/services";
import { Medium } from "@reactjs/models";
import React, { FC } from "react";

interface MediumLinkProps {
  medium: Medium;
}

export const MediumLink: FC<MediumLinkProps> = ({ medium }) => {
  const path = routing.urlForModel("medium", medium);
  const name = medium.name;

  return <a href={path}>{name}</a>;
};
