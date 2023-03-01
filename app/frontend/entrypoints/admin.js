import jQuery from "jquery";

window.jQuery = jQuery;
window.$ = jQuery;

import "@js/app/flash_binding";
import "@js/vendor/bootstrap/transition";
import "@js/vendor/bootstrap/tab";
import "@js/vendor/bootstrap/collapse";
import "@js/admin/globals";
import "@reactjs";

import select2 from "select2";
select2();
import ujs from "@rails/ujs";
if (!window._rails_loaded) {
  ujs.start();
}

import "@styles/admin.scss";
