MAU = window['MAU'] || {};

(function() {
    var M = MAU;
    var T = M.Thumbs = M.Thumbs || {};
    var A = M.Artist = M.Artist || {};
    var W = M.WhatsThis = M.WhatsThis || {};
	var F = M.Feedback = M.Feedback || {}
    M.__debug__ = true;

    /** safe javascript log - for debug */
    M.log = function() {
		if (window['console'] && M.__debug__) {
			// TODO: Chrome doesn't let us call apply on console.log.
			// Interpolate variable arguments manually and construct
			// a single-argument call to console.log for Chrome.
			try {
				console.log.apply(this, arguments);
			} catch(e) {
				X.log = function() {}
			}
		}
    }

    // Changes the cursor to an hourglass
    M.waitcursor = function() {
		document.body.style.cursor = 'wait';
    }
    
    // Returns the cursor to the default pointer
    M.clearcursor = function() {
		document.body.style.cursor = 'default';
    }

    M.goToArtist = function( artistid ) {
		window.location = "/artists/" + parseInt(artistid);
		return true;
    }

    M.doSearch = function( ) {
		var q = $('search_box');
		var f = $('search_form');
		if (f && q && q.value) {
			f.submit();
			return true;
		}
		return false;
    }

    M.mailer = function( name, domain, subject) {
		var lnk = "mailto:" + name + "@" + domain;
		if (subject && subject.length > -1) {
			lnk += "?subject=" + escape(subject);
		}
		window.location = lnk;
    };

    /* leave for later in case we need to init stuff */
    M.init = function() {
    }

    Event.observe(window, 'load', M.init);

    /** 
     * scripty stuff related to artist and artist pages
     */
    ID_STUDIO_INFO_TOGGLE = 'studio_info_toggle';
    ID_LINKS_TOGGLE = 'links_toggle';
    ID_ARTIST_INFO_TOGGLE = 'artist_info_toggle';
    ID_BIO_TOGGLE = 'bio_toggle';
    ID_PASSWD_TOGGLE = 'passwd_toggle';
    ID_DEACTIVATE_TOGGLE = 'deactivate_toggle';

    ID_STUDIO_SXN = 'artist_edit_address';
    ID_LINKS_SXN = 'artist_edit_links';
    ID_ARTIST_SXN = 'artist_edit_maininfo';
    ID_BIO_SXN = 'artist_edit_bio';
    ID_PASSWD_SXN = 'artist_change_passwd';
    ID_DEACTIVATE_SXN = 'artist_deactivate';

    A.SECTIONS = new Array(ID_STUDIO_SXN,
						   ID_LINKS_SXN,
						   ID_ARTIST_SXN,
						   ID_BIO_SXN,
						   ID_PASSWD_SXN,
						   ID_DEACTIVATE_SXN);

    A.TOGGLES = new Array(ID_STUDIO_INFO_TOGGLE,
						  ID_LINKS_TOGGLE,
						  ID_ARTIST_INFO_TOGGLE,
						  ID_BIO_TOGGLE,
						  ID_PASSWD_TOGGLE,
						  ID_DEACTIVATE_TOGGLE);

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
						frm.show();
						lnk.innerHTML = "hide";
					}
				}
				else {
					frm.hide();
					lnk.innerHTML = "change";
				}
			}
		}
		return false;
    }

    A.init = function() {
		var toggles = M.Artist.TOGGLES;
		var sxns = M.Artist.SECTIONS;
		var nsxn = sxns.length;
		for ( var ii = 0; ii < nsxn; ++ii ) {
			(function() {
				var lnk = $(toggles[ii] + '_lnk');
				var nm = sxns[ii];
				if (lnk) {
					Event.observe(lnk, 'click', function(event){
						M.Artist.toggleSxnVis(nm);
					});
				}
			})();
		}
		A.init = function() {}
    }

    Event.observe(window, 'load', A.init);

    T.jumpTo = function(ap_id) {
		var url = "/art_pieces/" + ap_id;
		document.location.href = url;
		return true;
    }

    function keypressHandler (event)
    {
		// I think this next line of code is accurate,
		// but I don't have a good selection of browsers
		// with me today to test this effectivly.
		var prvlnk = $('prev_img_lnk');
		var nxtlnk = $('next_img_lnk');
		if (prvlnk && nxtlnk) {
			var key = event.which || event.keyCode;
			switch (key) {
			case Event.KEY_RIGHT:
				T.jumpTo(nxtlnk.getAttribute('apid'));
				break;
			case Event.KEY_LEFT:	
				T.jumpTo(prvlnk.getAttribute('apid'));
				break;
			}
		}
    }

    T.init = function() {
		Event.observe(document, 'keypress', keypressHandler );
		var prvlnk = $('prev_img_lnk');
		var nxtlnk = $('next_img_lnk');
		if (nxtlnk && prvlnk) {
			Event.observe(nxtlnk, 'click', function() { console.log('clicked next'); });
		}
		T.init = function(){}
    }
	
    Event.observe(window, 'load', T.init);

    /*** help popup ***/
    W.popup = function(parent_id, section) {
		M.log(parent_id, section);
		var helpdiv = $(parent_id + "container");
		if (helpdiv) {
			helpdiv.toggle();
		}
    }

	/*** feedback option selector code ***/

	/* init called from after ajax load of content
       see prototype.feedback.js:Feedback.init*/
	F.hideInputs = function() {
		var inps = $$('.fdbk-inputs');
		var ninps = inps.length;
		for (var ii=0; ii<ninps; ++ii){
			inps.hide();
		}
	}
	F.COMMENT_BOX = 'comment_input';
	F.COMMENT_BOX_TA = 'feedback_comment';
	F.EMAIL_BOX = 'email_input';
	F.URL_BOX = 'url_input';
	F.SUBMIT_BOX = 'send_input';
	F.SKILL_BOX = 'skills_input';
	F.BUG_BOX = 'bug_input';

	F.showInputs = function(cmt, em, url, skil, bug) {
		var c = $(F.COMMENT_BOX);
		var e = $(F.EMAIL_BOX);
		var u = $(F.URL_BOX);
		var sk = $(F.SKILL_BOX);
		var b = $(F.BUG_BOX);
		if (c) { if (cmt) { c.show(); } else { c.hide(); }}
		if (e) { if (em) { e.show(); } else { e.hide(); }}
		if (u) { if (url) { u.show(); } else { u.hide(); }}
		if (sk) { if (skil) { sk.show(); } else { sk.hide(); }}
		if (b) { if (bug) { b.show(); } else { b.hide(); }}
		var s = $(F.SUBMIT_BOX);
		if (s) { s.show(); }
	}		
	F.setSubject = function(s) {
		var subj = $('feedback_subject');
		if (subj) { subj.value=s; }
		var lnks = $$('a.fdbk-subj');
		var nlnks = lnks.length;
		for (var ii=0; ii<nlnks; ++ii) {
			var lnk = lnks[ii]
			var sxn = lnk.href.split('#')[1];
			var cls = "lksubtle";
			if (sxn == s) {
				lnk.removeClassName(cls);
			}
			else {
				lnk.addClassName(cls);
			}
			cls = "fdbk-sel";
			if (sxn == s) {
				lnk.addClassName(cls);
			}
			else {
			    lnk.removeClassName(cls);
			}
		}
		
	}
	F.setInfoTxt = function(s) {
		var lbl = $('info_text');
		if (lbl) {
			lbl.innerHTML = s;
		}
	}
	var fdbk_methods = {
		'general': function() {
			F.showInputs(true, true, false, false, false);
  		    F.setSubject('general');
		    F.setInfoTxt("We love to get feedback.  Please let us know what you think of the website, what MAU can do for you, or whatever else you might like to tell us.  If you would like to get involved with MAU or Spring Open Studios planning, please leave your email and we'll get in touch as soon as we can. ");
		},
		'suggest':function() { 
			F.showInputs(true, false, false, false, false);
			F.setSubject('suggest');
			F.setInfoTxt('What would you like to see from MAU?');
		},
		'gallery':function() { 
			F.showInputs(true, true, false, false, false);
			F.setSubject('gallery');
			F.setInfoTxt('Tell us about your gallery and how you\'d like to work with MAU');
		},
		'business':function() { 
			F.showInputs(true, true, false, false, false);
			F.setSubject('business');
			F.setInfoTxt('Tell us about your business and how you\'d like to work with MAU');
		},
		'volunteer':function() { 
			F.showInputs(true, true, false, true, false);
			F.setInfoTxt('Tell us about your skillsets and how you would like to help MAU.');
			F.setSubject('volunteer');
		},
		'feedsuggest':function() { 
			F.showInputs(false, false, true, false, false);
			F.setInfoTxt('Point us to a feed you\'d like to see on our front page of feeds.  We\'ll check it out, and if it\'s appropriate, we\'ll add it to our list.');
			F.setSubject('feedsuggest');
		},
		'donate':function() {
			window.open('/donate','donate');
			Feedback.hideFeedback();
			return true;
		},
		'website':function() {
			F.showInputs(true, false, false, false, true);
			F.setInfoTxt('Did you find a problem with the website?  Have a feature you\'d like to see?  Let us know.');
			F.setSubject('website');
		},
		'emaillist':function() {
			F.showInputs(false, true, false, false, false);
			F.setInfoTxt("We'll keep you informed of MAU happenings, as well as shows and events involving artists who've signed up with us.");
			F.setSubject('emaillist');
		}
	}
	F.init = function(st) {
		var cmtbx = $(F.COMMENT_BOX_TA);
		if (cmtbx) {
			cmtbx.observe('focus', function() { 
				var cmtbx = $(F.COMMENT_BOX_TA);
				if (cmtbx.value == '<enter your comment here>') {
					cmtbx.value = '';
				};
				return false;
			});
		}
		var lnks = $$('a.fdbk-subj');
		var nlnks = lnks.length;
		for (var ii=0; ii<nlnks; ++ii) {
			var lnk = lnks[ii]
			var sxn = lnk.href.split('#')[1];
			if (fdbk_methods[sxn]) {
				mth = fdbk_methods[sxn];
				lnk.observe('click', fdbk_methods[sxn]);
			}
		}
		if (st) {
			fdbk_methods[st]();
		}
		else {
			fdbk_methods['general']();
		}
			
		/** do not zero out this method as we may need it again */
	}
	
}
)();

