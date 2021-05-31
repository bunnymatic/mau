import jQuery from "jquery";

window.jQuery = jQuery;
window.$ = jQuery;

import "select2";
import "./app/flash_binding";
import "./vendor/bootstrap/transition";
import "./vendor/bootstrap/tab";
import "./vendor/bootstrap/collapse";
import "./admin/globals";
import "@reactjs";

import ujs from "@rails/ujs";
ujs.start();
