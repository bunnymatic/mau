import React, { FC } from 'react'
import { useModalState } from '@reactjs/hooks/useModalState';
import ReactModal from 'react-modal'

type CreditsWindowProps = {
  version: string,
  handleClose: () => void
}

export const CreditsWindow: FC<CreditsWindowProps> = ({ handleClose, version }) => (
  <>
    <div className="credits-modal__header popup-header">
      <div className="credits-modal__title popup-title">
        Credits
      </div>
      <div className="credits-modal__close popup-close">
        <a title="close" href="#" onClick={(ev) => { ev.preventDefault(); handleClose() }}><i className="fa fa-times"></i></a>
      </div>
    </div>
    <div className="credits-modal__content popup-text">
      <div className="credits-modal__img">
        <img className="pure-img" src="/images/mau-headquarters-small.jpg" />
      </div>
      <p>
        {"Built at MAU Headquarters by "}
        <a href="http://trishtunney.com">Trish Tunney</a>
        {", "}
        <a href="http://rcode5.com">Mr Rogers</a>
        {" and "}
        <span>Liwei Xu</span>
      </p>
      <div className="release_version">
        Version: { version }
      </div>
    </div>
  </>
)

type CreditsModalProps = {
  version: string
}

export const CreditsModal: FC<CreditsModalProps> = ({version}) => {

  const {isOpen, open, close} = useModalState();

  ReactModal.setAppElement('body')

  return (
    <>
      <div className="credits">
        <a href="#" onClick={(ev) => { ev.preventDefault(); open() }}>credits</a>
      </div>
      <ReactModal isOpen={isOpen} className="credits-modal__container"
                  overlayClassName="credits-modal__overlay">
        <CreditsWindow handleClose={close} version={version} />
      </ReactModal>
    </>
  );
}
