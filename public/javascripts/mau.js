MAU = window['MAU'] || {};

/** setup hash change observer */

var Utils = {
  selected : function(elid) {
    var opts = $(elid).select('option');
    return opts.find(function(ele){return !!ele.selected;});
  }
};

Element.addMethods(Utils);

var FormMethods = {
  focus_first : function(f) {
    if (!f) return;
    var inps = f.select('input');
    var ni = inps.length;
    for (var ii =0; ii < ni; ++ii) {
      var inp = inps[ii];
      if ( $(inp).readAttribute('type') != 'hidden' ) {
	inp.activate();
	break;
      }
    }
  }
};

Element.addMethods('form', FormMethods);

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

/** ruby helper methods in js */
var TagMediaHelper = {
  _format_item: function(item, pfx, dolink, linkopts) {
    try {
      linkopts = linkopts || {};
      if (!item.id) {
	return '';
      }
      if (dolink) {
	linkopts.href = pfx + item.id;
	var a = new Element('a', linkopts);
	a.update(item.name);
	return a;
      }
      else {
	return item.name;
      }
    } catch(e) {
      M.log(e);
      return null;
    }
  },
  format_medium: function(dolink, linkopts) {
    return TagMediaHelper._format_item(this,'/media/', dolink, linkopts);
  },
  format_tag: function(dolink, linkopts) {
    return TagMediaHelper._format_item(this,'/tags/', dolink, linkopts);
  },
  format_tags: function(dolink, opts) {
    var tagstrs = [];
    var n = this.length;
    for (var ii=0;ii<n;ii++){
      tagstrs.push( TagMediaHelper.format_tag.apply(this[ii],[dolink, opts]));
    }
    return tagstrs;
  }
};

(function() {
  var M = MAU;
  var T = M.Thumbs = M.Thumbs || {};
  var A = M.Artist = M.Artist || {};
  var AP = M.ArtPiece = M.ArtPiece || {};
  var W = M.WhatsThis = M.WhatsThis || {};
  var F = M.Feedback = M.Feedback || {};
  var N = M.Notifications = M.Notifications || {};
  var NV = M.Navigation = M.Navigation || {};
  var MA = M.Map = M.Map || {};
  var G = M.GetInvolved = M.GetInvolved || {};
  var S = M.Submissions = M.Submissions || {};
  var TB = M.Toolbar = M.Toolbar || {};
  var FR = M.FrontPage = M.FrontPage || {};
  var AC = M.Account = M.Account || {};

  M.__debug__ = true;
  M.BLIND_OPTS = { up: {duration: 0.25},
                   down: {duration: 0.75} };
  M.FADE_OPTS = { 'in': {duration: 0.25, from:0, to:1},
                  'out': {duration: 0.25} };
  M.SPINNER = new Element('img',{src:'/images/spinner32.gif'});

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
	try {
	  if (console) {
	    var msg = '';
	    var i = 0;
	    var n = arguments.length;
	    for (;i<n;++i) {
	      msg += arguments[i];
	    }
	    console.log(msg);
	  }
	} catch(ee) {
	  H.log = function() {};
	}
      }
    }
  };
  // Changes the cursor to an hourglass
  M.waitcursor = function() {
    var errmsg = $('error_row');
    if (errmsg) {
      errmsg.update('');
    }
    var dv = new Element('div');
    dv.addClassName('wait-dialog');
    dv.show();
    var tx = new Element('span');
    tx.update('Uploading...');
    dv.appendChild(tx);
    var im = M.SPINNER;
    im.setAttribute('style','float:right; margin:auto;');
    dv.appendChild(im);
    document.body.appendChild(dv);
  };
  
  // Returns the cursor to the default pointer
  M.clearcursor = function() {
    document.body.style.cursor = 'default';
  };

  M.goToArtist = function( artistid ) {
    window.location = "/users/" + parseInt(artistid,10);
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
	bd.update('<div style="text-align: center;"><p>Web Design/Construction: Mr Rogers & Trish Tunney</p></div><div style="width:350px; text-align:center; border:0px; margin:10px auto 10px auto;" class="credits-img"><span style="padding-bottom:4px; ">Built at MAU Headquarters</span><img style="border: 1px solid #222;" width="350" src="/images/mau-headquarters-small.jpg"/></div><div style="font-size: x-small; text-align:right; padding-bottom: 2px; padding-right: 10px;">click to close</div>');
	if (d && hd && bd) {
	  new Insertion.Top(d, bd);
	  new Insertion.Top(d, hd);
	}
	Event.observe(d,'click', function(event) {
	  bg.remove();
	  cn.remove();
	  return false;
	});
	new Insertion.Top(cn, d);
	new Insertion.Top(document.body,cn);
	new Insertion.Top(document.body,bg);

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
	event.stop();
	return false;
      });
    }

  };

  Event.observe(window, 'load', M.init);

  /** front page thumbs **/
  Object.extend(FR, {
    init: function() {
      setInterval( function() { FR.update_art(); }, 12000);
      FR.init = function() {};
    },
    update_art: function() {
      var d = $('sampler');
      if (d) { 
	new Ajax.Request('/main/sampler', { method:'get',
					    onSuccess: function(tr) {
					      d.setOpacity(0);
					      d.update('');
					      var h = tr.responseText;
					      new Insertion.Top(d,h);
					      d.appear();
					    }
					  });
      }
    }
  });
  
  Event.observe(window, 'load', FR.init);
  /** nav bar related **/
  N.init = function() {
    var navleaves = $$('.nav li.leaf');
    navleaves.each( function(nl) {
      nl.observe('click', function(ev) {
	try {
	  var lk = this.select('a').first();
	  if (lk) {
	    ev.stopPropagation();
	    location.href = lk.readAttribute('href');
	  }
	}
	catch(e) {
	  M.log("Failed to fire click");
	  M.log(e);
	}
      });
    });
    /* same for top level items */
    var navtop = $$('.nav li.dir');
    navtop.each( function(nl) {
      nl.observe('click', function(ev) {
	try {
	  var lk = this.select('a').first();
	  if (lk) {
	    location.href = lk.readAttribute('href');
	  }
	}
	catch(e) {
	  M.log("Failed to fire click");
	  M.log(e);
	}
      });
    });

    N.init = function() {};
  };
  Event.observe(window, 'load', N.init);
  
  /** 
     * scripty stuff related to artist and artist pages
     */
  ID_STUDIO_INFO_TOGGLE = 'studio_info_toggle';
  ID_LINKS_TOGGLE = 'links_toggle';
  ID_ARTIST_INFO_TOGGLE = 'info_toggle';
  ID_BIO_TOGGLE = 'bio_toggle';
  ID_PASSWD_TOGGLE = 'passwd_toggle';
  ID_DEACTIVATE_TOGGLE = 'deactivate_toggle';
  ID_NOTIFICATION_TOGGLE = 'notification_toggle';
  ID_EVENTS_TOGGLE = 'events_toggle';

  ID_EVENTS_SXN = 'events';
  ID_STUDIO_SXN = 'address';
  ID_LINKS_SXN = 'links';
  ID_ARTIST_SXN = 'info';
  ID_BIO_SXN = 'bio';
  ID_PASSWD_SXN = 'passwd';
  ID_DEACTIVATE_SXN = 'deactivate';
  ID_NOTIFICATION_SXN = 'notification';

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
	    frm.blindDown(M.BLIND_OPTS['down']);
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
    if ( location.hash && (location.hash.length > 1)) { 
      var sxn = location.hash.substr(1);
      M.Artist.toggleSxnVis(sxn);
    }

    A.init = function() {};
  };

  Event.observe(window, 'load', A.init);

  /** art piece methods */
  AP.init = function() {
    if (location.hash) {
      var newid = location.hash.substr(1);
      M.log(newid);
      var urlbits = location.href.split('/');
      var n = urlbits.length;
      urlbits[n-1] = newid;
      var newurl = urlbits.join('/');
      location.href = newurl;
    }
    var moveleft = $$('.mv-left');
    if (moveleft && moveleft.length > 0) {
      moveleft.first().addClassName("first");
      moveleft.each(function(ml) {
        ml.observe('click', function(ev) {
          var parent = $(this).up();
          var _id = parent.readAttribute('pid');
          AP.move_art(_id,'left');
        });
      });
    }
    var moveright = $$('.mv-right');
    if (moveright && moveright.length > 0) {
      moveright.last().addClassName("last");
      moveright.each(function(mr) {
        mr.observe('click', function(ev) {
          var parent = $(this).up();
          var _id = parent.readAttribute('pid');
          AP.move_art(_id,'right');
        });
      });
    }
    var aps = $$('.thumbs-select .artp-thumb img');
    aps.each(function(ap) {
      ap.observe('click', function(ev) {
	var apid = $(this).up().readAttribute('pid');
	var inp = $('art_'+apid);
	if (inp) {
	  inp.click();
	}
      });
    });
    
    var aafrm = $('arrange_art_form');
    if(aafrm) {
      aafrm.observe('submit', function(ev) {
        // construct new order
        var divs = $$('.artp-thumb-container');
        var ii = 0;
        var ndivs = divs.length;
        var neworder = [];
        for(;ii<ndivs;++ii) {
          neworder.push(parseInt(divs[ii].readAttribute('pid'),10));
        }
        var no = neworder.join(",");
        $(aafrm).insert( new Element('input', { type:"hidden", name:'neworder', value:no }));
      });
    }
  };
  Event.observe(window, 'load', AP.init);

  AP.move_art = function(_id, direction) {
    var divs = $$('.artp-thumb-container');
    var swap = [];
    var ndivs = divs.length;
    var ii = 0;
    var idxs = null;
    for (;ii<ndivs;++ii) {
      var d = divs[ii];
      if (d.readAttribute('pid') == _id) {
        ii2 = (direction == 'left') ? ii-1:ii+1;
        idxs = [ ii, ii2 ];
      }
      d.select('.mv-right').each(function(el) {
        el.removeClassName('last').removeClassName('first');
      });
      d.select('.mv-left').each(function(el) {
        el.removeClassName('last').removeClassName('first');
      });
      
    }
    M.log("Swap " + idxs[0] + " with " + idxs[1] + " (dir " + direction + ")");
    if (idxs) {
      var d1 = divs[idxs[0]];
      var d2 = divs[idxs[1]];
      if (direction == 'left') {
        d2.insert({'before':d1.remove()});
      } else {
        d2.insert({'after':d1.remove()});
      }
    }
    $$('.mv-left').first().addClassName("first");
    $$('.mv-right').last().addClassName("last");

  };

  T.ThumbList = [];
  T.APCache = {};
  T.curIdx = 0;
  T.Helpers = {
    find_thumb: function(apid) {
      var i = 0;
      var n = T.ThumbList.length;
      for(;i<n;++i) {
	var t = T.ThumbList[i];
	if (t.id == apid) {
	  return i;
	}
      }
      return null;
    },
    get_image_path: function(fname, sz) {
      var sub = { thumb: "t_",
	small:"s_",
	medium: "m_" };
      if (sz in sub) {
	var reg = /(^\/*artistdata\/\d+\/imgs\/)(.*)/;
	var f = fname.replace(reg, "$1"+sub[sz]+"$2");
	if (f[0] != '/') {
	  f = '/'+f;
	}
	return f;
      }
      return fname;
    },
    safe_update: function(id, val) {
      var el = $(id);
      if (el) { el.update(val); }
    },
    update_highlight: function() {
      var idx = T.curIdx;
      var ts = $$('div.tiny-thumb');
      var i = 0;
      var n = ts.length;
      for (;i<n;++i) {
	ts[i].removeClassName('tiny-thumb-sel');
      }
      ts[idx].addClassName('tiny-thumb-sel');
    },
    update_info: function(ap) {
      var f = ap.filename;
      var img = $('artpiece_img');
      if (f) {
	f = this.get_image_path(f,'medium');
	img.src = f;
	this.safe_update('artpiece_title',ap.title);
	this.safe_update('ap_title', ap.title);
	this.safe_update('ap_dimensions', ap.dimensions);
	this.safe_update('ap_year',ap.year);
	var med = TagMediaHelper.format_medium.apply(ap.medium,[true]);
	if (med) {
	  var md = $("ap_medium");
	  if (md) {
	    md.update('');
	    new Insertion.Bottom(md, med);
	  }
	}
	var ts = TagMediaHelper.format_tags.apply(ap.tags,[true]);
	var i = 0;
	var ntags = ts.length;
	var tgs = $('ap_tags');
	if (tgs) {
	  tgs.update('');
	  for (;i<ntags;++i){
	    new Insertion.Bottom(tgs, ts[i]);
	    if (i != (ntags-1)) {
	      new Insertion.Bottom(tgs,', ');
	    }
	  }
	}
	if ('cache' in ap) {
	  img.appear();
	} else {
	  setTimeout(function() {img.appear();}, 50);
	}
      }
    },
    update_links: function(ap) {
      var b = ap.buttons;
      if (b && b.length) {
	var dv = $$('.edit-buttons').first();
	if (dv) {
	  dv.update(b);
	}
      }
    },
    update_page: function() {
      var idx = T.curIdx;
      var ap = T.ThumbList[idx];
      var url = "/art_pieces/" + ap.id + "?format=json";
      T.Helpers.update_highlight();
      location.hash = "#" + ap.id;
      var img = $('artpiece_img');
      img.setOpacity(0);
      if (T.APCache[ap.id]) {
	var a = T.APCache[ap.id];
	T.Helpers.update_info(a);
	T.Helpers.update_links(a);
      } else {
	var resp = new Ajax.Request(url, {
	  onSuccess: function(resp) {
	    try {
	      var ap_raw = resp.responseJSON;
	      // handle different json encodings :(
	      var ap = null;
	      if ('attributes' in ap_raw) {
		ap = ap_raw.attributes;
	      }
	      else {
		ap = ap_raw.art_piece;
	      }
	      T.APCache[ap.id] = ap;
	      T.Helpers.update_info(ap);
	      T.Helpers.update_links(ap);
	      ap.cache=true;
	    }
	    catch(e) {
	      M.log(e);
	    }
	  },
	  contentType: "application/json",
	  method: 'get' }
				   );
      }
      return true;
    }
  };

  T.jumpToIdx = function (idx) {
    var n = T.ThumbList.length;
    if (idx < 0) { idx = n-1; }
    idx = idx % n;
    var ap = T.ThumbList[idx];
    T.curIdx = idx;
    T.Helpers.update_page();
    return false;
  };

  T.jumpTo = function(ap_id) {
    var idx = T.Helpers.find_thumb(ap_id);
    T.jumpToIdx(idx);
  };
  T.jumpNext = function() {
    T.jumpToIdx(T.curIdx+1); 
  };
  T.jumpPrevious = function() {
    T.jumpToIdx(T.curIdx-1);
  };
  function keypressHandler (event)
  {
    // I think this next line of code is accurate,
    // but I don't have a good selection of browsers
    // with me today to test this effectivly.
    var key = event.which || event.keyCode;
    switch (key) {
    case Event.KEY_RIGHT:
      T.jumpNext();
      break;
    case Event.KEY_LEFT:
      T.jumpPrevious();
      break;
    default:
      break;
    }
  }

  T.init = function() {
    Event.observe(document, 'keydown', keypressHandler );
    var prvlnk = $('prev_img_lnk');
    var nxtlnk = $('next_img_lnk');
    if (nxtlnk && prvlnk) {
      prvlnk.observe('click', function() { T.jumpPrevious(); });
      nxtlnk.observe('click', function() { T.jumpNext(); });
    }
    $$('a.jump-to').each(function(t) {
      t.observe('click', function() { 
	location.href = t.href;
	var apid = location.hash.substr(1);
        if (apid) {
	  T.jumpTo(apid);
        }
      });
    });
    
    T.init = function(){};
  };
  
  Event.observe(window, 'load', T.init);

  /*** help popup ***/
  W.popup = function(parent_id, section) {
    var helpdiv = $(parent_id + "container");
    if (helpdiv.visible()) {
      helpdiv.fade({duration:0.2});
    }
    else { helpdiv.appear({duration:0.5}); }

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
      new Ajax.Updater(N.ID_CONTENT, '/users/' + aid + '/noteform',
		       {
			 method: 'get',
			 onComplete: function(transport) {
			   $(N.ID_CONTENT).removeClassName('note-loading');
                           $(N.ID_FORM).focus_first();
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
	    if (dv.visible()){
	      dv.blindUp(M.BLIND_OPTS['up']);
	    } else {
	      dv.blindDown(M.BLIND_OPTS['down']);
	    }
	  }
	  else {
	    dv.blindUp(M.BLIND_OPTS['up']);
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

    var items = $$('div.open-close-div a');
    var nitems = items.length;
    var ii = 0;
    for (ii = 0; ii < nitems; ++ii) {
      var tg = items[ii];
      if (tg) {
	tg.observe('click', function(e) {
	  var s = _giLnk2Div(this.id);
	  G.showSection(s);
	  return false;
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

  Object.extend(AC, {
    CHOOSER: 'account_type_chooser',
    DEFAULT_OPTION: 'select_account_default_option',
    FORM_HASH: { Artist: { container:'artist_signup_form', 
                           form: 'new_artist' },
                 MAUFan: { container: 'fan_signup_form',
                           form: 'new_mau_fan' } },
    onload: function() {
      var $chooser = $(AC.CHOOSER);
      if ($chooser) {
        Event.observe($chooser,'change', AC.open_selected_form);
        if (intype) {
          AC.open_selected_form(intype);
        } else {
          AC.open_form('Artist', false);
        }
      }
    },
    open_selected_form: function() {
      var newform = $(AC.CHOOSER).selected();
      AC.open_form(newform.value, true);
      // remove dummy option
      var $def = $(AC.DEFAULT_OPTION);
      if ($def) { $def.remove() };
    },
    open_form: function(frmtype, enabled) {
      if (!(frmtype in AC.FORM_HASH)) {
        return;
      }
      var form_info = AC.FORM_HASH[frmtype];
      var div_id = form_info['container'];
      var $dv = $(div_id);
      if ($dv) {
        for (var k in AC.FORM_HASH) {
          var current = AC.FORM_HASH[k];
          var cdiv = current['container'];
          var cfrm = current['form'];
          var $cfrm = $(cfrm);
          var $cdiv = $(cdiv);
          if (div_id == cdiv) {
            if (!$cdiv.visible()) { //show if necessary
              $cdiv.fade(M.FADE_OPTS['in']);
              $cdiv.setStyle({display:'block'});
            }
            // enable/disable all form inputs based on enabled input
            $cfrm[enabled?'enable':'disable']();
            if (enabled) {
              $cfrm.removeClassName('disabled'); 
              $cfrm.focus_first();
            }
            else {
              $cfrm.addClassName('disabled');
            }
          } else { // hide
            $cdiv.fade(M.FADE_OPTS['out']);
            $cdiv.setStyle({display:'none'});
            $cfrm.disable();
          }
        }
      }
    }
  });
  Event.observe(window,'load', AC.onload);
}
)();

