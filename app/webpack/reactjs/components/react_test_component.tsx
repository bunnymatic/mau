import React, { FC } from "react";

interface ReactTestComponentProps {}

import Flash from "@js/app/flash";

import { FavoriteThis } from "./favorite_this";
import { MediumLink } from "./medium_link";
import { ShareButton } from "./share_button";

const artPiece = {
  title: "whatever",
  artistName: "joe",
  id: 10,
  imageUrls: {
    large: "whatever.jpg",
  },
};

const errorWithTimeout = (timeout?: number) => {
  new Flash().show({ error: "the error message", timeout });
};

const noticeWithTimeout = (timeout?: number) => {
  new Flash().show({ notice: "a regular notice", timeout });
};

export const ReactTestComponent: FC<ReactTestComponentProps> = (_props) => {
  return (
    <div>
      <FavoriteThis type="Artist" id={10} />
      <FavoriteThis type="whatever" id={310} />

      <ShareButton artPiece={artPiece} type="twitter" />
      <MediumLink medium={{ name: "ceramics", id: 3, slug: "ceramic" }} />

      <div>
        <button onClick={() => errorWithTimeout()}>default error</button>
        <button onClick={() => errorWithTimeout(2000)}>
          error with timeout of 2000
        </button>
        <button onClick={() => errorWithTimeout(-1)}>
          error with timeout of -1 never goes away
        </button>
      </div>
      <div>
        <button onClick={() => noticeWithTimeout()}>default notice</button>
        <button onClick={() => noticeWithTimeout(2000)}>
          notice with timeout of 2000
        </button>
        <button onClick={() => noticeWithTimeout(-1)}>
          notice with timeout of -1 never goes away
        </button>
      </div>
    </div>
  );
};
