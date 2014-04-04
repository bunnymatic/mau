/*jshint -W031 */  /** don't warn for using "new" with side-effects : because of prototype new Insertion() */

var MAU = window.MAU = window.MAU || {};

/** setup hash change observer */
(function(){
  var curHash = window.location.hash;
  function doHashChange(){
    if(window.location.hash != curHash){
      curHash = window.location.hash;
      $(document).fire('mau:hashchange');
    }
  }
  if('onhashchange' in window){
    window.onhashchange = doHashChange;
  } else {
    window.setInterval(doHashChange, 200);
  }
})();


(function() {
  var M = MAU;
  var A = M.Artist = M.Artist || {};
  var AP = M.ArtPiece = M.ArtPiece || {};

  M.__debug__ = true;
  M.BLIND_OPTS = { up: {duration: 0.25},
                   down: {duration: 0.75} };
  M.FADE_OPTS = { 'in': {duration: 0.25, from:0, to:1},
                  'out': {duration: 0.25} };

  // clear any errors and spinit
  M.waitcursor = function() {
    var errmsg = $('error_row');
    if (errmsg) {
      errmsg.update('');
    }
    var spinner = new MAU.Spinner({top:'0px'})
    spinner.spin();
  };

  M.goToArtist = function( artistid ) {
    window.location = "/users/" + parseInt(artistid,10);
    return true;
  };

  M.doSearch = function(ev) {
    var q = $('search_box');
    var f = $('search_form');
    if (f && q && q.value) {
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
  var ID_NOTIFICATION_TOGGLE = 'notification_toggle';
  var ID_EVENTS_TOGGLE = 'events_toggle';

  var ID_EVENTS_SXN = 'events';
  var ID_STUDIO_SXN = 'address';
  var ID_LINKS_SXN = 'links';
  var ID_ARTIST_SXN = 'info';
  var ID_BIO_SXN = 'bio';
  var ID_PASSWD_SXN = 'passwd';
  var ID_DEACTIVATE_SXN = 'deactivate';
  var ID_NOTIFICATION_SXN = 'notification';

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
      var frm = $(sxnnm);
      var lnk = $(M.Artist.TOGGLES[ii] + "_lnk");
      if (frm) {
	      if (!frm.visible() ) {
	        if (sxnnm == sxn) {
	          frm.slideDown(M.BLIND_OPTS.down);
	          lnk.innerHTML = "hide";
	        }
	      }
	      else {
	        frm.slideUp(M.BLIND_OPTS.up);
	        lnk.innerHTML = "change";
	      }
      }
    }
    return false;
  };
  A.clickYepNope = function(type) {
    var sel = 'artist_os_participation';
    var new_setting = parseInt($(sel).value,10);
    var msg = null;
    if (!new_setting) {
      msg = 'So sorry you\'re not going to participate this year.'+
        ' We\'d love to know why.  Tell us via the feedback link'+
        ' at the bottom of the page.';
    } else {
      msg = 'Super!  The more the merrier!';
    }
    // submit via ajax
    var submitForm = $$('form.edit_artist').first();
    if (submitForm) {
      submitForm.request({onComplete:function() {
        if(new_setting) {
          $$('#artist_edit .os-violator')[0].show();
          $$('#events .os-status span')[0].innerHTML = 'Yep';
        }
        else
        {
          $$('#artist_edit .os-violator')[0].hide();
          $$('#events .os-status span')[0].innerHTML = 'Nope';
        }
        alert(msg);
      }});
    }
  };
  A.clickYep = function() {
    var sel = 'artist_os_participation';
    $(sel).value = 1;
    A.clickYepNope('yep');
  };
  A.clickNope = function() {
    var sel = 'artist_os_participation';
    $(sel).value = 0;
    A.clickYepNope('nope');
  };

  A.bindYepNopeButtons = function() {
    var yep = $$('#events .yep.formbutton');
    var nope = $$('#events .nope.formbutton');
    if (yep && (yep.length > 0) && nope && (nope.length > 0)) {
      var $yep = $(yep[0]);
      var $nope = $(nope[0]);
      $yep.observe('mouseover', function() {
        $(this).innerHTML = 'Yep!';
      });
      $yep.observe('mouseout', function() {
        $(this).innerHTML = 'Yep';
      });
      $nope.observe('mouseover', function() {
        $(this).innerHTML = ':(';
      });
      $nope.observe('mouseout', function() {
        $(this).innerHTML = 'Nope';
      });
      $yep.observe('click', A.clickYep);
      $nope.observe('click', A.clickNope);
    }
  };
  A.bindDonateButton = function() {
    var donate_sxn = $('donate_for_openstudios');
    if (donate_sxn) {
      donate_sxn.observe('click', function() {
        // find paypal form and submit its
        var paypal_form = $('paypal_donate_openstudios');
        if (paypal_form) {
          return paypal_form.submit();
        }
      });
    }
  };
  A.init = function() {
    var toggles = M.Artist.TOGGLES;
    var sxns = M.Artist.SECTIONS;
    var nsxn = sxns.length;

    var bindToggleAction = function( section_idx ) {
      Event.observe(lnk, 'click', function(event){
        var nm = sxns[section_idx];
        M.Artist.toggleSxnVis(nm);
      });
    };
    for ( var ii = 0; ii < nsxn; ++ii ) {
      var lnk = $(toggles[ii] + '_lnk');
      var nm = sxns[ii];
      if (lnk) {
        bindToggleAction(ii);
      }
    }
    if ( location.hash && (location.hash.length > 1)) {
      var sxn = location.hash.substr(1);
      M.Artist.toggleSxnVis(sxn);
    }

    A.bindYepNopeButtons();
    A.bindDonateButton();

    var openCloseDivs = $$('.edit-sections .open-close-div');
    if ( openCloseDivs ) {
      _.each(openCloseDivs, function(t) {
        t.observe('mouseover', function() {
          $(this).addClassName('hover');
        });
        t.observe('mouseout', function() {
          $(this).removeClassName('hover');
        });
      });
    }

    /** hide/clear studio # when we choose indy */
    $$('.edit-sections #artist_studio_id').each(function(s) {
      s.observe('change', function(ev) {

        if (this.selected().value === 0) {
          $('artist_artist_info_studionumber').value = '';
          $$('.edit-sections #address .studio-number-row')[0].hide();
        } else {
          $$('.edit-sections #address .studio-number-row')[0].show();
        }
      });
    });


    A.init = function() {};
  };

  Event.observe(window, 'load', A.init);



}
)();

/*** jquery on load */
jQuery(function() {

  var flashNotice = jQuery(".notice");
  if (flashNotice.length) {
    flashNotice.find('.close_btn').bind('click', function() {
	    flashNotice.fadeOut();
    });
    setTimeout(function() {
	    flashNotice.fadeOut();
    }, 10000);
  }

});
