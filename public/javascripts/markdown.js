MAU = window['MAU'] || {};
(function() {
    var D = MAU.Discount = MAU.Discount || {};

    Object.extend(D, {
        init: function() {
            // for test page
            $('process_markdown_btn').observe('click', function() {
                var params = {
                    markdown: $('input_markdown').getValue('value')
                };
	        new Ajax.Request('/discount/markup', { 
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
    });
    Event.observe(window, 'load', D.init);    
})();