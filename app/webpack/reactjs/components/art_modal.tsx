import { ARROW_LEFT_KEY, ARROW_RIGHT_KEY } from "@js/event_constants";
import { ArtPiece } from "@models/art_piece.model";
import { ArtWindow } from "@reactjs/components/art_browser/art_window";
import { CloseButton } from "@reactjs/components/close_button";
import { MauModal, setAppElement } from "@reactjs/components/mau_modal";
import { ArtPiecesContext } from "@reactjs/contexts/art_pieces.context";
import {
  useCarouselState,
  useEventListener,
  useModalState,
} from "@reactjs/hooks";
import React, { FC, useCallback, useContext } from "react";

interface ArtModalWindowProps {
  artPiece: ArtPiece;
  handleClose: (MouseEvent) => void;
}

const ArtModalWindow: FC<ArtModalWindowProps> = ({ artPiece, handleClose }) => {
  setAppElement("body");

  const { artPieces } = useContext(ArtPiecesContext);
  const { current, next, previous } = useCarouselState(artPieces, artPiece);

  const keyDownHandler = useCallback((e) => {
    if (e.key === ARROW_LEFT_KEY) {
      previous();
    }
    if (e.key === ARROW_RIGHT_KEY) {
      next();
    }
  });

  useEventListener("keydown", keyDownHandler);

  const handleNext = (e: MouseEvent) => {
    e.preventDefault();
    next();
  };
  const handlePrevious = (e: MouseEvent) => {
    e.preventDefault();
    previous();
  };
  return (
    <MauModal
      className="art-modal__content"
      isOpen={true}
      onRequestClose={handleClose}
    >
      {current && (
        <>
          <a
            href="#"
            title="previous"
            className="art-modal__previous"
            onClick={handlePrevious}
          >
            <i className="fa fa-chevron-left" />
          </a>
          <div className="art-modal__window-wrapper">
            <ArtWindow art={current} />
          </div>
          <a
            href="#"
            title="next"
            className="art-modal__next"
            onClick={handleNext}
          >
            <i className="fa fa-chevron-right" />
          </a>
          <div className="art-modal__close">
            <CloseButton handleClick={handleClose} />
          </div>
        </>
      )}
    </MauModal>
  );
};

interface ArtModalProps {
  artPiece: ArtPiece;
}

export const ArtModal: FC<ArtModalProps> = ({ artPiece, children }) => {
  const { isOpen, open, close } = useModalState(false);
  return (
    <>
      {isOpen && <ArtModalWindow artPiece={artPiece} handleClose={close} />}
      <div
        onClick={(ev) => {
          ev.preventDefault();
          open();
        }}
      >
        {children}
      </div>
    </>
  );
};
