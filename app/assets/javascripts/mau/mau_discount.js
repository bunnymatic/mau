var MAU = (window.MAU = window.MAU || {});

jQuery(function() {
  var markItDown = function(textarea, output) {
    var markdown = $(textarea);
    var txt = markdown.val() || "## no markdown to process";
    var params = {
      markdown: txt
    };
    jQuery(output).load("/admin/discount/markup", params);
  };

  jQuery("#process_markdown_btn").bind("click", function() {
    markItDown("#input_markdown, #cms_document_article", "#processed_markdown");
  });

  jQuery("#cms_document_article").on("change", function() {
    MAU.Utils.debounce(
      function() {
        markItDown(
          "#input_markdown, #cms_document_article",
          "#processed_markdown"
        );
      },
      250,
      false
    )();
  });
});
