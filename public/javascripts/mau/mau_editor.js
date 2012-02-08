/*  cms methods */
var MAUEdit = {
  init: function () {
    $$(".markdown.editable").each(
      function(el) {
        var edit_indicator = new Element('div', {'class':'edit_indicator'});
        edit_indicator.innerHTML = 'edit me';
        edit_indicator.observe('click', function() {
          window.open('/cms_documents/' + el.data('cmsid') + '/edit');
        });
        el.insert(edit_indicator);
        el.hover(
          function(ev) { 
            var item = el;
            $(item).addClassName('active');
          },
          function(ev) { 
            var item = el;
            $(item).removeClassName('active'); 
          }
        );
      });
  }
};

Event.observe(window,'load',MAUEdit.init);
