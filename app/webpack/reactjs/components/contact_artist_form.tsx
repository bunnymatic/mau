import Flash from "@js/app/jquery/flash";
import { ArtPiece } from "@models/art_piece.model";
import {
  MauTextAreaField,
  MauTextField,
} from "@reactjs/components/form_fields";
import { MauButton } from "@reactjs/components/mau_button";
import { api } from "@services/api";
import { Form, Formik } from "formik";
import { camelizeKeys } from "humps";
import React, { FC } from "react";

interface ContactArtistFormProps {
  artPiece: ArtPiece;
  handleClose: (ev: MouseEvent) => void;
}

const DEFAULT_FORM_VALUES = {
  name: "",
  email: "",
  phone: "",
  message: "",
};

const validate = (values) => {
  const errors = {};
  if (!values.name) {
    errors["name"] = "Name is required";
  }
  if (!values.email && !values.phone) {
    errors["email"] = "Email or Phone is required";
    errors["phone"] = "Email or Phone is required";
  }
  if (
    values.phone &&
    !values.phone.match(/^\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$/)
  ) {
    errors["phone"] = "That doesn't look like a real phone number";
  }
  return errors;
};

export const ContactArtistForm: FC<ContactArtistFormProps> = ({
  artPiece,
  handleClose,
}) => {
  const handleSubmit = (values, actions) => {
    const done = () => {
      actions.setSubmitting(false);
      handleClose();
    };

    actions.setSubmitting(true);
    api.artPieces
      .contact(artPiece.id, values)
      .then(({ openStudiosParticipant }) => {
        actions.resetForm({
          values: openStudiosParticipant,
        });
        new Flash().show({ notice: "Thanks.  We sent a note to the artist!" });
        done();
      })
       .catch((err) => {
         let error;
         actions.setSubmitting(false);
         try {
           const { errors } = camelizeKeys(err.responseJSON);
           actions.setErrors(errors);
           error = "Whoops. There was a problem."
         } catch (e) {
           console.error(e)
           error = "Ack. Something is seriously wrong. Please try again later."
         }
         new Flash().show({ error });
      });
  };

  return (
    <div className="contact-artist__container">
      <h3 className="contact-artist__header">
        Send the artist a note about this piece!
      </h3>
      <Formik
        initialValues={DEFAULT_FORM_VALUES}
        onSubmit={handleSubmit}
        validate={validate}
      >
        {({ dirty, isSubmitting }) => {
          return (
            <Form className="contact-artist__form" id="contact_artist_form">
              <fieldset className="inputs">
                <div className="pure-g">
                  <div className="pure-u-1-1 contact-artist__input">
                    <MauTextField label={"Your Name"} name="name" />
                  </div>
                </div>
                <div className="pure-g">
                  <div className="pure-u-1-1 contact-artist__input">
                    <MauTextField
                      type="email"
                      label={"Your Email"}
                      name="email"
                    />
                  </div>
                </div>
                <div className="pure-g">
                  <div className="pure-u-1-1 contact-artist__input">
                    <MauTextField
                      label={"Your Phone"}
                      name="phone"
                      hint="The message below is optional but either email or phone is required."
                    />
                  </div>
                </div>
                <div className="pure-g">
                  <div className="pure-u-1-1 contact-artist__input">
                    <MauTextAreaField label={"Message"} name="message" />
                  </div>
                </div>
              </fieldset>
              <div className="contact-artist__form__actions actions">
                <MauButton
                  type="submit"
                  primary
                  disabled={!dirty && !isSubmitting}
                >
                  Send!
                </MauButton>
                <MauButton onClick={handleClose}>Cancel</MauButton>
              </div>
            </Form>
          );
        }}
      </Formik>
    </div>
  );
};
