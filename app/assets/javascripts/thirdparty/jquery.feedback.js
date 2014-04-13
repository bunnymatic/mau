/*
 * Feedback (for jQuery)
 * version: 0.1 (2009-07-21)
 * @requires jQuery v1.3 or later
 *
 * This script is part of the Feedback Ruby on Rails Plugin:
 *   http://
 *
 * Licensed under the MIT:
 *   http://www.opensource.org/licenses/mit-license.php
 *
 * Copyright 2009 Jean-Sebastien Boulanger [ jsboulanger@gmail.com ]
 *
 * Usage:
 *
 *  jQuery(document).ready(function() {
 *    jQuery('#feedback_tab_link').feedback({
 *      // options
 *    });
 *  })
 *
 */
(function($) {
  var settings;

  jQuery.fn.feedback = function(callerSettings) {
    settings = $.extend({
      main: 'feedback',
      closeLink: 'feedback_close_link',
      closeBtn: 'feedback_close_btn',
      modalWindow: 'feedback_modal_window',
      modalContent: 'feedback_modal_content',
      form: 'feedback_form',
      formUrl: '/feedbacks/new',
      overlay: 'feedback_overlay',
      loadingImage: '/images/spinner16black.gif',
      loadingText: 'Loading...',
      sendingText: 'Sending...'
    }, callerSettings || {});

    settings.feedbackHtml = '<div id="' + settings.main + '" style="display: none;">' +
                              '<div id="' + settings.modalWindow + '">' +
                                '<a href="#" id="' + settings.closeLink + '">x</a>' +
                                '<div id="' + settings.modalContent + '"></div>' +
                              '</div>' +
                            '</div>'
    settings.overlayHtml = '<div id="' + settings.overlay + '" class="feedback_hide"></div>';
    settings.tabHtml = '<a href="#" id="feedback_link" class="feedback_link ' + settings.tabPosition + '"></a>';
    settings.main = '#' + settings.main;
    settings.closeLink = '#' + settings.closeLink;
    settings.modalWindow = '#' + settings.modalWindow;
    settings.modalContent = '#' + settings.modalContent;
    settings.form = '#' + settings.form;
    settings.overlay = '#' + settings.overlay;
    settings.closeBtn = '#' + settings.closeBtn;
    settings.tabControls = this;

    if (settings.tabPosition != null && jQuery("#feedback_link").length == 0) {
      jQuery("body").append(settings.tabHtml);
      settings.tabControls = jQuery(settings.tabControls).add(jQuery('#feedback_link'));
    }

    jQuery(settings.tabControls).click(function() {
      loading();
      jQuery(settings.modalContent).load(settings.formUrl, null, function() {
        jQuery(settings.form).submit(submitFeedback);

	      jQuery(settings.closeBtn).bind('click', function(){
	        hideFeedback();
	        return false;
	      });
      });
      return false;
    });
  };

  var submitFeedback = function() {
		jQuery('input[name=feedback\\[page\\]]').val(location.href);
    var data = jQuery(settings.form).serialize();
    var url = $.trim(jQuery(settings.form).attr('action'));
    loading(settings.sendingText);
    $.ajax({
      type: "POST",
      url: url,
      data: data,
      success: function(msg, status) {
        jQuery(settings.modalContent).html(msg);
        jQuery(settings.modalWindow).fadeOut(2000, function() {
          hideFeedback();
        });
      },
      error: function(xhr, status, a) {
        jQuery(settings.modalContent).html(xhr.responseText);
        jQuery(settings.form).submit(submitFeedback);
      }
    });
    return false;
  }


  var initOverlay = function() {
    if (jQuery(settings.overlay).length == 0)
      jQuery("body").append(settings.overlayHtml)
    return jQuery(settings.overlay).hide().addClass("feedback_overlayBG")
  }

  var showOverlay = function() {
    initOverlay().show();
  }

  var hideOverlay = function() {
    if (jQuery(settings.overlay).length == 0) return false;
    jQuery(settings.overlay).remove();
  }

  var initFeedback = function() {
    if (jQuery(settings.main).length == 0) {
      jQuery("body").append(settings.feedbackHtml);
      jQuery(settings.closeLink).click(function() {
        hideFeedback();
        return false;
      });
      setBoxPosition();
    }
    return jQuery(settings.main);
  }

  var showFeedback = function() {
    initFeedback().show();
  }

  var hideFeedback = function() {
    jQuery(settings.main).hide();
    jQuery(settings.main).remove();
    hideOverlay();
  }

  var setBoxPosition = function() {
    var scrollTop, clientHeight;
    if (self.pageYOffset) {
      scrollTop = self.pageYOffset;
    } else if (document.documentElement && document.documentElement.scrollTop) {	 // Explorer 6 Strict
      scrollTop = document.documentElement.scrollTop;
    } else if (document.body) {// all other Explorers
      scrollTop = document.body.scrollTop;
    }
    if (self.innerHeight) {	// all except Explorer
      clientHeight = self.innerHeight;
    } else if (document.documentElement && document.documentElement.clientHeight) { // Explorer 6 Strict Mode
      clientHeight = document.documentElement.clientHeight;
    } else if (document.body) { // other Explorers
      clientHeight = document.body.clientHeight;
    }
    jQuery(settings.modalWindow).css({
      top: scrollTop + (clientHeight / 10) + 'px'
    });
  }

  var loading = function(text) {
    showOverlay();
    initFeedback();

    if(text == null)
      text = settings.loadingText;

    jQuery(settings.modalContent).html(
      '<h1>' + text + '<img src="' + settings.loadingImage + '" /></h1>');

    showFeedback();

  }
}) (jQuery);
