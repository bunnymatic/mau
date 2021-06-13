import Flash from "@js/app/flash";
import { MauTextField } from "@reactjs/components/form_fields";
import { MauButton } from "@reactjs/components/mau_button";
import { MauModal, setAppElement } from "@reactjs/components/mau_modal";
import { MauTextButton } from "@reactjs/components/mau_text_button";
import { useModalState } from "@reactjs/hooks";
import * as types from "@reactjs/types";
import { api } from "@services/api";
import { Form, Formik } from "formik";
import { camelizeKeys } from "humps";
import React, { FC } from "react";

export type OnAddCallback = ({ email: string, name: string }) => void;

export interface AddEmailModalProps {
  onAdd: OnAddCallback;
  listId: types.IdType;
}

export const AddEmailModal: FC<AddEmailModalProps> = ({ listId, onAdd }) => {
  const { isOpen, open, close } = useModalState();

  const handleSubmit = ({ email, name }, actions) => {
    return api.emailLists.emails
      .save(listId, { email: { email, name } })
      .then(() => {
        onAdd({ email, name });
        close();
      })
      .catch((err) => {
        if (err && err.responseJSON) {
          const { errors } = camelizeKeys(err.responseJSON);
          actions.setErrors(errors);
        } else {
          new Flash().show({ error: "Ack.  Something is not right!" });
          close();
        }
      });
  };
  setAppElement("body");

  return (
    <>
      <MauTextButton onClick={() => open()} title="add an email to this list">
        <i className="fa fa-plus-circle" />
      </MauTextButton>

      <MauModal isOpen={isOpen}>
        <div className="add-email-form__wrapper">
          <h4>Email to Add</h4>
          <Formik
            initialValues={{ email: "", name: "" }}
            onSubmit={handleSubmit}
          >
            {({ dirty, isSubmitting }) => (
              <Form className="add-email-form">
                <fieldset className="inputs">
                  <MauTextField label="Name" name="name" />
                  <MauTextField label="Email" name="email" type="email" />
                </fieldset>
                <fieldset className="actions">
                  <MauButton
                    type="submit"
                    primary
                    disabled={!dirty && !isSubmitting}
                  >
                    Add
                  </MauButton>
                  <MauButton onClick={() => close()}>Cancel</MauButton>
                </fieldset>
              </Form>
            )}
          </Formik>
        </div>
      </MauModal>
    </>
  );
};
