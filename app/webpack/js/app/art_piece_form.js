import { map } from "@js/app/helpers";
import Spinner from "@js/app/spinner";
import jQuery from "jquery";

class ArtPieceForm {
  constructor(selector) {
    this.$form = jQuery(selector);
    this.initializeMediumChooser();
    this.initializeTagChooser();
    this.initializeSubmitSpinner();
  }

  initializeMediumChooser() {
    this.$form.find("#art_piece_medium_id").select2();
  }

  initializeTagChooser() {
    this.$form.find("#art_piece_tag_ids").select2({
      tags: true,
      ajax: {
        method: "post",
        url: "/art_piece_tags/autosuggest",
        data: (params) => ({ q: params.term }),
        delay: 200,
        processResults: ({ art_piece_tags }) => {
          const results = (art_piece_tags || []).map(({ id, name }) => ({
            id,
            text: name,
          }));
          return { results };
        },
      },
    });
  }

  initializeSubmitSpinner() {
    this.$form.find("input[type=submit]").on("click", function () {
      const spinner = new Spinner();
      spinner.spin();
    });
  }
}

export default ArtPieceForm;
