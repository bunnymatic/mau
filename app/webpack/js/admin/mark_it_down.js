import jQuery from "jquery";
import { ajaxSetup } from "@js/mau_ajax";
import { debounce } from "@js/app/utils";

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
