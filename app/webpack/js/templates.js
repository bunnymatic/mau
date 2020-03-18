import email_list_manager_index_html from "../components/admin/email_list_manager/index.html";
import admin_events_notification_bell_index_html from "../components/admin/events_notification_bell/index.html";
import art_piece_tag_index_html from "../components/art_piece_tag/index.html";
import art_pieces_browser_index_html from "../components/art_pieces_browser/index.html";
import credits_link_credits__modal_html from "../components/credits_link/credits__modal.html";
import credits_link_index_html from "../components/credits_link/index.html";
import editable_content_index_html from "../components/editable_content/index.html";
import link_if_index_html from "../components/link_if/index.html";
import mailer_index_html from "../components/mailer/index.html";
import medium_index_html from "../components/medium/index.html";
import notify_mau_index_html from "../components/notify_mau/index.html";
import notify_mau_inquiry_html from "../components/notify_mau/inquiry.html";
import notify_mau_inquiry_form_html from "../components/notify_mau/inquiry_form.html";
import open_studios_registration_widget_index_html from "../components/open_studios_registration_widget/index.html";
import open_studios_registration_widget_open_studios_registration__modal_html from "../components/open_studios_registration_widget/open_studios_registration__modal.html";
import search_results_index_html from "../components/search_results/index.html";
import social_buttons_favorite_html from "../components/social_buttons/favorite.html";
import social_buttons_index_html from "../components/social_buttons/index.html";

(function() {
  "use strict";

  angular.module("templates", []).run([
    "$templateCache",
    function($templateCache) {
      $templateCache.put(
        "email_list_manager/index.html",
        email_list_manager_index_html
      );

      $templateCache.put(
        "admin/email_list_manager/index.html",
        email_list_manager_index_html
      );
      $templateCache.put(
        "admin/events_notification_bell/index.html",
        admin_events_notification_bell_index_html
      );
      $templateCache.put("art_piece_tag/index.html", art_piece_tag_index_html);
      $templateCache.put(
        "art_pieces_browser/index.html",
        art_pieces_browser_index_html
      );
      $templateCache.put(
        "credits_link/credits__modal.html",
        credits_link_credits__modal_html
      );
      $templateCache.put("credits_link/index.html", credits_link_index_html);
      $templateCache.put(
        "editable_content/index.html",
        editable_content_index_html
      );
      $templateCache.put("link_if/index.html", link_if_index_html);
      $templateCache.put("mailer/index.html", mailer_index_html);
      $templateCache.put("medium/index.html", medium_index_html);
      $templateCache.put("notify_mau/index.html", notify_mau_index_html);
      $templateCache.put("notify_mau/inquiry.html", notify_mau_inquiry_html);
      $templateCache.put(
        "notify_mau/inquiry_form.html",
        notify_mau_inquiry_form_html
      );
      $templateCache.put(
        "open_studios_registration_widget/index.html",
        open_studios_registration_widget_index_html
      );
      $templateCache.put(
        "open_studios_registration_widget/open_studios_registration__modal.html",
        open_studios_registration_widget_open_studios_registration__modal_html
      );
      $templateCache.put(
        "search_results/index.html",
        search_results_index_html
      );
      $templateCache.put(
        "social_buttons/favorite.html",
        social_buttons_favorite_html
      );
      $templateCache.put(
        "social_buttons/index.html",
        social_buttons_index_html
      );
    }
  ]);
})();
