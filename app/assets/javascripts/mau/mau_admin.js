jQuery(function() {

  jQuery('.js-hideable-rows').hideableRows()

  jQuery('#os_combo_link').bind('click', function() {
    var $frm = jQuery('#multi_form');
    $frm.slideToggle();
  });
  
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
