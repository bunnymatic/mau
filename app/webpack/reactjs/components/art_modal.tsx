import { ArtPiece } from "@models/art_piece.model";
import { ArtWindow } from "@reactjs/components/art_browser/art_window";
import { CloseButton } from "@reactjs/components/close_button";
import { MauModal, setAppElement } from "@reactjs/components/mau_modal";
import { useModalState } from "@reactjs/hooks/useModalState";
import React, { FC } from "react";

interface ArtModalWindowProps {
  artPiece: ArtPiece;
  handleClose: (MouseEvent) => void;
}

const ArtModalWindow: FC<ArtModalWindowProps> = ({ artPiece, handleClose }) => {
  setAppElement("body");

  return (
    <MauModal
      className="art-modal__content"
      isOpen={true}
      onRequestClose={handleClose}
    >
      {artPiece && (
        <>
          <div className="art-modal__close">
            <CloseButton handleClick={handleClose} />
          </div>
          <ArtWindow art={artPiece} />
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
