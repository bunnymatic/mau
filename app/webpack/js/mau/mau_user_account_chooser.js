import jQuery from "jquery";
import QueryStringParser from "./query_string_parser";
import Spinner from "./mau_spinner.js";

jQuery(function () {
  jQuery("#account_type_chooser").bind("change", function () {
    const newform = jQuery(this).val();
    const uri_parser = new QueryStringParser("/users/new");
    uri_parser.query_params.type = newform;
    const spinner = new Spinner();
    spinner.spin();
    window.location.href = uri_parser.toString();
  });
});
