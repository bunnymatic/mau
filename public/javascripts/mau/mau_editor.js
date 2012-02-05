/*  cms methods */
var MAUEdit = {
  init: function () {
    $$(".markdown.editable").each(function(el) {
      console.log('hover on ' + el);
      $(el).hover(function(ev) { 
        var item = $(el);
        $(item).addClassName('active');
        console.log('in page/section ', item.data('page'), item.data('section')); 
      },
                  function(ev) { 
                    var item = $(el);
                    $(item).removeClassName('active'); 
                   console.log('out page/section ', item.data('page'), item.data('section')); 
                  }
                 );
    });
  }
};

Event.observe(window,'load',MAUEdit.init);
