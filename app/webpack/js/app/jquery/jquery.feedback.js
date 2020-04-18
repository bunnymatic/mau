import { post } from "@js/mau_ajax";
import jQuery from "jquery";

jQuery.fn.feedback = function () {
  const formId = "feedback_form";
  const mainId = "feedback";
  const modalWindowId = "feedback_modal_window";
  const modalContentId = "feedback_modal_content";
  const overlayId = "feedback_overlay";

  const formUrl = "/feedbacks/new";

  const feedbackTemplate =
    `<div id="${mainId}" style="display: none;">` +
    `  <div id="${modalWindowId}" >` +
    `    <div id="${modalContentId}" ></div>` +
    "  </div>" +
    "</div>";
  const overlayTemplate = `<div id="${overlayId}"></div>`;

  const selectors = {
    closeLink: ".feedback_close",
    main: `#${mainId}`,
    modalWindow: `#${modalWindowId}`,
    modalContent: `#${modalContentId}`,
    form: `#${formId}`,
    overlay: `#${overlayId}`,
  };

  const submitFeedback = function () {
    jQuery("input[name=feedback\\[page\\]]").val(location.href);
    const data = jQuery(selectors.form).serialize();
    const url = jQuery.trim(jQuery(selectors.form).attr("action"));
    post(url, data, {
      success: function (msg, _status) {
        jQuery(selectors.modalContent).html(msg);
        setTimeout(function () {
          jQuery(selectors.modalWindow).fadeOut(500, hide);
        }, 3000);
      },
      error: function (xhr, _status, _a) {
        jQuery(selectors.modalContent).html(xhr.responseText);
        jQuery(selectors.form).submit(submitFeedback);
      },
    });
    return false;
  };

  const show = function () {
    if (jQuery(selectors.main).length == 0) {
      jQuery("body").append(feedbackTemplate);
      jQuery(selectors.main).on("click", selectors.closeLink, hide);
    }
    if (jQuery(selectors.overlay).length == 0) {
      jQuery("body").append(overlayTemplate);
    }
    jQuery(selectors.overlay).show();
    jQuery(selectors.main).show();
  };

  const hide = function () {
    jQuery(selectors.main).hide();
    jQuery(selectors.main).remove();
    jQuery(selectors.overlay).remove();
    return false;
  };

  jQuery(this).click(function () {
    show();
    jQuery(selectors.modalContent).load(formUrl, null, function () {
      jQuery(selectors.form).submit(submitFeedback);
    });
    return false;
  });
};
