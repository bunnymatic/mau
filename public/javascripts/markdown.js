MAU = window['MAU'] || {};
(function() {
  var D = MAU.Discount = MAU.Discount || {};

  Object.extend(D, {
    init: function() {
      // for test page
      $('process_markdown_btn').observe('click', function() {
        var markdown = $('input_markdown');
        if (!markdown) {
          // try as a class
          markdown = $$('.input_markdown');
          if (markdown && markdown.length) {
            markdown = markdown[0];
          }
        }
        if (!markdown) {
          markdown = '## no markdown to process';
        }
          
        var params = {
          markdown: markdown
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