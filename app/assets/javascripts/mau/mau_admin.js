
MAUAdmin =  window.MAUAdmin || {};

(function() {
  Element.prototype.triggerEvent = function(eventName)
  {
    if (document.createEvent)
    {
      var evt = document.createEvent('HTMLEvents');
      evt.initEvent(eventName, true, true);

      return this.dispatchEvent(evt);
    }

    if (this.fireEvent) {
      return this.fireEvent('on' + eventName);
    }
  };

  var M = MAUAdmin;

  jQuery(function() {
    jQuery('.js-hideable-rows').hideableRows()
  });

  M.init = function() {

    var oscombo = $('os_combo_link');
    if (oscombo) {
        oscombo.observe('click', function() {
          var $frm = $('multi_form');
          if (!$frm.visible()) {
            $frm.slideDown();
          } else {
            $frm.slideUp();
          }
        });
    }

  };
  Event.observe(window,'load',M.init);

})();


jQuery(function() {
  jQuery('.add_btn').each(function() {
    jQuery(this).bind('click', function(ev) {
      ev.preventDefault();
      var $li = jQuery(this).closest('li');
      if ($li.length) {
        var $container = $li.find('.add_email');
        $container.slideToggle();
      }
      return false;
    });
  });


  jQuery('.del_btn').each(function() {
    jQuery(this).bind('click', function(ev) {
      var $this = jQuery(this);
      ev.preventDefault();
      var $li = $this.closest('li')
      var $ul = $this.closest('ul')
      // var li = $(btn).firstParentByTagName('li');
      // var ul = $(btn).firstParentByTagName('ul');
      if ($li && $ul) {
        var email = $li[0].firstChild.data.strip();
        var email_id = $li.attr('email_id');
        var listname = $ul.attr('list_type');
        if ( email && listname && email_id ) {
          if (confirm('Whoa Nelly!  Are you sure you want to remove ' + email + ' from the ' + listname + ' list?')) {
            var data_url = '/email_lists/' + email_id;
            var ajax_data = {
              url: data_url,
              method: 'delete',
              data: {
                authenticity_token:unescape(authenticityToken),
                listtype: listname
              },
              success: function(data,status,xhr) {
                $li.remove();
              }
            }
            jQuery.ajax(ajax_data)
          }
        }
      }
    });
  });
});
