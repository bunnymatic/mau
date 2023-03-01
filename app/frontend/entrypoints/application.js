import jQuery from "jquery";
window.jQuery = jQuery;
window.$ = jQuery;

import "@js/app/flash_binding.js";
import "@js/app/all_tabs";
import "@js/globals";
// import "@js/app/map";
import "@js/vendor/bootstrap/transition";
import "@js/vendor/bootstrap/tab";
import "@js/vendor/bootstrap/collapse";
import "@reactjs";

import ujs from "@rails/ujs";
if (!window._rails_loaded) {
  ujs.start();
}

import select2 from "select2";
select2();

// STYLES
import "@styles/application.scss";
