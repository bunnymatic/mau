import { MauModal, setAppElement } from "@reactjs/components/mau_modal";
import { OpenStudiosEventType } from '@reactjs/types';
import { OpenStudiosInfoForm } from "@reactjs/components/open_studios/open_studios_info_form"
import { MauButton } from '@reactjs/components/mau_button';
import { mailToLink } from "@js/services/mailer.service";
import { useModalState } from "@reactjs/hooks/useModalState";
import { api } from "@js/services/api";
import Flash from "@js/app/jquery/flash";
import { isNil } from "@js/app/helpers";
import React, {FC, useState, useEffect} from 'react'

interface OpenStudiosRegistrationWindowProps {
  location: string;
  dateRange: string;
  onClose: () => void;
}

const submitRegistrationStatus = (status: boolean) => {
  return api.users.whoami().then(function ({ currentUser }) {
    if (currentUser && currentUser.slug) {
      return api.users.registerForOs(currentUser.slug, status);
    }
  })
}

const OpenStudiosRegistrationWindow:FC<OpenStudiosRegistrationWindowProps> = ({location, dateRange, onClose}) => {

  const setRegistration = (status: boolean) => {
    const flash = new Flash();
    return submitRegistrationStatus(status).then(() => {
      onClose(status);
      flash.show({
        notice:
          "We've updated your registration status"
      });
    }).catch(() => {
      onClose(status)
      flash.show({
        error:
          "We had problems updating your open studios status.  Please try again later"
      });
    })
  }
  const accept = ()=> setRegistration(true)
  const decline = () => setRegistration(false)

  const hasQuestions = () => {
    onClose()
    window.location = mailToLink(
      "I have questions about registering for Open Studios"
    );
  }
  return (<div className="open-studios-modal__container" id="open-studios-registration-form">
    <div className="open-studios-modal__header popup-header">
      <div className="open-studios-modal__title popup-title">
        Register For Open Studios
      </div>
      <div className="open-studios-modal__close popup-close">
        <a href="#" onClick={(ev) => {ev.preventDefault; onClose()}} ><i className="fa fa-times"></i></a>
      </div>
    </div>
    <div className="open-studios-modal__content popup-text">
      <p>
        You are registering to participate as an Open Studios artist for {dateRange}.
      </p>
      <p>
        This means you are committing to:
      </p>
      <ol>
        <li>
          Hang some art at your studio - {location}
        </li>
        <li>
          Be there to receive the public during your (possibly) scheduled video conference time
        </li>
        <li>
          Promote your art and your studio’s participation in the event. (We’ll send you tools if you need them)
        </li>
      </ol>
      <p>
        Continue with registration?
      </p>
      <div className="actions open-studios-registration-form__actions">
        <div className="open-studios-registration-form__action-item">
          <MauButton primary onClick={accept}>Yes</MauButton>
        </div>
        <div className="open-studios-registration-form__action-item">
          <MauButton secondary onClick={decline}>No</MauButton>
        </div>
        <div className="open-studios-registration-form__action-item">
          <MauButton secondary onClick={hasQuestions}>I have questions</MauButton>
        </div>
      </div>
    </div>
  </div>)
}

interface OpenStudiosRegistrationProps {
  location: string;
  openStudiosEvent: OpenStudiosEventType;
  participating: Boolean;
  autoRegister: Boolean;
};


export const OpenStudiosRegistration:FC<{
  location: string;
  openStudiosEvent: OpenStudiosEventType;
  participating: Boolean;
  autoRegister: Boolean;
}> = ({participating, location, openStudiosEvent, autoRegister}) => {
  let message: string;
  let buttonText: string;

  const {isOpen, open, close} = useModalState();
  const [isParticipating, setIsParticipating] = useState<boolean>(participating)

  useEffect(() => {
    if(autoRegister) {
      open()
    }
  },[autoRegister])

  const handleClose = (result?: boolean) => {
    if (!isNil(result)) {
      setIsParticipating(result)
    }
    close()
  };
  if (isParticipating) {
    message = `Yay! You are currently registered for Open Studios on ${openStudiosEvent.dateRange}`
    buttonText = "Update my registration status"
  } else {
    message = `Will you be participating in Open Studios on ${openStudiosEvent.dateRange}`;
    buttonText = "Yes - Register Me";
  }

  setAppElement('body')

  return (<>
    <p>
      { message }
    </p>
    { isParticipating ? <OpenStudiosInfoForm/> : null }
    <div id="open-studios-registration-button">
      <MauButton primary onClick={(ev) => { ev.preventDefault(); open() }} >
        {buttonText}
      </MauButton>
    </div>
    <MauModal isOpen={isOpen} >
      <OpenStudiosRegistrationWindow onClose={handleClose} location={location} dateRange={openStudiosEvent?.dateRange}  />
    </MauModal>
  </>);
}
