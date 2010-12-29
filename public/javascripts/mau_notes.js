/*
for all elements with 'send-mau-a-note' class, popup a form to fill
out the appropriate info and fire off a note to mau emails

avoids 'mailto' links
*/

MAU = window['MAU'] || {};

MAU.NotesMailer = Class.create();
MAU.browser = MAU.browser || {};
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
      new Element('label').update('Email'),
      new Element('div').insert(new Element('input', { type: 'text', id: 'email', name: 'email' })) ]);
    entries.push( [
      new Element('label').update('Confirm Email'),
      new Element('div').insert(new Element('input', { type: 'text', id: 'email_confirm', name: 'email_confirm' })) ]);
    entries.push( [
      new Element('label').update('Question'),
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

FormConstructors.feed_submission = {
  title: "Art Feeds",
  render: function() {
    var el = new Element('div');
    el.innerHTML = "Tell us about your favorite art related feed.  We'll check it out and if it stays current and is interesting, we'll add it to our list.";

    var inputs = new Element('ul');
    var entries = [];

    entries.push( [
      new Element('label').update('Feed Link'),
      new Element('div').insert(new Element('input', { type: 'text', id: 'feedlink', name: 'feedlink' })) ]);
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

FormConstructors.help = {
  title: "Help!",
  render: function() {
    var el = new Element('div');
    el.innerHTML = "Ack.  So sorry you're having issues.  Our developers are only human.  You may have found a bug in our system.  Please tell us what you were doing and what wasn't working.  We'll do our best to fix the issue and get you rolling as soon as we can.";

    var inputs = new Element('ul');
    var entries = [];

    entries.push( [
      new Element('label').update('Email'),
      new Element('div').insert(new Element('input', { type: 'text', id: 'email', name: 'email' })) ]);
    entries.push( [
      new Element('label').update('Confirm Email'),
      new Element('div').insert(new Element('input', { type: 'text', id: 'email_confirm', name: 'email_confirm' })) ]);
    entries.push( [
      new Element('label').update('Report your issue'),
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
  _parent_class: function(selector) {
    if (selector) {
      return '.send-mau-a-note.mau-notes-container-' + this.options.note_class;
    } else {
      return 'send-mau-a-note mau-notes-container-' + this.options.note_class;
    }
  },
  close: function(ev) {
    $$(this._parent_class(true)).each(function(el) {
      el.fade({duration:0.3, afterFinish: function() { el.remove(); }});
    });
    if (ev) {
      ev.stopPropagation();
    }
    return false;
  },
  insert: function(ev) {
    var xpos = ypos = 0;
    if (ev) {
      xpos = ev.pointerX();
      ypos = ev.pointerY();
    }
    var _that = this;
    if ($$(this._parent_class(true)).length == 0 ) {
      var note_class = _that.options.note_class;
      var formbuilder = _that.form_builders[note_class];
      var inner = '';
      if (formbuilder.render) {
        inner = $(formbuilder.render());
      }
      var f = new Element('form', { method: 'post', action: _that.options.url });
      $(f).insert(new Element('input', { name: 'authenticity_token', type: 'hidden', value: unescape(authenticityToken) }));
      $(f).insert(new Element('input', { name: 'note_type', type: 'hidden', value: _that.options.note_class }));
      $(f).insert(new Element('input', { name: 'browser', type: 'hidden', value: MAU.browser.browser + ' ' + MAU.browser.version }));
      $(f).insert(new Element('input', { name: 'operating_system', type: 'hidden', value: MAU.browser.OS }));
      $(f).insert(inner);
      $(f).observe('submit', function(ev) {
        if (formbuilder.submit) {
          formbuilder.submit();
        }
        f.request({onComplete: function() { _that.close(ev); }});
        ev.stop();
        return false;
      });
      var h = new Element('div', { "class": 'popup-header' }).update( formbuilder.title );
      var x = new Element('div', { "class": 'close-btn' }).update('x');
      h.insert(x);
      x.observe('click', function(ev) { _that.close(ev); });
      var c = new Element('div', { "class": 'popup-content' });
      var m = new Element('div', { "class": 'popup-mailer' });
      $(m).insert(h).insert(c);
      $(c).insert(f);
      var notes = new Element('div', { "class": _that._parent_class() }).insert(m);
      $$('body')[0].insert(notes);
      var style = { left: ''+(xpos-250) + 'px',
                    top: ''+ypos + 'px' };
      if (_that.options.note_class == 'feed_submission') {
          style['bottom'] = ''+notes.getHeight() + 'px';
          style['left'] = '' + (xpos-100) + 'px';
          style['top'] = null;
      }
      notes.setStyle(style);

    } else {
    }
  },
  initialize: function(selector, opts) {
    this.options = Object.extend({},this.defaults);
    this.options = Object.extend(this.options, opts);
    this.selector = selector;
    if (this.options.note_class in this.form_builders) {
      var _that = this;
      $$(this.selector).each(function(el) {
        $$(selector).each(function(root) {
            $(el).observe('click', function(ev) { _that.insert(ev); })
        });
      });
    };
  }
});





