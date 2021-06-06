import jQuery from "jquery";

window.jQuery = jQuery;
window.$ = jQuery;

import "select2";
import "angular/angular";
import "@angularjs/angular_modules";
import "angular-ui-utils/modules/keypress/keypress";
import "angular-resource";
import "angular-sanitize";
import "./vendor/angular-mailchimp";
import "re-tree";
import "ng-dialog/js/ngDialog";
import "./app/feedback";
import "./app/flash_binding";
import "./app/all_tabs";
import "./app/map";
import "./app/jquery/jquery.feedback";
import "./app/jquery/jquery.isOverflowing";
import "./mau_app";
import "./vendor/bootstrap/transition";
import "./vendor/bootstrap/tab";
import "./vendor/bootstrap/collapse";
import "./globals";
import "@reactjs";

import ujs from "@rails/ujs";
ujs.start();
