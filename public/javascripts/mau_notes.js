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
    var inputs = new Element('ul');
    var entries = [];

    entries.push( [
      new Element('div').update('Email:'),
      new Element('div').insert(new Element('input', { type: 'text', id: 'email', name: 'email' })) ]);
    entries.push( [
      new Element('div').update('Confirm Email:'),
      new Element('div').insert(new Element('input', { type: 'text', id: 'email_confirm', name: 'email_confirm' })) ]);
    entries.push( [
      new Element('div').update('Inquiry:'),
      new Element('div').insert(new Element('input', { type: 'textarea', id: 'inquiry', name: 'inquiry' })) ]);
    entries.push( [ new Element('input', {type: 'submit', value: 'send'}) ]);
    
    $(entries).each(function(entry) {
      var li = new Element('li');
      $(entry).each(function(chunk) {
        li.insert(chunk);
      });
      inputs.insert(li);
    });
    el.insert(inputs);
    return el;
  }
};

FormConstructors.email_list = {
  title: 'Join our mailing list',
  render: function() {
    var el = new Element('div');
    el.innerHTML = "Awesome!  We'll notify you of upcoming MAU events.  We hate spam just like you do so the only things you'll be apprised of will be great!  Enter your email twice below and we'll put you on the list.";

    var inputs = new Element('ul');
    var entries = [];

    entries.push( [
      new Element('div').update('Email:'),
      new Element('div').insert(new Element('input', { type: 'text', id: 'email', name: 'email' })) ]);
    entries.push( [
      new Element('div').update('Confirm Email:'),
      new Element('div').insert(new Element('input', { type: 'text', id: 'email_confirm', name: 'email_confirm' })) ]);
    entries.push( [ new Element('input', {type: 'submit', value: 'send'}) ]);
    
    $(entries).each(function(entry) {
      var li = new Element('li');
      $(entry).each(function(chunk) {
        li.insert(chunk);
      });
      inputs.insert(li);
    });
    el.insert(inputs);
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
  show: function() {
    $$(this.selector + ' .' + this.options.note_class).each(function(el) {
      //el.appear({duration:.3});
      el.show();
    });
  },
  close: function(ev) {
    $$(this.selector + ' .' + this.options.note_class).each(function(el) {
      //el.fade({duration:.3});
      el.hide();
    });
    if (ev) {
      ev.stopPropagation();
    }
    return false;
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
          $(f).insert(new Element('input', { name: 'authenticity_token', type: 'hidden', value: unescape(authenticityToken) }));
          $(f).insert(inner);
          $(f).observe('submit', function() {
            if (formbuilder.submit) {
              formbuilder.submit();
            }
            f.request({onComplete: _that.close});
          });
          var h = new Element('div', { class: 'popup-header' }).update( formbuilder.title );
          var x = new Element('div', { class: 'close-btn' }).update('x');
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
        el.insert(new Element('div', {style: 'display:none;', class: _that.options.note_class}));
        $$(selector).each(function(root) {
          $(root).select("." + _that.options.note_class).each(function(notehead) {
            _that.insert(); 
            $(el).observe('click', function() { _that.show(); });
          });
        });
      });
    };
  }
});





