var MAU = window.MAU = window.MAU || {};
(function() {
  var N = MAU.Notifications = MAU.Notifications || {};

  N.ID_FORM = 'note_form';
  N.ID_OVERLAY = 'note_overlay';
  N.ID_MAIN = 'note_container';
  N.ID_CONTENT = 'note_modal_content';
  N.ID_MODAL_WINDOW = 'note_modal_window';
  N.ID_CLOSER = 'note_close_link';
  N.ID_CLOSE_BTN = 'note_close_btn';
  N.ID_COMMENT = 'comment';
  N.NOTEFORM_HTML = '<div id="' + N.ID_MAIN + '" style="display: none;">' +
    '<div id="' + N.ID_MODAL_WINDOW + '">' +
    '<a href="#" id="' + N.ID_CLOSER + '">x</a>' +
    '<div id="' + N.ID_CONTENT + '"></div>' +
    '</div></div>';
  N.OVERLAY_DIV = '<div id="'+N.ID_OVERLAY+'" class="note_hide"></div>';

  N.initOverlay = function() {
    if ($$('#' + N.ID_OVERLAY).length === 0) {
      $$("body").first().insert(N.OVERLAY_DIV);
    }
    $(N.ID_OVERLAY).addClassName('note_overlayBG');
  };

  N.showOverlay = function() {
    N.initOverlay();
    $(N.ID_OVERLAY).show();
  };

  N.hideOverlay = function() {
    if ($$('#' + N.ID_OVERLAY).length === 0) {
      return;
    }
    $(N.ID_OVERLAY).remove();
  };

  N.showNoteForm = function(ev) {
    var aid = this.readAttribute('aid');
    N.initOverlay();
    N.initNote(aid);
    $(N.ID_MAIN).show();
  };

  N.hideNote = function() {
    $(N.ID_MAIN).hide();
    $(N.ID_MAIN).remove();
    N.hideOverlay();
  };

  N.loading = function() {
    $(N.ID_CONTENT).innerHTML = "Loading...";
    $(N.ID_CONTENT).addClassName('note-loading');
  };

  N.submitNote = function(event){
    Event.stop(event);
    var form = $(N.ID_FORM);
    if (form) {
      var data = form.serialize(true);
      var url = form.action;
      N.loading('Sending...');
      var xhr = new Ajax.Updater(N.ID_CONTENT, url, {
        method: 'POST',
        parameters: data,
        onComplete: function(transport){
	        if (transport.status >= 200 && transport.status < 300) {
	          $(N.ID_MODAL_WINDOW).fade({
	            duration: 2.0,
	            afterFinish: function() { N.hideNote(); }
	          });
	        }
	        else {
	          var n = $(N.ID_FORM);
	          f.observe('submit', N.submitNote);
	          var closer = $(N.ID_CLOSE_BTN);
	          closer.observe('click', function(ev){
              ev.stopPropagation();
	            N.hideNote();
	            return false;
	          });
	        }
        }
      });
    }
  };

  N.initNote = function(aid) {
    if ($$('#' + N.ID_MAIN).length === 0) {
      $$("body").first().insert(N.NOTEFORM_HTML);
      var closer = $(N.ID_CLOSER);
      closer.observe('click', function(){
	      N.hideNote();
	      return false;
      });
      N.setWindowPosition();
      N.loading();
      var xhr = new Ajax.Updater(N.ID_CONTENT, '/users/' + aid + '/noteform',
		                             {
			                             method: 'get',
			                             onComplete: function(transport) {
			                               $(N.ID_CONTENT).removeClassName('note-loading');
                                     $(N.ID_FORM).focus_first();
			                               $(N.ID_FORM).observe('submit', N.submitNote);
			                               var b = $(N.ID_CLOSE_BTN);
			                               b.observe('click', function(ev){
                                       ev.stopPropagation();
			                                 N.hideNote();
			                                 return false;
			                               });
			                               MAU.addCommentBoxObserver($(N.ID_COMMENT));
			                             }
		                             });
    }
    return false;
  };

  N.setWindowPosition = function() {
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
    $(N.ID_MODAL_WINDOW).setStyle({
      top: (clientHeight / 10) + 'px'
    });
  };


  N.init = function() {
    var notes = $$('.notify-artist');
    var nnotes = notes.length;
    for (var ii = 0; ii < nnotes; ++ii) {
      var n = notes[ii];
      if (n) { n.observe('click', N.showNoteForm); }
    }
  };

  Event.observe(window,'load', N.init);
})();

