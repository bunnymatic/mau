import Flash from "@js/app/jquery/flash";
import { jsonApi as api } from "@js/services";
import { ArtPiece } from "@models/art_piece.model";
import { ArtWindow } from "@reactjs/components/art_browser/art_window";
import { CloseButton } from "@reactjs/components/close_button";
import { MauModal, setAppElement } from "@reactjs/components/mau_modal";
import { Spinner } from "@reactjs/components/spinner";
import { useModalState } from "@reactjs/hooks/useModalState";
import React, { FC, useEffect, useState } from "react";

interface ArtModalWindowProps {
  id: number;
  handleClose: (MouseEvent) => void;
}

const ArtModalWindow: FC<ArtModalWindowProps> = ({ id, handleClose }) => {
  const [artPiece, setArtPiece] = useState<ArtPiece>();

  useEffect(() => {
    api.artPieces
      .get(id)
      .then(setArtPiece)
      .catch((_error) => {
        new Flash().show({
          error: "We are having some issues getting that art.  Sorry!",
        });
      });
  }, []);
  setAppElement("body");

  return (
    <MauModal
      className="art-modal__content"
      isOpen={true}
      onRequestClose={handleClose}
    >
      {artPiece ? (
        <>
          <div className="art-modal__close">
            <CloseButton handleClick={handleClose} />
          </div>
          <ArtWindow art={artPiece} />
        </>
      ) : (
        <Spinner />
      )}
    </MauModal>
  );
};

interface ArtModalProps {
  id: number;
}

export const ArtModal: FC<ArtModalProps> = ({ id, children }) => {
  const { isOpen, open, close } = useModalState(false);
  return (
    <>
      {isOpen && <ArtModalWindow id={id} handleClose={close} />}
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
