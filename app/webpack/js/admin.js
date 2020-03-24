import jQuery from "jquery";
import angular from "angular";
import ngInject from "@js/ng-inject";

window.jQuery = jQuery;
window.$ = jQuery;

import "lodash/lodash";
import "moment/moment";
import "moment-timezone/moment-timezone";
import "./timezones";
import "angular/angular";
import "@components/angular_modules";
import "angular-resource";
import "angular-sanitize";
import "angular-animate";
import "angular-moment/angular-moment";
import "./vendor/angular-mailchimp";
import "angular-ui-utils/modules/keypress/keypress";
import "re-tree";
import "ua-device-detector";
import "ng-device-detector";
import "ng-dialog/js/ngDialog";
import "./templates";

import "@components/angular_modules.js";
import "@components/admin/email_list_manager/email_list_manager.js";
import "@components/admin/events_notification_bell/events_notification_bell.js";
import "@components/social_buttons/share_button.js";
import "@components/social_buttons/favorite_this.js";
import "@components/background-img/background-img.js";
import "@components/mailer/mailer.js";
import "@components/models/email.js";
import "@components/art_piece_tag/art_piece_tag.js";
import "@components/time_ago/time_ago.js";
import "@components/repeater_delimiter/repeater_delimiter.js";
import "@components/image_fader/image_fader.js";
import "@components/services/email_changed_events_service.js";
import "@components/services/object_routing_service.js";
import "@components/services/notification_service.js";
import "@components/services/tag_service.js";
import "@components/services/currentUserService.js";
import "@components/services/studios_service.js";
import "@components/services/mailer_service.js";
import "@components/services/favorites_service.js";
import "@components/services/env_service.js";
import "@components/services/email_lists_service.js";
import "@components/services/art_pieces_service.js";
import "@components/services/artists_service.js";
import "@components/services/open_studios_registration_service.js";
import "@components/services/search_service.js";
import "@components/services/emails_service.js";
import "@components/services/application_events_service.js";
import "@components/link_if/link_if.js";
import "@components/editable_content/editable_content.js";

import "./mau/jquery/arrange_art.js";
import "./mau/jquery/jquery.isOverflowing.js";
import "./mau/mau.js";
import "./mau/mau_discount.js";
import "./mau/mau_spinner.js";
import "./mau/mau_user_account_chooser.js";
import "./mau/query_string_parser.js";
import "./mau/utils.js";

import "./admin/open_studios_events.js";
import "./admin/emaillist.js";
import "./admin/admin_graphs.js";
import "./admin/datatables_hookup.js";
import "./admin/artists_index.js";
import "./admin/roles.js";
import "./admin/studios.js";
import "./admin/menu.js";
import "./admin/application_events_query.js";

import "./vendor/angularSlideables";
import "./mau_app";
import "selectize/dist/js/standalone/selectize";
import "./vendor/bootstrap/transition";
import "./vendor/bootstrap/tab";
import "./vendor/bootstrap/collapse";
import "pickadate/lib/picker";
import "pickadate/lib/picker.date";
import "pickadate/lib/picker.time";

import ujs from "@rails/ujs";
ujs.start();

//  Template includes both application.js and admin.js
//
//= require d3/dist/d3.min
//= require c3/c3.min
//= require_tree ./admin

(function () {
  angular
    .module("MauAdminApp", [
      "templates",
      "angularMoment",
      "ngSanitize",
      "ngDialog",
      "angularSlideables",
      "mau.models",
      "mau.services",
      "mau.directives",
    ])
    .config(
      ngInject(function ($httpProvider) {
        var base, csrfToken;
        csrfToken = $("meta[name=csrf-token]").attr("content");
        $httpProvider.defaults.headers.post["X-CSRF-Token"] = csrfToken;
        $httpProvider.defaults.headers.post["Content-Type"] =
          "application/json";
        $httpProvider.defaults.headers.put["X-CSRF-Token"] = csrfToken;
        $httpProvider.defaults.headers.patch["X-CSRF-Token"] = csrfToken;
        (base = $httpProvider.defaults.headers)["delete"] ||
          (base["delete"] = {});
        $httpProvider.defaults.headers["delete"]["X-CSRF-Token"] = csrfToken;
        return null;
      })
    );
}.call(this));
