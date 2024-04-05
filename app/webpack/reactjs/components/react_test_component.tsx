import React, { type FC,type ReactNode, useState } from "react";

interface ReactTestComponentProps {}
import * as types from "@reactjs/types";
import { FavoriteThis } from "./favorite_this";
import { MediumLink } from "./medium_link";
import { ShareButton } from "./share_button";
import { FlashMessage } from "./flash_message/flash_message";

const artPiece = {
  title: "whatever",
  artistName: "joe",
  id: 10,
  imageUrls: {
    large: "whatever.jpg",
  },
};

type FlashExample = "error" | "errorWithTimeout" | "errorPersistent" | "notice" | "warning" | "debug";

export const ReactTestComponent: FC<ReactTestComponentProps> = (_props) => {

  const [flashExample, setFlashExample] = useState<FlashExample|undefined>();

  let flashComponent: ReactNode;
  switch(flashExample) {
    case "error":
      flashComponent = <FlashMessage type={types.FlashType.Error} message="standard error flash"/>
      break;
    case "errorWithTimeout":
      flashComponent = <FlashMessage type={types.FlashType.Error} message="error with 2 second timeout" timeoutMilliseconds={2000}/>
      break;
    case "errorPersistent":
      flashComponent = <FlashMessage type={types.FlashType.Error} message="error flash with\nnegative timeout\nand a multi line message\nWe'll never leave you" timeoutMilliseconds={-1}/>
      break;
    case "notice":
      flashComponent = <FlashMessage type={types.FlashType.Notice} message="You have been notified" />
      break;
    case "warning":
      flashComponent = <FlashMessage type={types.FlashType.Warning} message="I'm warning you"/>
      break;
    case "debug":
      flashComponent = <FlashMessage type={types.FlashType.Debug} message="debug flash"/>
      break;
    default:
  }

  const buttonClass = "pure-button button-secondary"
  return (
    <div>
      <FavoriteThis type="Artist" id={10} />
      <FavoriteThis type="whatever" id={310} />

      <ShareButton artPiece={artPiece} type="twitter" />
      <MediumLink medium={{ name: "ceramics", id: 3, slug: "ceramic" }} />

      <div className="pure-g">
        {flashExample}
        {flashComponent}
        <div className="pure-u-1-3">
          <button className={buttonClass} onClick={() => setFlashExample("error")}>Show error flash </button>
        </div>
        <div className="pure-u-1-3">
          <button className={buttonClass} onClick={() => setFlashExample("errorWithTimeout")}>Show error with timeout flash </button>
        </div>
        <div className="pure-u-1-3">
          <button className={buttonClass} onClick={() => setFlashExample("errorPersistent")}>Show error persistent flash </button>
        </div>
        <div className="pure-u-1-3">
          <button className={buttonClass} onClick={() => setFlashExample("warning")}>Show warning flash </button>
        </div>
        <div className="pure-u-1-3">
          <button className={buttonClass} onClick={() => setFlashExample("notice")}>Show notice flash </button>
        </div>
        <div className="pure-u-1-3">
          <button className={buttonClass} onClick={() => setFlashExample("debug")}>Show debug flash </button>
        </div>
      </div>
    </div>
  );
};
