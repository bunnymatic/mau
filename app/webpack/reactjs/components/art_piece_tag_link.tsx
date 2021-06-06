import { routing } from "@js/services";
import { ArtPieceTag } from "@reactjs/models";
import React, { FC } from "react";

interface ArtPieceTagLinkProps {
  tag: ArtPieceTag;
}

export const ArtPieceTagLink: FC<ArtPieceTagLinkProps> = ({ tag }) => {
  const path = routing.urlForModel("art_piece_tag", tag);
  const name = tag.name;

  return (
    <a class="art-piece-tag-link" href={path}>
      {name}
    </a>
  );
};
