import jQuery from "jquery";

class AccordionShowSectionWithErrors {
  constructor() {
    jQuery(".error").closest(".collapse").collapse("show");
  }
}

export default AccordionShowSectionWithErrors;
