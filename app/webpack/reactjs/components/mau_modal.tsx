import React, {FC} from 'react'

import ReactModal from 'react-modal'

type MauModalProps = ReactModal.Props;

const MauModal:FC<MauModalProps> = ({children, ...props}) => {
  const style = {
    overlay: {
      display: "flex",
      justifyContent: "center",
      alignItems: "center",
      zIndex: 1500,
    },
    content: {
      top: "auto",
      left: "auto",
      right: "auto",
      bottom: "auto",
    }
  }
  return <ReactModal {...props } style={ style }>{children}</ReactModal>
}

const setAppElement = ReactModal.setAppElement;

export { MauModal, setAppElement}
