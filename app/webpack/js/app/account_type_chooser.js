import jQuery from "jquery";
import QueryStringParser from "./query_string_parser";
import Spinner from "@js/app/spinner";

class AccountTypeChooser {
  constructor(chooser) {
    jQuery(chooser).on("change", function () {
      const formType = jQuery(this).val();
      const uriParser = new QueryStringParser("/users/new");
      uriParser.queryParams.type = formType;
      const spinner = new Spinner();
      spinner.spin();
      window.location.href = uriParser.toString();
    });
  }
}

export default AccountTypeChooser;
