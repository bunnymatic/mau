/*  cms methods */
var MAUEdit = {
  init: function () {
    $$(".markdown.editable").each(
      function(el) {
        var edit_indicator = new Element('div', {'class':'edit_indicator'});
        edit_indicator.innerHTML = 'edit me';
        edit_indicator.observe('click', function() {
          if (el.data('cmsid')) {
            window.open('/cms_documents/' + el.data('cmsid') + '/edit');
          } else {
            var page = el.data('page');
            var section = el.data('section');
            window.open('/cms_documents/new?doc[page]=' + page + '&doc[section]=' + section);
          }
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
