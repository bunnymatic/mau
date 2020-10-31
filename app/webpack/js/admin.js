import ngInject from "@angularjs/ng-inject";
import angular from "angular";
import jQuery from "jquery";

window.jQuery = jQuery;
window.$ = jQuery;

import "select2";
import "angular/angular";
import "@angularjs/angular_modules";
import "angular-resource";
import "angular-sanitize";
import "angular-animate";
import "./vendor/angular-mailchimp";
import "angular-ui-utils/modules/keypress/keypress";
import "ng-dialog/js/ngDialog";
import "@components/admin/email_list_manager/email_list_manager";
import "@components/admin/events_notification_bell/events_notification_bell";
import "@components/mailer/mailer";
import "@components/models/email";
import "@components/time_ago/time_ago";
import "@components/image_fader/image_fader";
import "@components/link_if/link_if";
import "@components/editable_content/editable_content";
import "@services/email_changed_events.service";
import "@services/object_routing.service";
import "@services/notification.service";
import "@services/current_user.service";
import "@services/studios.service";
import "@services/mailer.service";
import "@services/favorites.service";
import "@services/env.service";
import "@services/art_pieces.service";
import "@services/artists.service";
import "@services/open_studios_registration.service";
import "@services/search.service";
import "@services/emails.service";
import "@services/application_events.service";
import "./app/flash_binding";
import "./vendor/angularSlideables";
import "./vendor/bootstrap/transition";
import "./vendor/bootstrap/tab";
import "./vendor/bootstrap/collapse";
import "pickadate/lib/picker";
import "pickadate/lib/picker.date";
import "pickadate/lib/picker.time";
import "./admin/globals";

import ujs from "@rails/ujs";
ujs.start();

angular
  .module("MauAdminApp", [
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
      $httpProvider.defaults.headers.post["Content-Type"] = "application/json";
      $httpProvider.defaults.headers.put["X-CSRF-Token"] = csrfToken;
      $httpProvider.defaults.headers.patch["X-CSRF-Token"] = csrfToken;
      (base = $httpProvider.defaults.headers)["delete"] ||
        (base["delete"] = {});
      $httpProvider.defaults.headers["delete"]["X-CSRF-Token"] = csrfToken;
      return null;
    })
  );
