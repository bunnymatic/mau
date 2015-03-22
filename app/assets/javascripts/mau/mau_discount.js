var MAU = window.MAU = window.MAU || {};

jQuery(function() {
  // for test page
  jQuery('#process_markdown_btn').bind('click', function() {
    var markdown = jQuery('#input_markdown, #cms_document_article');
    var txt = markdown.val() || '## no markdown to process';
    var params = {
      markdown: txt,
      authenticity_token:unescape(authenticityToken)
    };
    jQuery('#processed_markdown').load('/admin/discount/markup', params)
  });

});
