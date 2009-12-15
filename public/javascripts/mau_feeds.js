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
	    }
	});
	MAUFEEDS.init = function(){}
    }

    Event.observe(window, 'load', MAUFEEDS.init);
}
)();

