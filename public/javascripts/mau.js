MAU = window['MAU'] || {};

(function() {
    var M = MAU;
    var T = M.Thumbs = M.Thumbs || {};
    var A = M.Artist = M.Artist || {};
    var W = M.WhatsThis = M.WhatsThis || {};
    var F = M.Feedback = M.Feedback || {};
    var N = M.Notifications = M.Notifications || {};
    var MA = M.Map = M.Map || {};
    var G = M.GetInvolved = M.GetInvolved || {};

    M.__debug__ = true;

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

    /** safe javascript log - for debug */
    M.log = function() {
	if (window['console'] && M.__debug__) {
	    // TODO: Chrome doesn't let us call apply on console.log.
	    // Interpolate variable arguments manually and construct
	    // a single-argument call to console.log for Chrome.
	    try {
		console.log.apply(this, arguments);
	    } catch(e) {
		M.log = function() {};
	    }
	}
    };

    // Changes the cursor to an hourglass
    M.waitcursor = function() {
	var errmsg = $('error_row');
	if (errmsg) {
	    errmsg.update('');
	}
	var dv = document.createElement('div');
	Element.extend(dv);
	dv.addClassName('wait-dialog');
	dv.show();
	var tx = document.createTextNode('Uploading...');
	dv.appendChild(tx);
	var im = document.createElement('img');
	im.setAttribute('src','/images/spinner32.gif');
	im.setAttribute('style','float:right; margin:auto;');
	dv.appendChild(im);
	document.body.appendChild(dv);
    };
    
    // Returns the cursor to the default pointer
    M.clearcursor = function() {
	document.body.style.cursor = 'default';
    };

    M.goToArtist = function( artistid ) {
	window.location = "/artists/" + parseInt(artistid,10);
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

    M.CREDITS_DIV = 'credits_div';
    /* leave for later in case we need to init stuff */
    M.init = function() {
	// init credits popup
	var fq = $('credits_lnk');
	if (fq) {
	    Event.observe(fq,'click', function(event) {
		var d = $(M.CREDITS_DIV);
		if (d) { 
		    d.remove();
		}
		d = new Element('div', { id: M.CREDITS_DIV });
		d.hide();
		var hd = new Element('div').addClassName('credits-hdr');
		hd.update('Credits');
		var bd = new Element('div').addClassName('credits-bdy');
		bd.update('<p>Web Design/Construction: Mr Rogers & Trish Tunney</p>');
		if (d && hd && bd) {
		    new Insertion.Top(d, bd);
		    new Insertion.Top(d, hd);
		}
		Event.observe(d,'click', function(event) {
		    var el = $(M.CREDITS_DIV);
		    el.blindUp();
		    return false;
		});
		var ft = $('footer_right');
		if (ft) {
		    new Insertion.Bottom(ft,d);
		}
		d.blindDown();
		event.stop();
		return false;
	    });
	}

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
    ID_EVENTS_TOGGLE = 'events_toggle';

    ID_EVENTS_SXN = 'artist_events';
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
			   ID_NOTIFICATION_SXN,
			   ID_EVENTS_SXN);

    A.TOGGLES = new Array(ID_STUDIO_INFO_TOGGLE,
			  ID_LINKS_TOGGLE,
			  ID_ARTIST_INFO_TOGGLE,
			  ID_BIO_TOGGLE,
			  ID_PASSWD_TOGGLE,
			  ID_DEACTIVATE_TOGGLE,
			  ID_NOTIFICATION_TOGGLE,
			 ID_EVENTS_TOGGLE);

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
    };

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
	A.init = function() {};
    };

    Event.observe(window, 'load', A.init);

    T.jumpTo = function(ap_id) {
	var url = "/art_pieces/" + ap_id;
	document.location.href = url;
	return true;
    };

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
	    default:
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
	T.init = function(){};
    };
    
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
	if ($$('#' + N.ID_OVERLAY).length === 0) {
	    $$("body").first().insert(N.OVERLAY_DIV);
	}
	$(N.ID_OVERLAY).addClassName('note_overlayBG');
    };
    
    N.showOverlay = function() {
	N.initOverlay();
	$(N.ID_OVERLAY).show();
    };
    
    N.hideOverlay = function() {
	if ($$('#' + N.ID_OVERLAY).length === 0) return;
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
    };

    N.loading = function() {
	$(N.ID_CONTENT).innerHTML = "Loading...";
	$(N.ID_CONTENT).addClassName('note-loading');
    };

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
    };

    N.initNote = function(aid) {
	if ($$('#' + N.ID_MAIN).length === 0) {
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
				     $(N.ID_CONTENT).removeClassName('note-loading');
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
    };
    
    
    N.init = function() {
	var notes = $$('#notify_artist');
	var nnotes = notes.length;
	for (var ii = 0; ii < nnotes; ++ii) {
	    var n = notes[ii];
	    if (n) { n.observe('click', N.showNoteForm); }
	}
	N.init = function() {};
    };
    
    Event.observe(window,'load', N.init);


    /** get involved **/
    G.TOGGLELNK_SUFFIX = '_toggle_lnk';
    G.NTRUNC = G.TOGGLELNK_SUFFIX.length;
    G.ITEMS = new Array('volunteer','donate','emaillist',
			'suggest','shop','venue','business');
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
		    if (s == s2) {
			dv.toggle();
		    }
		    else {
			dv.hide();
		    }
		}
	    }
	}
    };

    G.init = function() {
	// pick out special items 
	// shop -> cafe press
	// email -> mailto:
	var specialCases = new Array('shop');

	var items = $$('div.gi a');
	var nitems = items.length;
	var ii = 0;
	for (ii = 0; ii < nitems; ++ii) {
	    var tg = items[ii];
	    if (tg) {
		tg.observe('click', function() {
		    var s = _giLnk2Div(this.id);
		    G.showSection(s);
		});
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

    MA.ID_OS_FORM = "map_osswitcher";
    MA.ID_OS_CHECKBOX = "map_cb";
    MA.init = function() {
	var mcb = $(MA.ID_OS_FORM);
	if (mcb) {
	    $(MA.ID_OS_CHECKBOX).observe('click', function() {
		var mcb = $(MA.ID_OS_FORM);
		if (mcb) {
		    mcb.submit();
		}
	    });
	}
	MA.init = function(){};
    };
    Event.observe(window,'load',MA.init);
    
}
)();

