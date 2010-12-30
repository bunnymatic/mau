MAUFEEDS = window['MAUFEEDS'] || {};

(function() {
  /** all js init goes in here. **/
  MAUFEEDS.requests = [];
  MAUFEEDS.init = function() {
    if ($('feed_div')) {
      var url = document.location.href;
      var req = new Ajax.Request('/feeds/feed', {
	parameters: { authenticity_token:unescape(authenticityToken), numentries:1, page:url},
	onSuccess: function(transport) {
	  var d = $('feed_div');
	  d.innerHTML = transport.responseText;
	  //MAU.log("Got feeds");
	  MAUFEEDS.stripStyles('feed_div');
	}
      });
      MAUFEEDS.requests.push(req);
    }
    MAUFEEDS.init = function(){};
  };
  MAUFEEDS.stripStyles = function( feeddiv_id ) {
    spans = $$('#'+feeddiv_id+" span");
    // clean style attributes from spans
    spans.each(function(sp){ sp.writeAttribute('style','');});
    
  };
  MAUFEEDS.abort_requests = function() {
    if (MAUFEEDS.requests.length > 0) {
      MAUFEEDS.requests.each(function(req) {
        if (req.abort) { req.abort(); }
      });
      MAUFEEDS.requests = [];
    }
  };

  Event.observe(window, 'load', MAUFEEDS.init);
  Event.observe(window, 'unload', MAUFEEDS.abort_requests);
}
)();

