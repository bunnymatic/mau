import { map } from "@js/app/helpers";
import Spinner from "@js/app/spinner";
import { post } from "@js/mau_ajax";
import jQuery from "jquery";

const selectizeMapper = (input) => ({ value: input, text: input });

class ArtPieceForm {
  constructor(selector) {
    this.$form = jQuery(selector);
    this.initializeMediumChooser();
    this.initializeTagChooser();
    this.initializeSubmitSpinner();
  }

  initializeMediumChooser() {
    this.$form.find("#art_piece_medium_id").selectize();
  }

  initializeTagChooser() {
    this.$form.find("#art_piece_tag_ids").selectize({
      delimiter: ",",
      persist: false,
      sortField: "text",
      create: selectizeMapper,
      render: (data, _escape) => data,
      load: function (query, callback) {
        if (query.length < 3) {
          callback();
        }
        return post(
          "/art_piece_tags/autosuggest",
          {
            q: query,
          },
          {
            error: callback,
            success: function (results) {
              return callback(map(results, selectizeMapper));
            },
          }
        );
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
