import $ from "jquery";
import map from "lodash/map";
import Spinner from "../mau_spinner";
import { post } from "@js/mau_ajax";

(function() {
  $(function() {
    var $artPieceForm;
    $artPieceForm = $(".art_piece.formtastic");
    if ($artPieceForm.length) {
      $("#art_piece_medium_id").selectize();
      $("input[type=submit]").on("click", function() {
        var spinner;
        if (/add/i.test($(this).val())) {
          spinner = new Spinner();
          return spinner.spin();
        }
      });
      $("#art_piece_tag_ids").selectize({
        delimiter: ",",
        persist: false,
        sortField: "text",
        create: function(input) {
          return {
            value: input,
            text: input
          };
        },
        render: function(data, _escape) {
          return data;
        },
        load: function(query, callback) {
          if (query.length < 3) {
            callback();
          }
          return post(
            "/art_piece_tags/autosuggest",
            {
              q: query
            },
            {
              error: function() {
                return callback();
              },
              success: function(results) {
                return callback(
                  map(results, function(result) {
                    return {
                      value: result,
                      text: result
                    };
                  })
                );
              }
            }
          );
        }
      });
    }
  });
}.call(this));
