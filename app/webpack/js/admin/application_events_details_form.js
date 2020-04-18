import jQuery from "jquery";

class ApplicationEventsDetailsForm {
  constructor(form) {
    const $form = jQuery(form);
    if ($form) {
      var $numRecordsInput = $form.find("#query_number_of_records");
      var $sinceInput = $form.find("#query_since");
      $sinceInput.on("change", function (_ev) {
        $numRecordsInput.val("");
      });
      $numRecordsInput.on("change", function (_ev) {
        $sinceInput.val("");
      });
    }
  }
}
export default ApplicationEventsDetailsForm;
