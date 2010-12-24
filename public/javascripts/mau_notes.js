/*
for all elements with 'send-mau-a-note' class, popup a form to fill
out the appropriate info and fire off a note to mau emails

avoids 'mailto' links
*/

MAU = window['MAU'] || {};

MAU.NotesMailer = Class.create();

Object.extend(MAU.NotesMailer.prototype, {
  notes: {
    email_list: "<div>email list</div",
    inquiry: "<div>inquiry</div>"
  },
  insert: function(selector, key) {
    var _that = this;
    $$(selector).each(function(el) {
      el.insert(_that[key]);
    });
  },
  initialize: function(selector, note_class) {
    var _that = this;
    $$(selector).each(function(el) {
      el.insert('<div class="' + note_class +'">');
      $$(selector).each(function(root) {
        $(root).select("." + note_class).each(function(notehead) {
          if (note_class in _that.notes) {
            $(notehead).observe('click', function (){ 
              _that.insert( _that.notes[note_class]); 
            });
          }
        });
      });
    });
  }
});





