MAU = window['MAU'] || {};

(function() {
    var T = MAU.Thumbs = MAU.Thumbs || {};
	var A = MAU.Artist = MAU.Artist || {};
    
    /** all js init goes in here. **/

	// Changes the cursor to an hourglass
	MAU.waitcursor = function() {
		document.body.style.cursor = 'wait';
	}
	
	// Returns the cursor to the default pointer
	MAU.clearcursor = function() {
		document.body.style.cursor = 'default';
	}

    MAU.goToArtist = function( artistid ) {
	window.location = "/artists/" + parseInt(artistid);
	return true;
    }

    MAU.doSearch = function( ) {
	var q = $('search_box');
	var f = $('search_form');
	if (f && q && q.value) {
	    f.submit();
	    return true;
	}
	return false;
    }

    MAU.mailer = function( name, domain, subject) {
	var lnk = "mailto:" + name + "@" + domain;
	if (subject && subject.length > -1) {
	    lnk += "?subject=" + escape(subject);
	}
	window.location = lnk;
    };

    /* leave for later in case we need to init stuff */
    MAU.init = function() {
    }

    Event.observe(window, 'load', MAU.init);

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
		var sxns = MAU.Artist.SECTIONS;
		var nsxn = sxns.length;
		for( var ii = 0; ii < nsxn; ++ii) {
			var sxnnm = sxns[ii];
			var frm = $(sxnnm);
			var lnk = $(MAU.Artist.TOGGLES[ii] + "_lnk");
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
		var toggles = MAU.Artist.TOGGLES;
		var sxns = MAU.Artist.SECTIONS;
		var nsxn = sxns.length;
		for ( var ii = 0; ii < nsxn; ++ii ) {
			(function() {
				var lnk = $(toggles[ii] + '_lnk');
				var nm = sxns[ii];
				if (lnk) {
					Event.observe(lnk, 'click', function(event){
						MAU.Artist.toggleSxnVis(nm);
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
    }
    Event.observe(window, 'load', T.init);

}
)();

