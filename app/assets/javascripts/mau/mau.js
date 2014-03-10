/*jshint -W031 */  /** don't warn for using "new" with side-effects : because of prototype new Insertion() */

var MAU = window.MAU = window.MAU || {};

post_to_url = function (path, params, method) {
  method = method || "post"; // Set method to post by default, if not specified.

  // The rest of this code assumes you are not using a library.
  // It can be made less wordy if you use one.
  var form = new Element('form', { method: method, action: path });
  var hiddenField = null;
  for(var key in params) {
    hiddenField = new Element('input', { type: 'hidden', name: key, value: params[key] });
    form.appendChild(hiddenField);
  }
  hiddenField = new Element('input', { type: 'hidden', name: 'authenticity_token', value:unescape(authenticityToken)});
  form.appendChild(hiddenField);
  document.body.appendChild(form);    // Not entirely sure if this is necessary
  form.submit();
};

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
  var F = M.Feedback = M.Feedback || {};
  var G = M.GetInvolved = M.GetInvolved || {};
  var AC = M.Account = M.Account || {};
  var FV = M.Favorites = M.Favorites || {};
  var JSF = M.Flash = M.Flash || {};

  M.__debug__ = true;
  M.BLIND_OPTS = { up: {duration: 0.25},
                   down: {duration: 0.75} };
  M.FADE_OPTS = { 'in': {duration: 0.25, from:0, to:1},
                  'out': {duration: 0.25} };

  M.validateEmail = function(str) {
    return (str.indexOf(".") > 2) && (str.indexOf("@") > 0);
  };

  M.addCommentBoxObserver = function( cmtbx ) {
    if (cmtbx) {
      cmtbx.observe('focus', function() {
        if ((this.value == '<enter your comment here>') ||
	          (this.value == '<enter your note here>')) {
	        this.value = '';
	      }
	      return false;
      });
    }
  };

  M.addFlashObserver = function() {
    var notice = $$('.notice').first();
    if (notice) {
      var close = new Element('div',{'class':'close_btn'});
      close.innerHTML ='x';
      notice.insert(close);

      notice.setStyle({display:'block'});
      /*notice.blindDown(M.BLIND_OPTS.down);*/
      notice.observe('click', function() {
	      notice.fade(M.BLIND_OPTS.up);
      });
      setTimeout(function() {
	      notice.fade(M.BLIND_OPTS.up);
      }, 10000);
    }
  };

  /* when we add an art piece */
  M.addArtPieceSubmissionObserver = function() {
    var art_piece_form = $('new_artpiece_form');
    if (art_piece_form) {
      var submit_button = art_piece_form.select('input[type=submit]')[0];
      if (art_piece_form && submit_button) {
        submit_button.observe('click', function(ev) {
          if (AP.validate_art_piece(art_piece_form)) {
            MAU.waitcursor();
            return true;
          }
          else {
            ev.stop();
            return false;
          }
        });
      }
    }
  };

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

  M.CREDITS_BG = 'credits_bg';
  M.CREDITS_BG_CONTAIN = 'credits_bg_contain';
  M.CREDITS_DIV = 'credits_div';

  M.init = function() {
    var $lf = $('login_form');

    if ($lf) { $lf.focus_first(); }

    // init credits popup
    var fq = $('credits_lnk');
    if (fq) {
      Event.observe(fq,'click', function(event) {
	      var bg = $(M.CREDITS_BG);
	      var cn = $(M.CREDITS_BG_CONTAIN);
	      if (bg) { bg.remove(); }
	      if (cn) { cn.remove(); }
	      bg = new Element('div', { id: M.CREDITS_BG });
	      cn = new Element('div', { id:M.CREDITS_BG_CONTAIN });
	      var d = new Element('div', { id: M.CREDITS_DIV });
	      var hd = new Element('div').addClassName('credits-hdr');
	      hd.update('Credits');
	      var bd = new Element('div').addClassName('credits-bdy');
        var version = MAU.versionString || 'Charger 6';
	      bd.update('<div style="text-align: center;">'+
                  '<p>Web Design/QA: Trish Tunney</p>' +
                  '<p>Web Construction: <a href="http://rcode5.com">Mr Rogers @ Rcode5 </a></p>' +
                  '<p><span style="padding-bottom:14px; ">Built at MAU Headquarters</p>'+
                  '</div>'+
                  '<div class="credits-img"><img width="350" src="/images/mau-headquarters-small.jpg"/></div>'+
                  '<div class="close_btn">click to close</div>'+
                  '<div class="release_version">Release: ' + version + '</div><div class="clear"></div>');
	      if (d && hd && bd) {
	        var dummy = new Insertion.Top(d, bd);
	        dummy = new Insertion.Top(d, hd);
	      }
	      Event.observe(d,'click', function(event) {
	        bg.remove();
	        cn.remove();
	        return false;
	      });
	      var dump = new Insertion.Top(cn, d);
	      dump = new Insertion.Top(document.body,cn);
	      dump = new Insertion.Top(document.body,bg);

	      /* center */
	      var dm = Element.getDimensions(d);
	      w = dm.width;
	      h = dm.height;
	      var ws = document.viewport.getDimensions();
	      var soff = document.viewport.getScrollOffsets();
	      pw = ws.width + soff.left;
	      ph = ws.height + soff.top;
	      var tp = '' + ((ph/2) - (h/2)) + "px";
	      var lft = '' + ((pw/2) - (w/2)) + "px";
	      cn.style.top = tp;
	      cn.style.left = lft;
	      event.stopPropagation();
	      return false;
      });
    }
    M.addArtPieceSubmissionObserver();
    M.addFlashObserver();
  };

  Event.observe(window, 'load', M.init);


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


  /*** feedback option selector code ***/
  F.init = function() {
    var cbx = $$('div.fdbk-input #feedback_comment');
    if (cbx.length > 0) {
      M.addCommentBoxObserver();
    }
  };

  /** get involved **/
  G.TOGGLELNK_SUFFIX = '_toggle_lnk';
  G.NTRUNC = G.TOGGLELNK_SUFFIX.length;
  G.ITEMS = ['volunteer','donate','emaillist',
	           'suggest','shop','venue','business'];
  var _giToggle = function(it) {
    return "gi_"+it+"toggle";
  };
  var _giToggleLink = function(it) {
    return "gi_"+it+"_toggle_lnk";
  };
  var _giDiv = function(it) {
    return "gi_"+it;
  };
  var _giLnk2Div = function(lnk) {
    return lnk.substr(0,lnk.length - G.NTRUNC);
  };

  G.showSection = function(s) {
    var items = $$('div.gi a');
    var nitems = items.length;
    for (var ii = 0; ii < nitems; ++ii) {
      var tg = items[ii];
      if (tg) {
	      var s2 = _giLnk2Div(tg.id);
	      var dv = $(s2);
	      if (dv) {
	        if (!dv.visible()) {
	          if (s && s2 && (s == s2)) {
	            dv.blindDown(M.BLIND_OPTS.down);
            }
          } else {
	          dv.slideUp(M.BLIND_OPTS.up);
	        }
	      }
      }
    }
  };

  G.init = function() {
    var showSection = function(ev) {
      ev.stopPropagation();
      var s = _giLnk2Div(this.id);
      G.showSection(s);
      return false;
    };

    // pick out special items
    // shop -> cafe press
    // email -> mailto:
    var specialCases = ['shop'];

    var items = $$('div.open-close-div a');
    var nitems = items.length;
    var ii = 0;
    for (ii = 0; ii < nitems; ++ii) {
      var tg = items[ii];
      if (tg) {
	      tg.observe('click', showSection);
      }
    }

    var cbx = $$('.content-block #feedback_comment');
    var ncbx = cbx.length;
    for (ii = 0; ii < ncbx; ++ii) {
      M.addCommentBoxObserver(cbx[ii]);
    }

    var frms = $$('div.content-block form');
    var nfrms = frms.length;
    for (ii = 0; ii < nfrms; ++ii) {
      var f = frms[ii];
      f.observe('submit', G.validateEmailComment );
    }
    G.init = function() {};
  };

  G.validateEmailComment = function(ev) {
    var el = ev.element();
    if (!el) {
      return false;
    }
    var ems = el.getElements();
    var nems = ems.length;
    var ii;
    for (ii = 0; ii < nems; ++ii) {
      var em = ems[ii];
      if (em.name == 'feedback[email]') {
	      if (!M.validateEmail(em.getValue())) {
	        alert("Please enter a valid email address.");
	        ev.stop();
	        return false;
	      }
      }
      if (em.name == 'feedback[comment]') {
	      var v = em.getValue();
	      if ((v === '') || (v === '<enter your comment here>')) {
	        alert("Please enter something in the comment box.");
	        ev.stop();
	        return false;
	      }
      }
    }
    return true;
  };

  Event.observe(window,'load',G.init);

  /** javascript flash */
  Object.extend(JSF, {
    WRAPPER: 'jsFlash',
    show:function(msgs, container) {
      jQuery('#' + this.WRAPPER).remove();
      var $w = this.construct(msgs);
      var c = jQuery(container).first();
      if (!c.length) {
        c = document.body;
      }
      jQuery(c).prepend($w);
      $w.fadeIn();
      M.addFlashObserver();
    },
    hide:function() {
      var w = $(this.WRAPPER);
      if (w) { w.hide(); }
    },
    construct: function(msgs) {
      /** do this with jQuery */
      var $flash = jQuery('<div>', {id:this.WRAPPER, style:'display:none;'});
      //var flash = new Element('div', {id:this.WRAPPER, style:'display:none;'});
      var err = msgs.error;
      var notice = msgs.notice;
      var contents = jQuery('<div>');
      ['error','notice'].each(function(k) {
        if (msgs[k]) {
          var msg = msgs[k];
          var clz = k;
          if (k == 'error') { clz = 'error-msg'; }
          contents.append(jQuery('<div>', {'class': clz}).html(msg));
        }
      });
      if (contents.html().length) {
        $flash.html(contents);
      }
      return $flash;
    },
    init:function() {
    }
  });

  Event.observe(window,'load', JSF.init);


}
)();

