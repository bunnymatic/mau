/*global                        l        merr    */
/*jshint -W031 */  /** don't warn for using "new" with side-effects : because of prototype new Insertion() */

var MAU = window.MAU = window.MAU || {};

/** setup hash change observer */
(function(){
  var curHash = window.location.hash;
  function doHashChange(){
    if(window.location.hash != curHash){
      curHash = window.location.hash;
      jQuery(document).trigger('mau:hashchange');
    }
  }
  if('onhashchange' in window){
    window.onhashchange = doHashChange;
  } else {
    window.setInterval(doHashChange, 20);
  }
})();


(function() {
  var M = MAU;
  var A = M.Artist = M.Artist || {};

  M.__debug__ = true;

  // clear any errors and spinit
  M.waitcursor = function() {
    var errmsg = jQuery('#error_row');
    if (errmsg) {
      errmsg.html('');
    }
    var spinner = new MAU.Spinner({top:'0px'})
    spinner.spin();
  };

  M.goToArtist = function( artistid ) {
    window.location = "/users/" + parseInt(artistid,10);
    return true;
  };

  M.doSearch = function(ev) {
    var q = jQuery('#search_box');
    var f = jQuery('#search_form');
    if (f.length && q.length && q.val()) {
      f.submit();
      return true;
    }
    return false;
  };

  M.mailer = function( name, domain, subject) {
    var lnk = "mailto:" + name + "@" + domain;
    if (subject && subject.length > -1) {
      lnk += "?subject=" + escape(subject);
    }
    window.location = lnk;
  };


  // /**
  //  * scripty stuff related to artist and artist pages
  //  */
  // var ID_STUDIO_INFO_TOGGLE = 'studio_info_toggle';
  // var ID_LINKS_TOGGLE = 'links_toggle';
  // var ID_ARTIST_INFO_TOGGLE = 'info_toggle';
  // var ID_BIO_TOGGLE = 'bio_toggle';
  // var ID_PASSWD_TOGGLE = 'passwd_toggle';
  // var ID_DEACTIVATE_TOGGLE = 'deactivate_toggle';
  // var ID_NOTIFICATION_TOGGLE = 'notifications_toggle';
  // var ID_EVENTS_TOGGLE = 'events_toggle';

  // var ID_EVENTS_SXN = 'events';
  // var ID_STUDIO_SXN = 'address';
  // var ID_LINKS_SXN = 'links';
  // var ID_ARTIST_SXN = 'info';
  // var ID_BIO_SXN = 'bio';
  // var ID_PASSWD_SXN = 'passwd';
  // var ID_DEACTIVATE_SXN = 'deactivate';
  // var ID_NOTIFICATION_SXN = 'notifications';

  // A.SECTIONS = [ID_STUDIO_SXN,
	// 	            ID_LINKS_SXN,
	// 	            ID_ARTIST_SXN,
	// 	            ID_BIO_SXN,
	// 	            ID_PASSWD_SXN,
	// 	            ID_DEACTIVATE_SXN,
	// 	            ID_NOTIFICATION_SXN,
	// 	            ID_EVENTS_SXN];

  // A.TOGGLES = [ID_STUDIO_INFO_TOGGLE,
	//              ID_LINKS_TOGGLE,
	//              ID_ARTIST_INFO_TOGGLE,
	//              ID_BIO_TOGGLE,
	//              ID_PASSWD_TOGGLE,
	//              ID_DEACTIVATE_TOGGLE,
	//              ID_NOTIFICATION_TOGGLE,
	//              ID_EVENTS_TOGGLE];

  // A.toggleSxnVis = function(sxn) {

  //   var sxns = M.Artist.SECTIONS;
  //   var nsxn = sxns.length;
  //   for( var ii = 0; ii < nsxn; ++ii) {
  //     var sxnnm = sxns[ii];
  //     var frm = jQuery('#'+sxnnm);
  //     var lnk = jQuery('#'+M.Artist.TOGGLES[ii] + "_lnk");
  //     if (frm.length) {
	//       if (!frm.is(':visible') ) {
	//         if (sxnnm == sxn) {
	//           frm.slideDown()
	//           lnk[0].innerHTML = "hide"
	//         }
	//       }
	//       else {
  //         frm.slideUp();
	//         lnk[0].innerHTML = "change";
	//       }
  //     }
  //   }
  //   return false;
  // };

  // A.clickYepNope = function(type, val) {
  //   (new MAU.Flash()).clear()
  //   var msg = null;
  //   if (!val) {
  //     msg = 'So sorry you\'re not going to participate this year.'+
  //       ' We\'d love to know why.  Tell us via the feedback link'+
  //       ' at the bottom of the page.';
  //   } else {
  //     msg = 'Super!  The more the merrier!';
  //   }

  //   form = jQuery('form.edit_artist')
  //   ajax_params = {
  //     url: form.attr('action'),
  //     method: form.attr('method'),
  //     data: {
  //       artist: {
  //         os_participation: val
  //       }
  //     },
  //     success: function() {
  //       if(val) {
  //         jQuery('#artist_edit .os-violator').show();
  //         jQuery('#events .os-status span').html('Yep');
  //       }
  //       else {
  //         jQuery('#artist_edit .os-violator').hide();
  //         jQuery('#events .os-status span').html('Nope');
  //       }
  //       (new MAU.Flash()).show({notice:msg}, '.singlecolumn .edit-sections')
  //       return false;
  //     }
  //   };
  //   jQuery.ajax(ajax_params);
  //   return false;
  // };
  // A.clickYep = function(ev) {
  //   ev.preventDefault();
  //   A.clickYepNope('yep',1);
  //   return false;
  // };
  // A.clickNope = function(ev) {
  //   ev.preventDefault();
  //   A.clickYepNope('nope', 0);
  //   return false;
  // };

  // A.bindYepNopeButtons = function() {
  //   jQuery('#events .yep.formbutton').on('click', A.clickYep);
  //   jQuery('#events .nope.formbutton').on('click', A.clickNope);
  // };

  // A.bindDonateButton = function() {
  //   jQuery('#donate_for_openstudios').bind('click', function() {
  //     // find paypal form and submit its
  //     var paypal_form = jQuery('#paypal_donate_openstudios');
  //     if (paypal_form.length) {
  //       return paypal_form.submit();
  //     }
  //   });
  // };
}

)();

/*** jquery on load */
jQuery(function() {


  var flashNotice = ".notice, .flash, .flash__notice, .flash__error";
  $('body').on('click', flashNotice, function(ev) {
    $(this).fadeOut();
  });
  jQuery(flashNotice).each( function() {
    var _that = this;
    setTimeout(function() {
	    $(_that).fadeOut();
    }, 5000);
  });
});
