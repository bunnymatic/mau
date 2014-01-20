var MAU = window.MAU = window.MAU || {};

jQuery(function() {
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

});
