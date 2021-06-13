import jQuery from "jquery";

window.jQuery = jQuery;
window.$ = jQuery;

import "select2";
import "re-tree";
import "./app/flash_binding";
import "./app/all_tabs";
import "./app/map";
import "./vendor/bootstrap/transition";
import "./vendor/bootstrap/tab";
import "./vendor/bootstrap/collapse";
import "./globals";
import "@reactjs";

import ujs from "@rails/ujs";
ujs.start();
