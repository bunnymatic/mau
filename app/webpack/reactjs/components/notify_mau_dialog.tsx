import Flash from "@js/app/jquery/flash";
import {
  MauHiddenField,
  MauTextAreaField,
  MauTextField,
} from "@reactjs/components/form_fields";
import { MauButton } from "@reactjs/components/mau_button";
import { MauModal, setAppElement } from "@reactjs/components/mau_modal";
import { MauTextButton } from "@reactjs/components/mau_text_button";
import { useModalState } from "@reactjs/hooks";
import { sendInquiry } from "@services/notification.service";
import { Form, Formik } from "formik";
import React, { FC } from "react";

type NoteTypes = "inquiry" | "help";

interface NotifyMauFormProps {
  noteType: NoteTypes;
  email?: string;
  onCancel: () => void;
  onSuccess: () => void;
}

interface NoteInfo {
  message: string;
  questionLabel: string;
}

const NOTE_INFO_LUT = {
  inquiry: {
    message:
      "We love to hear from you.  Please let us know your thoughts, questions, rants." +
      " We'll do our best to respond in a timely manner.",
    questionLabel: "Your Question",
  },
  help: {
    message:
      "Ack.  So sorry you're having issues.  Our developers are only human." +
      " You may have found a bug in our system.  Please tell us what you were doing and what wasn't working." +
      " We'll do our best to fix the issue and get you rolling as soon as we can.",
    questionLabel: "What went wrong?  What doesn't work?",
  },
};

const noteInfo: Record<NoteTypes, NoteInfo> = (noteType: NoteTypes) => {
  return NOTE_INFO_LUT[noteType];
};

const fieldIsRequired = (fieldName, values, errors = {}) => {
  if (!values[fieldName]) {
    errors[fieldName] ||= [];
    errors[fieldName].push("is required");
  }
};

function denullify(formValues) {
  const result = { ...formValues };
  ["email", "emailConfirm", "inquiry"].forEach(
    (field) => (result[field] = formValues[field] ?? "")
  );
  return result;
}

const NotifyMauForm: FC<NotifyMauFormProps> = ({
  noteType,
  email,
  onSuccess,
  onCancel,
}) => {
  const { message, questionLabel } = noteInfo(noteType);
  const handleSubmit = (values, actions) => {
    const flash = new Flash();
    flash.clear();
    actions.setSubmitting(true);
    return sendInquiry(values)
      .then(() => {
        actions.setSubmitting(false);
        flash.show({
          notice:
            "Thanks for your inquiry.  We'll get back to you as soon as we can.",
        });
        onSuccess();
      })
      .catch((_err) => {
        actions.setSubmitting(false);
        flash.show({
          error:
            "Sorry, something went wrong.  Please try your question later.",
        });
      });
  };
  const handleCancel = () => {
    onCancel();
  };
  const validate = (values) => {
    const errors = {};
    fieldIsRequired("email", values, errors);
    fieldIsRequired("emailConfirm", values, errors);
    fieldIsRequired("inquiry", values, errors);

    if (values.email !== values.emailConfirm) {
      errors.emailConfirm ||= [];
      errors.emailConfirm.push("must match email");
    }

    return errors;
  };

  return (
    <div className="notify-mau-modal__container">
      <div className="notify-mau-modal__header popup-header">
        <div className="notify-mau-modal__title popup-title">
          Ask us a question?
        </div>
        <div className="notify-mau-modal__close popup-close">
          <a href="#" ng-click="closeThisDialog()">
            <i className="fa fa-times"></i>
          </a>
        </div>
      </div>
      <div className="notify-mau-modal__content popup-text">
        <Formik
          initialValues={denullify({ email, noteType })}
          onSubmit={handleSubmit}
          validate={validate}
        >
          {({ dirty, isSubmitting }) => (
            <Form className="notify-mau-modal__form">
              <p>{message}</p>
              <fieldset className="inputs">
                <MauHiddenField name="noteType" />
                <ol>
                  <li className="stringish input">
                    <MauTextField
                      label="Email"
                      name="email"
                      type="email"
                      required
                    />
                  </li>
                  <li className="stringish input">
                    <MauTextField
                      label="Confirm Email"
                      name="emailConfirm"
                      type="email"
                      required
                    />
                  </li>
                  <li className="stringish input">
                    <MauTextAreaField
                      label={questionLabel}
                      name="inquiry"
                      required
                    />
                  </li>
                </ol>
              </fieldset>
              <fieldset className="actions">
                <MauButton
                  primary
                  disabled={!dirty && !isSubmitting}
                  type="submit"
                >
                  Send
                </MauButton>
                <MauButton secondary onClick={handleCancel}>
                  Cancel
                </MauButton>
              </fieldset>
            </Form>
          )}
        </Formik>
      </div>
    </div>
  );
};

interface NotifyMauDialogProps {
  noteType: NoteTypes;
  linkText: string;
  withIcon?: boolean;
  email?: string;
}

export const NotifyMauDialog: FC<NotifyMauDialogProps> = ({
  noteType,
  linkText,
  withIcon,
  email,
}) => {
  const { isOpen, open, close } = useModalState();

  setAppElement("body");

  const icon = withIcon ? <i className="fa fa-envelope" /> : null;
  return (
    <>
      <span className="mau-modal confirm-modal__trigger">
        <MauTextButton
          title={linkText}
          onClick={(ev) => {
            ev.preventDefault();
            open();
          }}
        >
          {linkText} {icon}
        </MauTextButton>
      </span>
      <MauModal isOpen={isOpen}>
        <NotifyMauForm
          noteType={noteType}
          email={email}
          onSuccess={close}
          onCancel={close}
        />
      </MauModal>
    </>
  );
};
