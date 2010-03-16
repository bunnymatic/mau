MAUFEEDS = window['MAUFEEDS'] || {};

(function() {
    /** all js init goes in here. **/

    MAUFEEDS.init = function() {
		var url = document.location.href;
		new Ajax.Request('/feeds/feed', {
			parameters: { authenticity_token:unescape(authenticityToken), numentries:1, page:url},
			onSuccess: function(transport) {
				var d = $('feed_div');
				d.innerHTML = transport.responseText;
				MAU.log("Got feeds");
				MAUFEEDS.stripStyles('feed_div');
			}
		});
		MAUFEEDS.init = function(){};
	};
	MAUFEEDS.stripStyles = function( feeddiv_id ) {
		MAU.log( "Strip");
		spans = $$('#'+feeddiv_id+" span");
		MAU.log( "spans " + spans.length);
		// clean style attributes from spans
		spans.each(function(sp){ sp.writeAttribute('style','');});
	};

    Event.observe(window, 'load', MAUFEEDS.init);
}
)();

