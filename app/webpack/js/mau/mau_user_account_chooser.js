import jQuery from "jquery";
import QueryStringParser from "./query_string_parser";
import Spinner from "./mau_spinner.js";
(function () {
  jQuery(function () {
    jQuery("#account_type_chooser").bind("change", function () {
      var newform, spinner, uri_parser;
      newform = jQuery(this).val();
      uri_parser = new QueryStringParser("/users/new");
      uri_parser.query_params.type = newform;
      spinner = new Spinner();
      spinner.spin();
      window.location.href = uri_parser.toString();
    });
  });
}.call(this));
