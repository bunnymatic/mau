import Flash from "@js/app/jquery/flash";
import Spinner from "@js/app/spinner";
import jQuery from "jquery";

const MAX_FILE_SIZE_MB = 6;

const validateFileSize = (event) => {
  const fileInput = event.currentTarget;
  if (fileInput.type != "file" || !fileInput.files.length) {
    return;
  }

  let ii = 0;
  for (; ii < fileInput.files.length; ++ii) {
    const size = fileInput.files.item(ii).size;
    const sizeMb = Math.round(size / (1024 * 1024));
    if (sizeMb > MAX_FILE_SIZE_MB) {
      const flash = new Flash();
      flash.show({
        error: "That file may be a little too big. 4MB or smaller is ideal.",
      });
    }
  }
};

class ArtPieceForm {
  constructor(selector) {
    this.$form = jQuery(selector);
    this.initializeMediumChooser();
    this.initializeTagChooser();
    this.initializeSubmitSpinner();
    this.initializeFileSizeValidator();
  }

  initializeFileSizeValidator() {
    const $file = this.$form.find("#art_piece_photo[type=file]");
    $file.on("change", validateFileSize);
    $file.on("click", () => new Flash().clear());
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
          const results = (art_piece_tags || []).map(
            ({ art_piece_tag: { id, name } }) => ({
              id,
              text: name,
            })
          );
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
