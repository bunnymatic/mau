import React, { FC } from "react";

interface ReactTestComponentProps {}

import { FavoriteThis } from "./favorite_this";
import { ShareButton } from "./share_button";

const artPiece = {
  title: "whatever",
  artistName: "joe",
  id: 10,
  imageUrls: {
    large: "whatever.jpg",
  },
};

export const ReactTestComponent: FC<ReactTestComponentProps> = (_props) => {
  return (
    <div>
      <FavoriteThis type="Artist" id={10} />
      <FavoriteThis type="whatever" id={310} />

      <ShareButton artPiece={artPiece} type="twitter" />
    </div>
  );
};
