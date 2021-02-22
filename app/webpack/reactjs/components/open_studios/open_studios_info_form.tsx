import { Field, Form, Formik, FormikProps } from 'formik';
import { MauButton } from "@reactjs/components/mau_button";
import { MauCheckboxField } from "@reactjs/components/mau_checkbox_field"
import { MauTextField } from "@reactjs/components/mau_text_field"
import React, {FC} from 'react'


interface OpenStudiosInfoFormProps {};


export const OpenStudiosInfoForm:FC<OpenStudiosInfoFormProps> = () => {
  const handleSubmit = (values, actions) => {
    actions.setSubmitting(true)


    console.log(values, actions)
  }

  return (<div id="open_studios_info_form" >
    <Formik
      initialValues={{}}
      onSubmit={handleSubmit}
    >{({values}) => {
        return (<Form className="open-studios-info-form">
          <h4>Details</h4>
          <fieldset className="inputs">
            <div className="pure-g">
              <div className="pure-u-1-1 pure-u-sm-1-2 open-studios-info-form__input open-studios-info-form__input--text open-studios-info-form__input--shop-url">
                <MauTextField label="Shop Link" name="shop_url" placeholder="e.g. https://my-art-store.shopify.com/" />
              </div>
              <div className="pure-u-1-1 pure-u-sm-1-2 open-studios-info-form__input open-studios-info-form__input--text open-studios-info-form__input--video-url">
                <MauTextField label="Video Conference Link" name="video_conference_url" placeholder="e.g. the link to your zoom or Google hangout or ..." />
              </div>
              <div className="pure-u-1-1 pure-u-sm-1-2 open-studios-info-form__input open-studios-info-form__input--checkbox open-studios-info-form__input--show-email">
                <MauCheckboxField label="Show Email" name="show_email" hint="If checked, we'll add a link that users can use to email you directly on your personal Open Studios page for the duration of the event" />
              </div>
              <div className="pure-u-1-1 pure-u-sm-1-2 open-studios-info-form__input open-studios-info-form__input--checkbox open-studios-info-form__input--show-phone">
                <MauCheckboxField label="Show Phone Number" name="show_phone" hint="If checked, we'll show your phone number on your personal Open Studios page for the duration of the event" />
              </div>
            </div>
          </fieldset>
          <MauButton>Save Details</MauButton>
        </Form>)
    }}
    </Formik>
  </div>)
}
