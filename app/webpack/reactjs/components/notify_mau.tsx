import React, { FC, useState } from 'react';
import ReactModal from 'react-modal'
import { Field, Form, Formik, FormikProps } from 'formik';

type NotifyMauProps = {
  noteType: string,
  linkText: string,
  withIcon?: boolean,
  email?: string
}

interface NotifyMauWindowProps extends NotifyMauProps {
  handleClose: () => void
}

export const NotifyMauWindow: FC<NotifyMauWindowProps> = ({ handleClose, noteType, linkText, withIcon, email }) => {

  const submit = function ({values,actions}) {
    console.log({values,actions})
    /* const success = function (_data, _status, _headers, _config) {
     *   var flash;
     *   $scope.closeThisDialog();
     *   flash = new Flash();
     *   flash.clear();
     *   flash.show({
     *     notice:
     *       "Thanks for your inquiry.  We'll get back to you as soon as we can.",
     *   });
     * };
     * const error = function (data, _status, _headers, _config) {
     *   var errs, inputs;
     *   inputs = angular.element($element).find("fieldset")[0];
     *   angular.element(inputs.getElementsByClassName("error-msg")).remove();
     *   errs = data.data.error_messages.map((msg) => `<div>${msg}.</div>`);
     *   angular
     *     .element(inputs)
     *     .prepend("<div class='error-msg'>" + errs.join("") + "</div>");
     * };
     * return notificationService
     *   .sendInquiry($scope.inquiry)
     *   .then(success)
     *   .catch(error); */
  };
  return (

    <div class="notify-mau-modal__container">
      <div class="notify-mau-modal__header popup-header">
        <div class="notify-mau-modal__title popup-title">
          Ask us a question?
        </div>
        <div class="notify-mau-modal__close popup-close">
          <a href="#" ng-click="closeThisDialog()"><i class="fa fa-close"></i></a>
        </div>
      </div>
      <div class="notify-mau-modal__content popup-text">
        <Formik
          initialValues={{}}
          onSubmit={submit}
        >
          <Form className="notify-mau-modal__form">
            <p>
              {{message}}
            </p>
            <fieldset class="inputs">
              <ol>
                <li>
                  <Field name="email" type="email" required/>
                </li>
                <li>
                  <Field name="email_confirm" type="email" required/>
                </li>
                <li>
                  <Field name="inquiry"  component=“textarea” />
                </li>
              </ol>
            </fieldset>
            <fieldset class="actions">
              <button
                class="pure-button button-secondary"
                type="submit"
                value="Send"
              />
            </fieldset>
          </Form>
        </Formik>
      </div>
    </div>
  )
}

export const NotifyMau: FC<NotifyMauProps> = ({noteType, linkText, withIcon, email}) => {

  const [isOpen, setIsOpen] = useState<boolean>(false);

  const openModal = () => setIsOpen(true)
  const closeModal = () => setIsOpen(false)
  ReactModal.setAppElement('body')

  return (
    <>
      <div className="notify-mau">
        <a class="mau-note-btn" href="#" ng-click={(ev) => { ev.preventDefault(); openModal() }}
        >
          {linkText}
          {withIcon && <i class="fa fa-envelope"/>}
        </a>
        <ReactModal isOpen={isOpen} className="notify-mau-modal__container"
                    overlayClassName="notify-mau-modal__overlay">
          <NotifyMauWindow handleClose={closeModal} version={version} />
        </ReactModal>
    </>
  );
}
