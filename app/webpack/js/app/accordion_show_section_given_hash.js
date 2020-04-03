import jQuery from "jquery";

class AccordionShowSectionGivenHash {
  constructor() {
    const hash = window.location.hash;
    if (hash && hash.length > 1) {
      jQuery(hash).collapse("show");
    }
  }
}

export default AccordionShowSectionGivenHash;
