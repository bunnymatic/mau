MAUFEEDS = window.MAUFEEDS || {};

(function() {
  /* this get's called once with each page load - the endpoint only updates the cached filesystem version
     if it needs update */
  MAUFEEDS.requests = [];
  MAUFEEDS.init = function() {
    if ($('feed_div')) {
      var url = document.location.href;
      MAU.log("Hit Feed");
      var req = new Ajax.Request('/feeds/feed', {
	parameters: { authenticity_token:unescape(authenticityToken), numentries:1, page:url},
	onSuccess: function(transport) {}
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

