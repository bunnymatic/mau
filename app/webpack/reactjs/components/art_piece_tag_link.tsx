import { routing } from "@js/services";
import { ArtPieceTag } from "@models/art_piece_tag.model";
import React, { FC } from "react";

interface ArtPieceTagLinkProps {
  tag: ArtPieceTag;
}

export const ArtPieceTagLink: FC<ArtPieceTagLinkProps> = ({ tag }) => {
  const path = routing.urlForModel("art_piece_tag", tag);
  const name = tag.name;

  return (
    <a className="art-piece-tag-link" href={path}>
      {name}
    </a>
  );
};
