
MAUAdmin =  window['MAUAdmin'] || {};

(function() {
    var M = MAUAdmin;
    M.init = function() {
	$('update_artists').observe('click', function() {
	    var oss = $$('.os2010');
	    var cbs = $$('.cb2010');
	    var ii = 0;
	    var updates = {};
	    for ( ; ii < oss.length; ++ii ) {
		os = oss[ii];
		cb = cbs[ii];
		
		if ((os.innerHTML === 'true') !== (cbs[ii].checked)) {
		    updates["ARTIST"+os.readAttribute('artistid')] = (cbs[ii].checked).toString();
		}
	    }
	    var oss = $$('.osoct2010');
	    var cbs = $$('.cboct2010');
	    var ii = 0;
	    var updates = {};
	    for ( ; ii < oss.length; ++ii ) {
		os = oss[ii];
		cb = cbs[ii];
		
		if ((os.innerHTML === 'true') !== (cbs[ii].checked)) {
		    updates["ARTIST"+os.readAttribute('artistid')] = (cbs[ii].checked).toString();
		}
	    }
	    
	    
	    var form = new Element('form', {
                action: "/admin/artists/update",
                method: "post"
            });
	    form.appendChild(new Element('input', { type:"hidden", name:"authenticity_token", value:unescape(authenticityToken)}));
	    for (k in updates) {
		var val = updates[k];
		form.appendChild(new Element('input', { type:"hidden", name:k, value:val }));
	    }
	    document.body.appendChild(form);
	    form.submit();
	    return false;
	});
    };
    Event.observe(window,'load',M.init);
})();
