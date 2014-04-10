var MAU = window.MAU = window.MAU || {};
(function() {
  var N = MAU.Notifications = MAU.Notifications || {};
  var ID_FORM = 'note_form';
  var ID_OVERLAY = 'note_overlay';
  var ID_MAIN = 'note_container';
  var ID_CONTENT = 'note_modal_content';
  var ID_MODAL_WINDOW = 'note_modal_window';
  var ID_CLOSER = 'note_close_link';
  var ID_CLOSE_BTN = 'note_close_btn';
  var ID_COMMENT = 'comment';
  var NOTEFORM_HTML = '<div id="' + ID_MAIN + '" style="display: none;">' +
    '<div id="' + ID_MODAL_WINDOW + '">' +
    '<a href="#" id="' + ID_CLOSER + '">x</a>' +
    '<div id="' + ID_CONTENT + '"></div>' +
    '</div></div>';
  var OVERLAY_DIV = '<div id="'+ID_OVERLAY+'" class="note_hide"></div>';

  jQuery.extend(N, {

    initOverlay: function() {
      var overlay = document.getElementById(ID_OVERLAY)
      if (!overlay) {
        jQuery('body').prepend(jQuery(OVERLAY_DIV).addClass("note_overlayBG"));
      }
    },
    showOverlay:function() {
      N.initOverlay();
      jQuery('#' + ID_OVERLAY).show();
    },
    hideOverlay : function() {
      var overlay = document.getElementById(ID_OVERLAY);
      if (!overlay) {
        return;
      }
      jQuery(overlay).remove();
    },
    showNoteForm : function(ev) {
      var aid = jQuery(this).attr('aid');
      N.initOverlay();
      N.initNote(aid);
      jQuery('#' + ID_MAIN).show();
    },
    hideNote : function() {
      var note = jQuery('#' + ID_MAIN);
      note.hide().remove();
      N.hideOverlay();
    },
    loading : function(msg) {
      var content = jQuery('#' + ID_CONTENT);
      content.html(msg || "Loading...").addClass('note-loading');
    },
    submitNote : function(ev){
      ev.preventDefault();
      var form = jQuery('#' + ID_FORM)
      if (form.length) {
        var data = form.serializeArray();
        var url = form.attr('action');
        N.loading('Sending...');
        var xhr = jQuery('#' + ID_CONTENT).load(
          url, data,
          function(response, status, xhr) {
	          if (status == 'success') {
	            jQuery('#' + ID_MODAL_WINDOW).fadeOut(function() { N.hideNote(); })
            }
          });
      }
    },
    initNote : function(aid) {
      if (!jQuery('#' + ID_MAIN).length) {
        jQuery("body").prepend(NOTEFORM_HTML);
        var closer = jQuery('#' + ID_CLOSER);
        closer.bind('click', function(ev){
          ev.preventDefault();
	        N.hideNote();
        });
        this.setWindowPosition();
        this.loading();
        jQuery('#' + ID_CONTENT).load('/users/' + aid + '/noteform',
                                        function(data,status,xhr) {
			                                    jQuery('#' + ID_CONTENT).removeClass('note-loading');
                                          jQuery('#' + ID_FORM).focusFirst();
			                                    jQuery('#' + ID_FORM).bind('submit', N.submitNote);
			                                    var b = jQuery('#' + ID_CLOSE_BTN);
			                                    b.bind('click', function(ev){
                                            ev.preventDefault();
			                                      N.hideNote();
			                                      return false;
			                                    });
                                        });


      }
      return false;
    },
    setWindowPosition : function() {
      var scrollTop, clientHeight;
      if (self.pageYOffset) {
        scrollTop = self.pageYOffset;
      } else if (document.documentElement && document.documentElement.scrollTop) { // Explorer 6 Strict
        scrollTop = document.documentElement.scrollTop;
      } else if (document.body) {// all other Explorers
        scrollTop = document.body.scrollTop;
      }
      if (self.innerHeight) {	// all except Explorer
        clientHeight = self.innerHeight;
      } else if (document.documentElement && document.documentElement.clientHeight) { // Explorer 6 Strict Mode
        clientHeight = document.documentElement.clientHeight;
      } else if (document.body) { // other Explorers
        clientHeight = document.body.clientHeight;
      }
      jQuery('#' + ID_MODAL_WINDOW).css({top: (clientHeight / 10) + 'px'});
    }
  });

})();

jQuery(function() {
  var notes = jQuery('.notify-artist');

  notes.bind('click', MAU.Notifications.showNoteForm);
});
