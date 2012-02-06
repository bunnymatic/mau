/*  cms methods */
var MAUEdit = {
  init: function () {
    $$(".markdown.editable").each(
      function(el) {
        var $el = $(el);
        var edit_indicator = new Element('div', {'class':'edit_indicator'});
        edit_indicator.innerHTML = 'edit me';
        el.insert(edit_indicator);
        $el.observe('click', function() {
          window.open('/cms_documents/' + $el.data('cmsid') + '/edit');
        });
        $el.hover(
          function(ev) { 
            var item = $el;
            $(item).addClassName('active');
          },
          function(ev) { 
            var item = $el;
            $(item).removeClassName('active'); 
            console.log('out page/section ', item.data('page'), item.data('section')); 
          }
        );
      });
  }
};

Event.observe(window,'load',MAUEdit.init);
