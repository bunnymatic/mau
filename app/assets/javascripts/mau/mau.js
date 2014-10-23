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


  /**
   * scripty stuff related to artist and artist pages
   */
  var ID_STUDIO_INFO_TOGGLE = 'studio_info_toggle';
  var ID_LINKS_TOGGLE = 'links_toggle';
  var ID_ARTIST_INFO_TOGGLE = 'info_toggle';
  var ID_BIO_TOGGLE = 'bio_toggle';
  var ID_PASSWD_TOGGLE = 'passwd_toggle';
  var ID_DEACTIVATE_TOGGLE = 'deactivate_toggle';
  var ID_NOTIFICATION_TOGGLE = 'notifications_toggle';
  var ID_EVENTS_TOGGLE = 'events_toggle';

  var ID_EVENTS_SXN = 'events';
  var ID_STUDIO_SXN = 'address';
  var ID_LINKS_SXN = 'links';
  var ID_ARTIST_SXN = 'info';
  var ID_BIO_SXN = 'bio';
  var ID_PASSWD_SXN = 'passwd';
  var ID_DEACTIVATE_SXN = 'deactivate';
  var ID_NOTIFICATION_SXN = 'notifications';

  A.SECTIONS = [ID_STUDIO_SXN,
		            ID_LINKS_SXN,
		            ID_ARTIST_SXN,
		            ID_BIO_SXN,
		            ID_PASSWD_SXN,
		            ID_DEACTIVATE_SXN,
		            ID_NOTIFICATION_SXN,
		            ID_EVENTS_SXN];

  A.TOGGLES = [ID_STUDIO_INFO_TOGGLE,
	             ID_LINKS_TOGGLE,
	             ID_ARTIST_INFO_TOGGLE,
	             ID_BIO_TOGGLE,
	             ID_PASSWD_TOGGLE,
	             ID_DEACTIVATE_TOGGLE,
	             ID_NOTIFICATION_TOGGLE,
	             ID_EVENTS_TOGGLE];

  A.toggleSxnVis = function(sxn) {

    var sxns = M.Artist.SECTIONS;
    var nsxn = sxns.length;
    for( var ii = 0; ii < nsxn; ++ii) {
      var sxnnm = sxns[ii];
      var frm = jQuery('#'+sxnnm);
      var lnk = jQuery('#'+M.Artist.TOGGLES[ii] + "_lnk");
      if (frm.length) {
	      if (!frm.is(':visible') ) {
	        if (sxnnm == sxn) {
	          frm.slideDown()
	          lnk[0].innerHTML = "hide"
	        }
	      }
	      else {
          frm.slideUp();
	        lnk[0].innerHTML = "change";
	      }
      }
    }
    return false;
  };

  A.clickYepNope = function(type) {
    var sel = '#artist_os_participation';
    var new_setting = parseInt(jQuery(sel).val(),10);
    var msg = null;
    if (!new_setting) {
      msg = 'So sorry you\'re not going to participate this year.'+
        ' We\'d love to know why.  Tell us via the feedback link'+
        ' at the bottom of the page.';
    } else {
      msg = 'Super!  The more the merrier!';
    }

    jQuery('form.edit_artist').ajaxSubmit({
      success: function() {
        if(new_setting) {
          jQuery('#artist_edit .os-violator').show();
          jQuery('#events .os-status span').html('Yep');
        }
        else {
          jQuery('#artist_edit .os-violator').hide();
          jQuery('#events .os-status span').html('Nope');
        }
        (new MAU.Flash()).show({notice:msg}, '.singlecolumn .edit-sections')
      }
    });
    return false;
  };
  A.clickYep = function(ev) {
    ev.preventDefault();
    jQuery('#artist_os_participation').val(1)
    A.clickYepNope('yep');
    return false;
  };
  A.clickNope = function(ev) {
    ev.preventDefault();
    jQuery('#artist_os_participation').val(0)
    A.clickYepNope('nope');
    return false;
  };

  A.bindYepNopeButtons = function() {
    jQuery('#events .yep.formbutton').bind('click', A.clickYep);
    jQuery('#events .nope.formbutton').bind('click', A.clickNope);
  };

  A.bindDonateButton = function() {
    jQuery('#donate_for_openstudios').bind('click', function() {
      // find paypal form and submit its
      var paypal_form = jQuery('#paypal_donate_openstudios');
      if (paypal_form.length) {
        return paypal_form.submit();
      }
    });
  };
}

)();

/*** jquery on load */
jQuery(function() {

  var toggles = MAU.Artist.TOGGLES;
  var sxns = MAU.Artist.SECTIONS;
  var nsxn = sxns.length;

  jQuery('.acct .edit a').each(function() {
    var $el = $(this);

    var openSectionFromLink = function(lnk) {
      var href = lnk.href;
      var sxn = _.last(href.split('#'));
      if (sxn) {
        MAU.Artist.toggleSxnVis(sxn);
      }
    };
    $el.closest('.acct').bind('click', function(ev) {
      ev.preventDefault();
      openSectionFromLink($el[0]);
    });
  });
  if ( location.hash && (location.hash.length > 1)) {
    var sxn = location.hash.substr(1);
    MAU.Artist.toggleSxnVis(sxn);
  }

  MAU.Artist.bindYepNopeButtons();
  MAU.Artist.bindDonateButton();

  /** hide/clear studio # when we choose indy */
  jQuery('.edit-sections #artist_studio_id').bind('change', function(ev) {
    if (parseInt(jQuery(this).val(),10) === 0) {
      jQuery('#artist_artist_info_studionumber').val('');
      jQuery('.edit-sections #address .studio-number-row').hide();
    } else {
      jQuery('.edit-sections #address .studio-number-row').show();
    }
  });

  /** handle os switch on map/roster page */
  jQuery('#map_cb').bind('click', function(ev) {
    ev.stopPropagation();
    jQuery('#map_osswitcher').submit();
  });




  var flashNotice = jQuery(".notice");
  if (flashNotice.length) {
    flashNotice.bind('click', function() {
	    flashNotice.fadeOut();
    });
    setTimeout(function() {
	    flashNotice.fadeOut();
    }, 10000);
  }

});
