import { hashToQueryString } from "@js/app/query_string_parser";
import { ArtPiece } from "@reactjs/models";
import cx from "classnames";
import React, { FC } from "react";

type ShareTypes = "twitter" | "facebook" | "pinterest";

interface ShareButtonProps {
  type: ShareTypes;
  artPiece: ArtPiece;
  target?: string;
}

export const ShareButton: FC<ShareButtonProps> = ({
  artPiece,
  type,
  target,
}) => {
  if (!(artPiece && artPiece.id) || !type) {
    return null;
  }

  let locationOrigin;
  const location = window.location;

  locationOrigin = location.protocol + "//" + location.hostname;
  if (location.port != null && location.port !== 80) {
    locationOrigin += ":" + location.port;
  }

  const domain = locationOrigin;
  const artPieceLink = `${domain}/art_pieces/${artPiece.id}`;
  const description = `Check out ${artPiece.title} by ${artPiece.artistName} on Mission Artists`;

  const safeArtPieceLink = encodeURIComponent(artPieceLink);
  const safeDescription = encodeURIComponent(description);
  const safeArtPieceImage = encodeURIComponent("" + artPiece.imageUrls.large);
  const safeTitle = encodeURIComponent(artPiece.title);

  const linkInfo = {
    twitter: {
      shareUrl: "http://twitter.com/intent/tweet",
      shareTitle: "Tweet this",
      params: {
        text: safeDescription,
        via: "sfmau",
        url: safeArtPieceLink,
      },
    },
    facebook: {
      shareUrl: "https://www.facebook.com/sharer/sharer.php",
      shareTitle: "Share this on Facebook",
      params: {
        u: safeArtPieceLink,
      },
    },
    pinterest: {
      shareUrl: "https://pinterest.com/pin/create/button/",
      shareTitle: "Pin it",
      params: {
        url: safeArtPieceLink,
        media: safeArtPieceImage,
        title: safeTitle,
        description: safeDescription,
      },
    },
  }[type];

  const href = `${linkInfo.shareUrl}?${hashToQueryString(linkInfo.params)}`;
  const iconClass = `ico-${type}`;
  const title = linkInfo.shareTitle;

  return (
    <a href={href} target={target || "_blank"} title={title}>
      <i className={cx("ico ico-invert", iconClass)}></i>
    </a>
  );
};