/*
for all elements with 'send-mau-a-note' class, popup a form to fill
out the appropriate info and fire off a note to mau emails

avoids 'mailto' links
*/

MAU = window['MAU'] || {};

MAU.NotesMailer = Class.create();

var constructEmailListMessage = function() {
  var el = new Element('div');
  el.innerHTML = "Awesome!  We'll notify you of upcoming MAU events.  We hate spam just like you do so the only things you'll be apprised of will be great!  Enter your email twice below and we'll put you on the list.";
  $(el).insert({bottom:new Element('input', { type: 'text', id: 'email' })});
  return el;
}

Object.extend(MAU.NotesMailer.prototype, {
  selector: null,
  note_class: null,
  notes: {
    email_list: constructEmailListMessage(), 
    inquiry: "<div>inquiry</div>"
  },
  insert: function() {
    var _that = this;
    $$(this.selector).each(function(el) {
      var clz = '.'+_that.note_class;
      var subels = $(el).select(clz);
      $(subels).each( function(subel) {
        var s = $(subel).insert('<div class="popup-mailer"></div>');
        $(s).insert(_that.notes[_that.note_class]);
      });
    });
  },
  initialize: function(selector, note_class) {
    this.selector = selector;
    this.note_class = note_class;
    var _that = this;
    $$(selector).each(function(el) {
      if (note_class in _that.notes) {
        el.insert('<div class="' + note_class +'">');
        $$(selector).each(function(root) {
          $(root).select("." + note_class).each(function(notehead) {
            $(notehead).observe('click', function (){ 
              _that.insert(); 
            });
          });
        });
      }
    });
  }
});





