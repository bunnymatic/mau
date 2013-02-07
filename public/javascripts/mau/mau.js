/** setup hash change observer */

var Utils = {
  selected : function(elid) {
    var opts = $(elid).select('option');
    return opts.find(function(ele){return !!ele.selected;});
  }
};

Element.addMethods(Utils);

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

var FormMethods = {
  focus_first : function(f) {
    if (!f) {return;}
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
    return TagMediaHelper._format_item(this,'/art_piece_tags/', dolink, linkopts);
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
  var FV = M.Favorites = M.Favorites || {};
  var JSF = M.Flash = M.Flash || {};

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

  M.addArtPieceSubmissionObserver = function() {
    var art_piece_submit = $('art_piece_submit');
    if (art_piece_submit) {
      art_piece_submit.observe('click', function(ev) {
        if (AP.validate_art_piece('new_artpiece')) {
          MAU.waitcursor();
          return true;
        }
        else {
          ev.stop();
          return false;
        }
      });
    }
  };

  /** safe javascript log - for debug */
  M.log = function() {
    if (window.console && M.__debug__) {
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
	bd.update('<div style="text-align: center;">'+
                  '<p>Web Design/QA: Trish Tunney</p>' +
                  '<p>Web Construction: <a href="http://rcode5.com">Mr Rogers @ Rcode5 </a></p>' +
                  '<p><span style="padding-bottom:14px; ">Built at MAU Headquarters</p>'+
                  '</div>'+
                  '<div class="credits-img"><img width="350" src="/images/mau-headquarters-small.jpg"/></div>'+
                  '<div class="close_btn">click to close</div>'+
                  '<div class="release_version">Release: Corvair 4.0</div><div class="clear"></div>');
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
	event.stop();
	return false;
      });
    }
    M.addArtPieceSubmissionObserver();
    M.addFlashObserver();
  };

  Event.observe(window, 'load', M.init);

  /** front page thumbs **/
  Object.extend(FR, {
    requests: [],
    init: function() {
      setInterval( function() { FR.update_art(); }, 10000);
      FR.init = function() {};
    },
    update_art: function() {
      var d = $('sampler');
      if (d) { 
	var req = new Ajax.Request('/main/sampler', { method:'get',
					              onSuccess: function(tr) {
					                d.setOpacity(0);
					                d.update('');
					                var h = tr.responseText;
					                var dummy = new Insertion.Top(d,h);
					                d.appear();
					              }
					            });
        FR.requests.push(req);
      }
    },
    abort_requests: function() {
      if (FR.requests.length > 0) {
        FR.requests.each(function(req) {
          if (req.abort) { req.abort(); }
        });
        FR.requests = [];
      }
    }
  });

  if (document.location.pathname == '/') {
    Event.observe(window, 'load', FR.init);
    Event.observe(window, 'unload', FR.abort_requests);
  }
  /** nav bar related **/
  N.init = function() {
    var navleaves = $$('.nav li.leaf');
    navleaves.each( function(nl) {
      nl.observe('click', function(ev) {
	try {
	  var lk = this.select('a').first();
	  if (lk) {
	    ev.stop();
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
    
    var s = $('emailsettings_fromall');
    if (s) {
      s.observe('click', function() {
        if (this.checked) {
          $('emailsettings_fromartist').checked = true;
        }
      });
    }
    s = $('emailsettings_fromartist');
    if (s) {
      s.observe('click', function() {
        var t = $('emailsettings_fromall');
        if (t.checked && !this.checked) {
          t.checked = false;
        }
      });
    }
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
  ID_FAVORITES_TOGGLE = 'favorites_toggle';

  ID_EVENTS_SXN = 'events';
  ID_STUDIO_SXN = 'address';
  ID_LINKS_SXN = 'links';
  ID_ARTIST_SXN = 'info';
  ID_BIO_SXN = 'bio';
  ID_PASSWD_SXN = 'passwd';
  ID_DEACTIVATE_SXN = 'deactivate';
  ID_NOTIFICATION_SXN = 'notification';
  ID_FAVORITES_SXN = 'favorites';

  A.SECTIONS = [ID_STUDIO_SXN,
		ID_LINKS_SXN,
		ID_ARTIST_SXN,
		ID_BIO_SXN,
		ID_PASSWD_SXN,
		ID_DEACTIVATE_SXN,
		ID_NOTIFICATION_SXN,
		ID_EVENTS_SXN,
                ID_FAVORITES_SXN];

  A.TOGGLES = [ID_STUDIO_INFO_TOGGLE,
	       ID_LINKS_TOGGLE,
	       ID_ARTIST_INFO_TOGGLE,
	       ID_BIO_TOGGLE,
	       ID_PASSWD_TOGGLE,
	       ID_DEACTIVATE_TOGGLE,
	       ID_NOTIFICATION_TOGGLE,
	       ID_EVENTS_TOGGLE,
               ID_FAVORITES_TOGGLE];

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
    var new_setting = parseInt($(sel).value,10)
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
        }
        else
        {
          $$('#artist_edit .os-violator')[0].hide();
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
    
    
    A.init = function() {};
  };

  Event.observe(window, 'load', A.init);

  /** art piece methods */
  AP.init = function() {
    if (location.hash && location.href.match(/art_pieces\/\d+/)) {
      var newid = location.hash.substr(1);
      if (newid) {
        var urlbits = location.href.split('/');
        var n = urlbits.length;
        urlbits[n-1] = newid;
        var newurl = urlbits.join('/');
        location.href = newurl;
      }
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

    var zoomBtn = $$('.action-icons a.zoom');
    _.each(zoomBtn, function(zoom) {
      zoom.observe('click', function(ev) {
        var t = ev.currentTarget || ev.target;
        /** current target/target work around for IE */
        if (t.tagName == 'DIV' && /micro/.test(t.className)) { /* hit the zoom div */
          t = t.up();
        }
        MAU.ImageLightbox.init({image:{url: t.data('image'),
                                       width: t.data('imagewidth'),
                                       height: t.data('imageheight')
                                      }
                               });
        MAU.ImageLightbox.show({position:'center'});
        ev.stopPropagation();
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
  
  /* validate upload date */
  AP.validate_art_piece = function(frm) {
    var input_filename = $(frm).select('#upload_datafile');
    if (input_filename.length) {
      var fname = input_filename[0].value;
      var re = /[\#|\*|\(|\)|\[|\]|\{|\}|<|\>|\$|\!\?|\;|\'\"]/;
      if (fname.match(re)) {
        alert("You need to change the filename of the file you're"+
              "trying to upload.  We don't do well with quotation"+
              " marks and other special characters "+
              "( like | or [] or {} or * or # or ; ).  "+
              "Please rename that file before trying to upload again.");
        return false;
      }
      return true;
    }
  };
  AP.move_art = function(_id, direction) {
    var removeLastFirstClasses = function(element) {
      element.removeClassName('last').removeClassName('first');
    };      
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
      d.select('.mv-right').each(removeLastFirstClasses);
      d.select('.mv-left').each(removeLastFirstClasses);
    }
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

  T.APCache = {};
  T.Helpers = {
    find_thumb: function(apid) {
      var i = 0;
      if (T.ThumbList) {
        var n = T.ThumbList.length;
        for(;i<n;++i) {
	  var t = T.ThumbList[i];
	  if (t.id == apid) {
	    return i;
	  }
        }
        return null;
      }
    },
    // get_image_path: function(fname, sz) {
    //   var sub = { thumb: "t_",
    //               small:"s_",
    //               medium: "m_",
    //               large: "l_",
    //               original: ''};
    //   if (sz in sub) {
    //     var f = fname.replace(/^public\//,'/');
    //     f = f.replace(/^\/public\//,'/');
    //     var reg = /(^\/*artistdata\/\d+\/imgs\/)(.*)/;
    //     f = f.replace(reg, "$1"+sub[sz]+"$2");
    //     if (f[0] != '/') {
    //       f = '/'+f;
    //     }
    //     return f;
    //   }
    //   return fname;
    // },
    safe_update: function(id, val) {
      var el = $(id);
      if (el) { el.update(val ? val : ''); }
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
      var dummy = null;
      var f = ap.image_files.medium;
      var img = $('artpiece_img');
      if (f) {
	img.src = f;
	this.safe_update('artpiece_title',ap.title);
	this.safe_update('ap_title', ap.title);
	this.safe_update('ap_dimensions', ap.dimensions);
	this.safe_update('ap_year',ap.year);
	this.safe_update('ap_favorites',ap.favorites_count);
	this.safe_update('num_favorites',ap.favorites_count);
	var med = TagMediaHelper.format_medium.apply(ap.medium,[true]);
	var md = $("ap_medium");
	if (md) {
	  md.update('');
	  dummy = new Insertion.Bottom(md, med);
	}
	var ts = TagMediaHelper.format_tags.apply(ap.tags,[true]);
	var i = 0;
	var ntags = ts.length;
	var tgs = $('ap_tags');
	if (tgs) {
	  tgs.update('');
	  for (;i<ntags;++i){
	    dummy = new Insertion.Bottom(tgs, ts[i]);
	    if (i != (ntags-1)) {
	      dummy = new Insertion.Bottom(tgs,', ');
	    }
	  }
	}
	if (img) {
          img.show();
        }
        
        // hides errors/notices
        $$('.notice').each(function(el) { 
          if (el.visible()) {
            el.fade({duration:0.3, 
                     afterFinish: function() {el.remove();}}); 
          }
        });
        $$('.error-msg').each(function(el) { 
          if (el.visible()) {
            el.fade({duration:0.3, 
                     afterFinish: function() {el.remove();}}); 
          }
        });

        var $zoom = $$('a.zoom')[0];
        if ($zoom) {
          var _that = this;
          $zoom.data('image', ap.image_files.large);
          $zoom.data('imageheight', ap.image_dimensions.large[1]);
          $zoom.data('imagewidth', ap.image_dimensions.large[0]);
        }
        var $favs = $$('.favorite_this');
        if ($favs.length > 0) {
          $favs[0].setAttribute('fav_id', ap.id);
        }
        var $shares = $$('.action-icons a');
        if ($shares.length > 0) {
          $shares.each(function(lnk) {
            var href = lnk.getAttribute('href');
            href = href.replace(/(%2Fart_pieces%2F)\d+(.*)/,"$1"+ap.id+"$2" );
            lnk.writeAttribute('href', href);
          });
        }
        var $edits = $$('.edit-buttons a');
        if ($edits.length > 0) {
          $edits.each(function(lnk) {
            var href = lnk.getAttribute('href');
            href = href.replace(/(art_pieces\/)\d+(.*)/,"$1"+ap.id+"$2" );
            lnk.writeAttribute('href', href);
          });
        }
      }
    },
    update_page: function() {
      var idx = T.curIdx;
      var ap = T.ThumbList[idx];
      var url = "/art_pieces/" + ap.id + ".json";
      
      T.Helpers.update_highlight();
      location.hash = "#" + ap.id;
      var img = $('artpiece_img');
      if (T.APCache[ap.id]) {
	var a = T.APCache[ap.id];
	T.Helpers.update_info(a);
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
	      ap.cache=true;
	    }
	    catch(e) {
              M.log('Failed to update page');
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
    if (T.ThumbList) {
      var n = T.ThumbList.length;
      if (idx < 0) { idx = n-1; }
      idx = idx % n;
      var ap = T.ThumbList[idx];
      T.curIdx = idx;
      T.Helpers.update_page();
    }
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
  
  T.curIdx = 0;

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
          return false;
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
      M.addCommentBoxObserver();
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
    if ($$('#' + N.ID_OVERLAY).length === 0) {
      return;
    }
    $(N.ID_OVERLAY).remove();
  };

  N.showNoteForm = function(ev) {
    var aid = this.readAttribute('aid');
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
    var data = $(N.ID_FORM).serialize(true);
    var url = $(N.ID_FORM).action;
    N.loading('Sending...');
    var xhr = new Ajax.Updater(N.ID_CONTENT, url, {
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
      var xhr = new Ajax.Updater(N.ID_CONTENT, '/users/' + aid + '/noteform',
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
    } else if (document.documentElement && document.documentElement.scrollTop) { // Explorer 6 Strict
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
    var notes = $$('.notify-artist');
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

  /** javascript flash */
  Object.extend(JSF, {
    WRAPPER: 'jsFlash',
    show:function(msgs, container) {
      var w = $(this.WRAPPER);
      if ( w ) {
        w.remove();
      }
      w = this.construct(msgs);
      var c = $$(container).first() || document.body;
      c.insert({top:w});
      w.show();
      M.addFlashObserver();
    },
    hide:function() {
      var w = $(this.WRAPPER);
      if (w) { w.hide(); }
    },
    construct: function(msgs) {
      var flash = new Element('div', {id:this.WRAPPER, style:'display:none;'});
      var err = msgs.error;
      var notice = msgs.notice;
      if ( err ) {
        var contents = new Element('div', {'class':'error-msg'});
        contents.innerHTML = err;
        flash.insert(contents);
      } 
      if (notice) {
        var contents = new Element('div', {'class':'notice'});
        contents.innerHTML = notice;
        flash.insert(contents);
      }
      return flash;
    },
    init:function() {
    }
  });
  
  Event.observe(window,'load', JSF.init);

  Object.extend(AC, {
    CHOOSER: 'account_type_chooser',
    onload: function() {
      var $chooser = $(AC.CHOOSER);
      if ($chooser) {
        Event.observe($chooser,'change', AC.open_selected_form);
      }
    },
    open_selected_form: function() {
      var newform = $(AC.CHOOSER).selected();
      var uri_parser = new MAU.QueryStringParser("/users/new");
      uri_parser.query_params.type = newform.value;
      window.location.href = uri_parser.toString();
    }
  });
  Event.observe(window,'load', AC.onload);

  
  var Favorites = {
    favorites_per_row : 20,
    init: function() {
      var favorites = $$('.favorite_this');
      $$('.favorite_this').each(function(lnk) {
        lnk.observe('click', function() {
          var tp = lnk.readAttribute('fav_type');
          var id = lnk.readAttribute('fav_id');
          if (tp && id) {
            post_to_url('/users/add_favorite', {fav_type: tp,fav_id: id} );
          }
        });
      });
      $$('.favorites-block div.thumb').each( function(el) {
        el.observe('mouseover', Favorites.show_delete);
        el.observe('mouseout', Favorites.hide_delete);
      });
      $$('.favorites ul li .name .del-btn').each( function(el) {
        el.observe('click', Favorites.execute_delete);
      });
      $$('#my_favorite_artists .delete-fav').each( function(el) {
        el.observe('click', Favorites.execute_ajax_delete);
      });
      $$('#my_favorite_artpieces .delete-fav').each( function(el) {
        el.observe('click', Favorites.execute_ajax_delete);
      });

      $$('.favorites-block').each( function(blk) {
        var _id = blk.readAttribute('id');
        var show_links = blk.select('.show-toggle');
        $(show_links).each(function(show_link) {
          show_link.addClassName('fewer');
          show_link.select('a').each( function(lnk) {
            lnk.writeAttribute('title','show all');
            lnk.observe('click', function(ev) {
              Favorites.show("#" + _id); 
            });
          });
        });
        blk.observe('favorite:removed', Favorites.update_favorites_block);
      });
      Favorites.show_fewer('#my_favorites');
      Favorites.show_fewer('#favorites_me');
      var sm = $$('#my_favorites .show-toggle').first();
      if (sm) {
        sm.observe('click', function(ev) { 
          Favorites.show('#my_favorites');
          ev.stop();
        });
      }
      sm = $$('#favorites_me .show-toggle').first();
      if (sm) {
        sm.observe('click', function(ev) { 
          Favorites.show('#favorites_me');
          ev.stop();
        });
      }
    },
    update_favorites_block: function(ev) {
      var blk = ev.target;
      var numfavs = $(blk).select('.thumb').length;
      var spanct = $(blk).select('.fav-count');
      if (spanct.length) {
        spanct[0].update(numfavs);
      }
    },
    show: function(block_id) {
      var thumbs = $$(block_id + ' .favorite-thumbs li');
      var show_link = $$(block_id + ' .show-toggle');
      var show_more = true;
      $(show_link).each(function(lk) {
        if (lk.hasClassName('fewer')) {
          Favorites.show_more(block_id);
          lk.removeClassName('fewer');
          lk.writeAttribute('title','show fewer');
          lk.innerHTML = 'hide'; 
        }
        else {
          Favorites.show_fewer(block_id);
          lk.addClassName('fewer');
          lk.writeAttribute('title','show more');
          lk.innerHTML = 'see all'; 
        }
      });
    },
    show_more: function(block_id) {
      var thumbs = $$(block_id + ' .favorite-thumbs li');
      if (thumbs.length) {
        $(thumbs).each(function( item, itemidx ) {
          item.show();
        });
      }
    },
    show_fewer: function(block_id) {
      var thumbs = $$(block_id + ' .favorite-thumbs li');
      if (thumbs.length) {
        $(thumbs).each(function( item, itemidx ) {
          if (itemidx < Favorites.favorites_per_row) {
            item.show();
          }
          else {
            item.hide();
          }
        });
      }
    },
    execute_delete: function(ev) {
      var lnk = ev.target;
      var tp = lnk.readAttribute('fav_type');
      var id = lnk.readAttribute('fav_id');
      if (tp && id) {
        ev.stop();
        post_to_url('/users/remove_favorite', {fav_type: tp,fav_id: id} );
      }
    },
    execute_ajax_delete: function(ev) {
      var favid = this.readAttribute('fav_id');
      var favtype = this.readAttribute('fav_type');
      var parent = this.up();
      if (favid && favtype && confirm("Are you sure you want to remove this favorite?")) {
	var xhr = new Ajax.Request('/users/remove_favorite', 
                                   { method:'post',
                                     parameters: {fav_type: favtype,
                                                  fav_id: favid,
                                                  authenticityToken: authenticityToken,
                                                  format: 'json'},
			             onSuccess: function(tr) {
                                       var blk = parent.up('.favorites-block');
                                       parent.remove();
                                       blk.fire('favorite:removed');
			             }
			           });
      }
      ev.stop();
      return false;
    },
    show_delete: function(ev) {
      var delbtn = this.select('.delete-fav').first();
      if (delbtn && !delbtn.visible()) {
        delbtn.show();
      }
    },
    hide_delete: function(ev) {
      var delbtn = this.select('.delete-fav').first();
      if (delbtn && delbtn.visible()) {
        delbtn.hide();
      }
    }
  };
  
  Object.extend(FV,Favorites);
  Event.observe(window,'load', FV.init);

  M.BrowserDetect = Class.create();
  Object.extend(M.BrowserDetect.prototype, {
    initialize: function () {
      this._browser = Prototype.Browser;
      this.browser = this.searchString(this.dataBrowser) || 'unknown';
      this.version = this.searchVersion(navigator.userAgent) || 
        this.searchVersion(navigator.appVersion) || "an unknown version";
      this.OS = this.searchString(this.dataOS) || "an unknown OS";
    },
    searchString: function (data) {
      for (var i=0;i<data.length;i++)	{
	var dataString = data[i].string;
	var dataProp = data[i].prop;
	this.versionSearchString = data[i].versionSearch || data[i].identity;
	if (dataString) {
	  if (dataString.indexOf(data[i].subString) != -1) {
	    return data[i].identity;
          }
	}
	else if (dataProp) {
	  return data[i].identity;
        }
      }
      return null;
    },
    searchVersion: function (dataString) {
      var index = dataString.indexOf(this.versionSearchString);
      if (index == -1) { return null; }
      return parseFloat(dataString.substring(index+this.versionSearchString.length+1));
    },
    dataBrowser: [
      {
        string: navigator.userAgent,
        subString: "Chrome",
        identity: "Chrome"
      },
      {
        string: navigator.userAgent,
        subString: "OmniWeb",
        versionSearch: "OmniWeb/",
        identity: "OmniWeb"
      },
      {
        string: navigator.vendor,
        subString: "Apple",
        identity: "Safari",
        versionSearch: "Version"
      },
      {
        prop: window.opera,
        identity: "Opera"
      },
      {
        string: navigator.vendor,
        subString: "iCab",
        identity: "iCab"
      },
      {
        string: navigator.vendor,
        subString: "KDE",
        identity: "Konqueror"
      },
      {
        string: navigator.userAgent,
        subString: "Firefox",
        identity: "Firefox"
      },
      {
        string: navigator.vendor,
        subString: "Camino",
        identity: "Camino"
      },
      {	// for newer Netscapes (6+)
        string: navigator.userAgent,
        subString: "Netscape",
        identity: "Netscape"
      },
      {
        string: navigator.userAgent,
        subString: "MSIE",
        identity: "Explorer",
        versionSearch: "MSIE"
      },
      {
        string: navigator.userAgent,
        subString: "Gecko",
        identity: "Mozilla",
        versionSearch: "rv"
      },
      { // for older Netscapes (4-)
        string: navigator.userAgent,
        subString: "Mozilla",
        identity: "Netscape",
        versionSearch: "Mozilla"
      }
    ],
    dataOS : [
      {
        string: navigator.platform,
        subString: "Win",
        identity: "Windows"
      },
      {
        string: navigator.platform,
        subString: "Mac",
        identity: "Mac"
      },
      {
        string: navigator.userAgent,
        subString: "iPhone",
        identity: "iPhone/iPod"
      },
      {
        string: navigator.platform,
        subString: "Linux",
        identity: "Linux"
      }
    ]
  });
  Event.observe(window, 'load', function() {
    MAU.browser = new M.BrowserDetect(); 
  });

  var D = M.Discount = M.Discount || {};
  
  Object.extend(D, {
    init: function() {
      // for test page
      var $btn = $('process_markdown_btn');
      if ($btn) {
        $btn.observe('click', function() {
          var markdown = $('input_markdown');
          if (!markdown) {
            // try as a class
            markdown = $$('.input-markdown');
            if (markdown && markdown.length) {
              markdown = markdown[0];
            }
          }
          if (!markdown) {
            markdown = '## no markdown to process';
          }
          
          var params = {
            markdown: markdown.getValue(),
            authenticity_token:unescape(authenticityToken)
          };

          var xhr = new Ajax.Request('/discount/markup', { 
            method:'post',
            parameters: params,
	    onSuccess: function(tr) {
              $('processed_markdown').innerHTML = tr.responseText;
	    },
            onFailure: function(tr) {
              $('processed_markdown').innerHTML = "Failed to process your markdown";
            }
          });
        });
      }
    }
  });
  Event.observe(window, 'load', D.init);    
  
  var E = M.Events = M.Events || {};
  E.init = function() {
    $$('.event_nav .by_month').each(function(nav_el) {
      nav_el.observe('click', function(el) {
        $$('.event_nav .by_month').each(function(el) { el.removeClassName('current'); });
        this.addClassName('current');
        
        $$('.event_list .events_by_month').each(function(el) { 
          el.removeClassName('current');
        });

        $$('.event_list .events_by_month.'+ this.data('viskey')).each(function(el) { 
          el.addClassName('current');
        });
      });
    });
  };
  Event.observe(window,'load',E.init);

  var IM = M.ImageZoom = M.ImageZoom || {};
  IM.init = function() {
  };
  Event.observe(window,'load',IM.init);
}



)();



