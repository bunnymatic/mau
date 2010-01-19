MAU = window['MAU'] || {};

(function() {
    var M = MAU;
    var T = M.Thumbs = M.Thumbs || {};
    var A = M.Artist = M.Artist || {};
    var W = M.WhatsThis = M.WhatsThis || {};
    var F = M.Feedback = M.Feedback || {};
    var N = M.Notifications = M.Notifications || {};

    M.__debug__ = true;

    M.addCommentBoxObserver = function( cmtbx ) {
	if (cmtbx) {
	    cmtbx.observe('focus', function() { 	
		if ((this.value == '<enter your comment here>') ||
		    (this.value == '<enter your note here>')) {
		    this.value = '';
		};
		return false;
	    });
	}
    };

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
    };

    // Changes the cursor to an hourglass
    M.waitcursor = function() {
		document.body.style.cursor = 'wait';
    };
    
    // Returns the cursor to the default pointer
    M.clearcursor = function() {
		document.body.style.cursor = 'default';
    };

    M.goToArtist = function( artistid ) {
		window.location = "/artists/" + parseInt(artistid);
		return true;
    };

    M.doSearch = function( ) {
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

    /* leave for later in case we need to init stuff */
    M.init = function() {
    };

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
    ID_NOTIFICATION_TOGGLE = 'notification_toggle';

    ID_STUDIO_SXN = 'artist_edit_address';
    ID_LINKS_SXN = 'artist_edit_links';
    ID_ARTIST_SXN = 'artist_edit_maininfo';
    ID_BIO_SXN = 'artist_edit_bio';
    ID_PASSWD_SXN = 'artist_change_passwd';
    ID_DEACTIVATE_SXN = 'artist_deactivate';
    ID_NOTIFICATION_SXN = 'artist_notification';

    A.SECTIONS = new Array(ID_STUDIO_SXN,
						   ID_LINKS_SXN,
						   ID_ARTIST_SXN,
						   ID_BIO_SXN,
						   ID_PASSWD_SXN,
						   ID_DEACTIVATE_SXN,
						  ID_NOTIFICATION_SXN);

    A.TOGGLES = new Array(ID_STUDIO_INFO_TOGGLE,
						  ID_LINKS_TOGGLE,
						  ID_ARTIST_INFO_TOGGLE,
						  ID_BIO_TOGGLE,
						  ID_PASSWD_TOGGLE,
						  ID_DEACTIVATE_TOGGLE,
						  ID_NOTIFICATION_TOGGLE);

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
    };

    /*** feedback option selector code ***/
    F.init = function() {
	var cbx = $$('div.fdbk-input #feedback_comment');
	if (cbx.length > 0) {
	    M.addCommentBoxObserver(cbx.first());
	}
    };

    N.ID_FORM = 'note_form';
    N.ID_OVERLAY = 'note_overlay';
    N.ID_MAIN = 'note_container';
    N.ID_CONTENT = 'note_modal_content';
    N.ID_MODAL_WINDOW = 'note_modal_window';
    N.ID_CLOSER = 'note_close_link';
    N.ID_CLOSE_BTN = 'note_close_btn';
    N.ID_COMMENT = 'comment';
    N.NOTEFORM_HTML = '<div id="' + N.ID_MAIN + '" style="display: none;">' +
             '<div id="' + N.ID_MODAL_WINDOW + '">' +	
             '<a href="#" id="' + N.ID_CLOSER + '">x</a>' +
             '<div id="' + N.ID_CONTENT + '"></div>' +
             '</div></div>';
    N.OVERLAY_DIV = '<div id="'+N.ID_OVERLAY+'" class="note_hide"></div>';

    N.initOverlay = function() {
	if ($$('#' + N.ID_OVERLAY).length == 0)
	    $$("body").first().insert(N.OVERLAY_DIV);
	$(N.ID_OVERLAY).addClassName('note_overlayBG');
    };
    
    N.showOverlay = function() {
	N.initOverlay();
	$(N.ID_OVERLAY).show();
    };
	 
    N.hideOverlay = function() {
	if ($$('#' + N.ID_OVERLAY).length == 0) return false;
	$(N.ID_OVERLAY).remove();
    };

    N.showNoteForm = function(ev) {
	var el = ev.findElement();
	var aid = el.readAttribute('aid');
	N.initOverlay();
	N.initNote(aid);
	$(N.ID_MAIN).show();
    };

    N.hideNote = function() {
	$(N.ID_MAIN).hide();
	$(N.ID_MAIN).remove();
	N.hideOverlay();
    }

    N.loading = function() {
	$(N.ID_CONTENT).innerHTML = "Loading...";
    }

    N.submitNote = function(event){
	M.log("Submit note");
	var data = Form.serialize($(N.ID_FORM));
	var url = $(N.ID_FORM).action;
	N.loading('Sending...');
	new Ajax.Updater(N.ID_CONTENT, url, {
	    method: 'POST',
	    parameters: data,
	    onComplete: function(transport){
		if (transport.status >= 200 && transport.status < 300) {
		    $(N.ID_MODAL_WINDOW).fade({
			duration: 3.0,
			afterFinish: function() { N.hideNote(); }
		    });
		}
		else {
		    var n = $(N.ID_FORM);
		    f.observe('submit', N.submitNote);
		    var closer = $(N.ID_CLOSE_BTN);
		    closer.observe('click', function(){
			N.hideNote();
			return false;
		    });
		}
	    }
	});
	Event.stop(event);
    }

    N.initNote = function(aid) {
	if ($$('#' + N.ID_MAIN).length == 0) {
	    $$("body").first().insert(N.NOTEFORM_HTML);
	    var closer = $(N.ID_CLOSER);
	    closer.observe('click', function(){
		N.hideNote();
		return false;
	    });
	    N.setWindowPosition();
	    N.loading();
	    new Ajax.Updater(N.ID_CONTENT, '/artists/' + aid + '/noteform',
			     {
				 method: 'get',
				 onComplete: function(transport) {
				     $(N.ID_FORM).observe('submit', N.submitNote);
				     var b = $(N.ID_CLOSE_BTN);
				     b.observe('click', function(){
					 N.hideNote();
					 return false;
				     });
				     MAU.addCommentBoxObserver($(N.ID_COMMENT));
				 }
			     });
	}
	return false;				
    };

    N.setWindowPosition = function() {
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
	$(N.ID_MODAL_WINDOW).setStyle({
	    top: (clientHeight / 10) + 'px'
	});
    }				
	 
    
    N.init = function() {
	var notes = $$('#notify_artist');
	var nnotes = notes.length
	for (var ii = 0; ii < nnotes; ++ii) {
	    var n = notes[ii];
	    if (n) { n.observe('click', N.showNoteForm); }
	}
	N.init = function() {};
    }
	
    Event.observe(window,'load', N.init)
}
)();

