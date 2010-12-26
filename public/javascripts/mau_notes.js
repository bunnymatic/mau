/*
for all elements with 'send-mau-a-note' class, popup a form to fill
out the appropriate info and fire off a note to mau emails

avoids 'mailto' links
*/

MAU = window['MAU'] || {};

MAU.NotesMailer = Class.create();

var FormConstructors = {};

FormConstructors.inquiry = {
  title: 'General Inquiry',
  render: function() {
    var el = new Element('div');
    el.innerHTML = "We love to hear from you.  Please let us know your thoughts, questions, rants.  We'll do our best to respond in a timely manner.";
    /* var C = MAU.Cookie;
    C.init({name:'mau'});
    var c = C.getData('user_email');
*/
    $(el).insert({bottom:new Element('input', { type: 'text', id: 'email', name: 'email' })});
    $(el).insert({bottom:new Element('input', { type: 'text', id: 'email_confirm', name: 'email_confirm' })});
    $(el).insert({bottom:new Element('input', { type: 'textarea', id: 'inquiry', name: 'inquiry' })});
    $(el).insert({bottom:new Element('input', { type: 'submit', id: 'submit' })});
    return el;
  }
};

FormConstructors.email_list = {
  title: 'Join our mailing list',
  render: function() {
    var el = new Element('div');
    el.innerHTML = "Awesome!  We'll notify you of upcoming MAU events.  We hate spam just like you do so the only things you'll be apprised of will be great!  Enter your email twice below and we'll put you on the list.";
    $(el).insert({bottom:new Element('input', { type: 'text', id: 'email' })});
    $(el).insert({bottom:new Element('input', { type: 'text', id: 'email_confirm' })});
    $(el).insert({bottom:new Element('input', { type: 'submit', id: 'submit' })});
    return el;
  },
  submit: function() {
  }
};

Object.extend(MAU.NotesMailer.prototype, {
  defaults: {
    url: '/email'
  },
  form_builders: FormConstructors,
  selector: null,
  close: function(ev) {
    console.log(this);
    $$(this.selector + ' .' + this.options.note_class).each(function(el) {
      el.childElements().each(function(child) {
        $(child).remove();
      });
    });
    ev.stopPropagation();
    return false

  },
  insert: function() {
    var _that = this;
    $$(this.selector).each(function(el) {
      var note_class = _that.options.note_class;
      var clz = '.' + note_class;
      var subels = $(el).select(clz);
      $(subels).each( function(subel) {
        if (!$(subel).select('.popup-mailer').length) {
          var formbuilder = _that.form_builders[note_class];
          var inner = '';
          if (formbuilder.render) {
            inner = $(formbuilder.render());
          }
          var f = new Element('form', { method: 'post', action: _that.options.url });
          $(f).insert(inner);
          $(f).observe('submit', function() {
            if (formbuilder.submit) {
              formbuilder.submit();
            }
          });
          var h = new Element('div', { class: 'popup-header' }).update( formbuilder.title );
          var x = new Element('div', { class: 'close-btn' }).update('X');
          h.insert(x);
          x.observe('click', function(ev) { _that.close(ev); });
          var c = new Element('div', { class: 'popup-content' });
          var m = new Element('div', { class: 'popup-mailer' });
          $(m).insert(h).insert(c);
          $(c).insert(f);
          $(subel).insert(m);
        } else {
          return false;
        }
      });
    });
  },
  initialize: function(selector, opts) {
    this.options = Object.extend({},this.defaults);
    this.options = Object.extend(this.options, opts);
    this.selector = selector;
    if (this.options.note_class in this.form_builders) {
      var _that = this;
      $$(this.selector).each(function(el) {
        el.insert('<div class="' + _that.options.note_class +'">');
        $$(selector).each(function(root) {
          $(root).select("." + _that.options.note_class).each(function(notehead) {
            $(el).observe('click', function (){ 
              _that.insert(); 
            });
          });
        });
      });
    };
  }
});





