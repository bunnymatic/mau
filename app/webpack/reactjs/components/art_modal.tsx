import { ARROW_LEFT_KEY, ARROW_RIGHT_KEY } from "@js/event_constants";
import { ArtPiece } from "@models/art_piece.model";
import { ArtWindow } from "@reactjs/components/art_browser/art_window";
import { CloseButton } from "@reactjs/components/close_button";
import { ContactArtistForm } from "@reactjs/components/contact_artist_form";
import { MauModal, setAppElement } from "@reactjs/components/mau_modal";
import { ArtPiecesContext } from "@reactjs/contexts/art_pieces.context";
import {
  useCarouselState,
  useEventListener,
  useModalState,
} from "@reactjs/hooks";
import HeartSpeechBubble from "images/heart_speech_bubble.svg";
import React, { FC, useCallback, useContext } from "react";

interface ArtModalWindowProps {
  artPiece: ArtPiece;
  handleClose: (MouseEvent) => void;
}

const ArtModalWindow: FC<ArtModalWindowProps> = ({ artPiece, handleClose }) => {
  setAppElement("body");

  const { artPieces } = useContext(ArtPiecesContext);
  const { current, next, previous } = useCarouselState(artPieces, artPiece);
  const {
    isOpen: isFormVisible,
    open: showForm,
    close: hideForm,
  } = useModalState(false);

  const contactArtistTitle = `Contact the artist directy ${artPiece.title}`;
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
  const handleShowContactForm = (e: MouseEvent) => {
    e.preventDefault();
    showForm();
  };

  const prevButton = (
    <a
      href="#"
      title="previous"
      className="art-modal__previous"
      onClick={handlePrevious}
    >
      <i className="fa fa-chevron-left" />
    </a>
  );

  const nextButton = (
    <a href="#" title="next" className="art-modal__next" onClick={handleNext}>
      <i className="fa fa-chevron-right" />
    </a>
  );

  const closeButton = (
    <div className="art-modal__close">
      <CloseButton handleClick={handleClose} />
    </div>
  );

  return (
    <MauModal
      className="art-modal__content"
      isOpen={true}
      onRequestClose={handleClose}
    >
      {current && (
        <>
          {!isFormVisible && prevButton}
          <div className="art-modal__window-wrapper">
            {isFormVisible ? (
              <ContactArtistForm artPiece={current} handleClose={hideForm} />
            ) : (
              <ArtWindow art={current} />
            )}
            <a
              href="#"
              onClick={handleShowContactForm}
              title={contactArtistTitle}
              className="art-window__contact-artist"
            >
              <img src={HeartSpeechBubble} title={contactArtistTitle} />
            </a>
          </div>
          {!isFormVisible && nextButton}
          {!isFormVisible && closeButton}
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
