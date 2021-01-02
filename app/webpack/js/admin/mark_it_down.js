import { debounce } from "@js/app/utils";
import { ajaxSetup } from "@js/services/mau_ajax";
import jQuery from "jquery";

const markItDown = (input, output) => {
  var $input = jQuery(input);
  var markdown = $input.val() || "## no markdown to process";
  jQuery(output).load("/admin/discount/markup", { markdown });
};

class MarkItDown {
  constructor(textarea, markdownOutputContainer, debounceTimeMs) {
    ajaxSetup(jQuery);
    jQuery(textarea).on(
      "change",
      debounce(
        () => {
          markItDown(textarea, markdownOutputContainer);
        },
        debounceTimeMs,
        false
      )
    );
  }
}

export default MarkItDown;
