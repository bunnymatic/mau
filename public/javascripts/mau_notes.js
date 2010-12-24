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
  $(el).insert({bottom:new Element('input', { type: 'text', id: 'email_confirm' })});
  $(el).insert({bottom:new Element('input', { type: 'submit', id: 'submit' })});
  return el;
};

Object.extend(MAU.NotesMailer.prototype, {
  defaults: {
    url: '/email'
  },
  selector: null,
  notes: {
    email_list: constructEmailListMessage(), 
    inquiry: "<div>inquiry</div>"
  },
  insert: function() {
    var _that = this;
    $$(this.selector).each(function(el) {
      var note_class = _that.options.note_class;
      var clz = '.' + note_class;
      var subels = $(el).select(clz);
      $(subels).each( function(subel) {
        var inner = $(_that.notes[note_class]);
        var f = new Element('form', { method: 'post', action: _that.options.url });
        $(f).insert(inner);
        var c = new Element('div', { class: 'popup-mailer' });
        $(c).insert(f);
        $(subel).insert(c);
      });
    });
  },
  initialize: function(selector, opts) {
    this.options = Object.extend(this.defaults,opts);
    this.selector = selector;
    var _that = this;
    $$(selector).each(function(el) {
      var note_class = _that.options.note_class;
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





