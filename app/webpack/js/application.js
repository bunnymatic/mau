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
import "re-tree";
import "ng-dialog/js/ngDialog";
import "@components/notify_mau/notify_mau";
import "@components/art_pieces_browser/art_pieces_browser";
import "@components/search_results/search_hit";
import "@components/search_results/search_results";
import "@components/admin/events_notification_bell/events_notification_bell";
import "@components/medium/medium";
import "@components/social_buttons/share_button";
import "@components/social_buttons/favorite_this";
import "@components/background-img/background-img";
import "@components/art_piece_tag/art_piece_tag";
import "@components/time_ago/time_ago";
import "@components/repeater_delimiter/repeater_delimiter";
import "@components/image_fader/image_fader";
import "@components/password_strength/passwordStrength.directive";
import "@components/link_if/link_if";
import "@components/editable_content/editable_content";
import "@services/email_changed_events.service";
import "@services/object_routing.service";
import "@services/notification.service";
import "@services/favorites.service";
import "@services/env.service";
import "@services/open_studios_registration.service";
import "@services/search.service";
import "./app/feedback";
import "./app/flash_binding";
import "./app/all_tabs";
import "./app/map";
import "./app/jquery/jquery.feedback";
import "./app/jquery/jquery.isOverflowing";
import "./vendor/angularSlideables";
import "./mau_app";
import "./vendor/bootstrap/transition";
import "./vendor/bootstrap/tab";
import "./vendor/bootstrap/collapse";
import "./globals";
import "@reactjs";

import ujs from "@rails/ujs";
ujs.start();
