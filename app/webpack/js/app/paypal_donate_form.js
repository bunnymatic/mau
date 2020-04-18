import jQuery from "jquery";

class PaypalDonateForm {
  constructor(button, donateForm) {
    jQuery(button).on("click", function (ev) {
      ev.preventDefault();
      jQuery(donateForm).submit();
    });
  }
}

export default PaypalDonateForm;
