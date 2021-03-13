import Flash from "@js/app/jquery/flash";
import { api } from "@js/services/api";
import { ConfirmModal } from "@reactjs/components/confirm_modal";
import { MauButton } from "@reactjs/components/mau_button";
import { MauCheckboxField } from "@reactjs/components/mau_checkbox_field";
import { MauTextField } from "@reactjs/components/mau_text_field";
import { SpecialEventScheduleFields } from "@reactjs/components/open_studios/special_event_schedule_fields";
import { submitRegistration } from "@reactjs/components/open_studios/submit_registration";
import * as types from "@reactjs/types";
import { Form, Formik } from "formik";
import { camelizeKeys } from "humps";
import React, { FC } from "react";

interface OpenStudiosInfoFormProps {
  artistId: number;
  participant: types.OpenStudiosParticipant;
  openStudiosEvent: types.OpenStudiosEvent;
  onUpdateParticipant: (participant: types.OpenStudiosParticipant) => void;
}

// Seems to help with proving the controlled v uncontrolled inputs and Formik
function denullify(participant) {
  const result = { ...participant };
  ["shopUrl", "videoConferenceUrl", "youtubeUrl"].forEach(
    (field) => (result[field] = participant[field] ?? "")
  );
  ["showPhoneNumber", "showEmail"].forEach(
    (field) => (result[field] = participant[field] ?? false)
  );
  return result;
}

export const OpenStudiosInfoForm: FC<OpenStudiosInfoFormProps> = ({
  artistId,
  participant,
  onUpdateParticipant,
  openStudiosEvent: event,
}) => {
  const specialEventDateRange =
    event.specialEvent?.dateRange || event.dateRange;

  const handleUnregistration = (unregistering: boolean) => {
    return submitRegistration(!unregistering).then((data) => {
      onUpdateParticipant(data.participant);
    });
  };

  const handleSubmit = (values, actions) => {
    new Flash().clear();
    actions.setSubmitting(true);
    api.openStudios.participants
      .update({
        id: participant.id,
        artistId: artistId,
        openStudiosParticipant: values,
      })
      .then(({ openStudiosParticipant }) => {
        actions.resetForm({
          values: openStudiosParticipant,
        });
        new Flash().show({ notice: "Super. Got it!" });
        actions.setSubmitting(false);
        onUpdateParticipant(openStudiosParticipant);
      })
      .catch((err) => {
        const { errors } = camelizeKeys(err.responseJSON);
        actions.setErrors(errors);
        new Flash().show({ error: "Whoops. There was a problem." });
        actions.setSubmitting(false);
      });
  };

  return (
    <section id="open-studios-info-form">
      <h3 className="open-studios-info-form__title">Your Open Studios Info</h3>
      <Formik initialValues={denullify(participant)} onSubmit={handleSubmit}>
        {({ dirty, isSubmitting, values }) => {
          return (
            <Form
              className="open-studios-info-form"
              id="open_studios_info_form"
            >
              <p>
                INSTRUCTIONS: You pick how you want to participate in Virtual
                Open Studios. Do you have an online shop? Do you want to
                participate in the Live Video Event {specialEventDateRange}? Do
                you have a YouTube video of your studio or your art? Do you want
                us to display your contact info? For more details,{" "}
                <a href="https://bit.ly/v-openstudios" target="_blank">
                  click here.
                </a>
              </p>

              <fieldset className="inputs">
                <div className="pure-g">
                  <div className="pure-u-1-1 open-studios-info-form__input open-studios-info-form__input--text open-studios-info-form__input--shop-url">
                    <MauTextField
                      label="Shopping Cart Link"
                      name="shopUrl"
                      placeholder="e.g. https://my-art-store.shopify.com/"
                      hint="This link should point to your shopping cart or online store"
                    />
                  </div>
                  <div className="pure-u-1-1 open-studios-info-form__input open-studios-info-form__input--text open-studios-info-form__input--video-conference-url">
                    <MauTextField
                      label="Meeting Link (Zoom or other)"
                      name="videoConferenceUrl"
                      placeholder="e.g. https://my.zoom.room.com/me"
                      hint="This link will connect folks to your video conference that you'd be on during Open Studios"
                    />
                    <SpecialEventScheduleFields
                      specialEvent={event.specialEvent}
                      disabled={!values.videoConferenceUrl}
                    />
                  </div>
                  <div className="pure-u-1-1 open-studios-info-form__input open-studios-info-form__input--text open-studios-info-form__input--youtube-url">
                    <MauTextField
                      label="Youtube Video Link"
                      name="youtubeUrl"
                      placeholder="e.g. https://www.youtube.com/watch?v=abc123"
                      hint="This could be a studio tour, or art demo or..."
                    />
                  </div>
                  <div className="pure-u-1-1 open-studios-info-form__input open-studios-info-form__input--checkbox open-studios-info-form__input--show-email">
                    <MauCheckboxField
                      label={`Show my e-mail during the 2-week Open Studios event (${event.dateRange}).`}
                      name="showEmail"
                    />
                  </div>
                  <div className="pure-u-1-1 open-studios-info-form__input open-studios-info-form__input--checkbox open-studios-info-form__input--show-phone">
                    <MauCheckboxField
                      label={`Show my phone number during the 2-week Open Studios event (${event.dateRange}).`}
                      name="showPhoneNumber"
                    />
                  </div>
                </div>
              </fieldset>
              <div className="open-studios-info-form__actions actions">
                <MauButton
                  type="submit"
                  primary
                  disabled={!dirty && !isSubmitting}
                >
                  Update my details
                </MauButton>
                <ConfirmModal
                  buttonText="Un-Register Me"
                  handleConfirm={handleUnregistration}
                >
                  <p>You will no longer be registered for Open Studios.</p>
                  <p>Would you like to continue?</p>
                </ConfirmModal>
              </div>
            </Form>
          );
        }}
      </Formik>
    </section>
  );
};
