/*
for all elements with 'send-mau-a-note' class, popup a form to fill
out the appropriate info and fire off a note to mau emails

avoids 'mailto' links
*/

MAU.NotesMailer = Class.create();
var FormConstructors = function() {

  var input_button = function(opts) {
    var o = _.extend(opts || {}, { "class": 'formbutton', type: 'submit', value: 'send' });
    return new Element('input', o);
  };

  var email_fields = function(email) {
    email = email || '';
    return(
      [
        new Element('label').update('Email'),
        new Element('div').insert(new Element('input', { type: 'text',
                                                         id: 'email',
                                                         name: 'feedback_mail[email]',
                                                         value: email})),
        new Element('label').update('Confirm Email'),
        new Element('div').insert(new Element('input', { type: 'text',
                                                         id: 'email_confirm',
                                                         name: 'feedback_mail[email_confirm]',
                                                         value: email })) ]
    );
  };

  this.types = ['inquiry', 'email_list', 'feed_submission', 'help'];

  this.inquiry = {
    title: 'General Inquiry',
    render: function() {
      var el = new Element('div');
      el.innerHTML = "We love to hear from you.  Please let us know your thoughts,"+
        " questions, rants.  We'll do our best to respond in a timely manner.";

      var inputs = new Element('ul');
      var entries = [];

      MAU.Cookie.init({name:'mau'});
      var email = MAU.Cookie.getData('email') || '';
      entries.push( email_fields() );
      entries.push( [
        new Element('label').update('Question'),
        new Element('div').insert(new Element('textarea', { columns: 80,
                                                            rows: 7,
                                                            id: 'inquiry',
                                                            name: 'feedback_mail[inquiry]' })) ]);
      entries.push( [ input_button() ] );

      $(entries).each(function(entry) {
        var li = new Element('li');
        $(entry).each(function(chunk) {
          li.insert(chunk);
        });
        inputs.insert(li);
      });
      el.insert(inputs);
      return $(el);
    }
  };

  this.feed_submission = {
    title: "Art Feeds",
    render: function() {
      return document.getElementById('feedback-feed-submission').innerHTML
    }
  };

  this.help = {
    title: "Help!",
    render: function() {
      return document.getElementById('feedback-help').innerHTML
    }
  };

  this.email_list = {
    title: 'Join our mailing list',
    render: function() {
      var el = new Element('div');
      el.innerHTML = "Awesome!  We'll notify you of upcoming MAU events.  "+
        "We hate spam just like you do so the only things you'll be apprised"+
        " of will be great!  Enter your email twice below and we'll put you "+
        "on the list.";

      var inputs = new Element('ul');
      var entries = [];

      MAU.Cookie.init({name:'mau'});
      var email = MAU.Cookie.getData('email') || '';
      entries.push( email_fields() );
      entries.push( [ input_button() ] );

      $(entries).each(function(entry) {
        var li = new Element('li');
        $(entry).each(function(chunk) {
          li.insert(chunk);
        });
        inputs.insert(li);
      });
      el.insert(inputs);
      return $(el);
    },
  };
};

Object.extend(MAU.NotesMailer.prototype, {
  defaults: {
    url: '/email'
  },
  form_builders: new FormConstructors(),
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
      if (el) {
        el.fade({duration:0.3, afterFinish: function() {
          if (el) {
            el.remove();
          }
        }});
      }
    });
    if (ev) {
      ev.stopPropagation();
    }
    return false;
  },
  insert: function(ev) {
    var browser = new MAU.BrowserDetect()
    var xpos = 0, ypos = 0;
    if (ev) {
      xpos = ev.pointerX();
      ypos = ev.pointerY();
    }
    var _that = this;
    if ($$(this._parent_class(true)).length === 0 ) {
      var note_class = _that.options.note_class;
      var formbuilder = _that.form_builders[note_class];
      var inner = '';
      if (formbuilder.render) {
        inner = formbuilder.render();
      }
      var f = new Element('form', { method: 'post', action: _that.options.url });
      $(f).insert(new Element('input', { name: 'authenticity_token',
                                         type: 'hidden',
                                         value: unescape(authenticityToken) }));
      $(f).insert(new Element('input', { name: 'feedback_mail[note_type]',
                                         type: 'hidden',
                                         value: _that.options.note_class }));
      $(f).insert(new Element('input', { name: 'feedback_mail[browser]',
                                         type: 'hidden',
                                         value: browser.browser + ' ' + browser.version }));
      $(f).insert(new Element('input', { name: 'feedback_mail[operating_system]',
                                         type: 'hidden',
                                         value: browser.OS }));
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
      xx = xpos-250;
      yy = ypos;
      if (_that.options.note_class == 'feed_submission') {
        _that.options.xoffset += 250;
      }
      if (_that.options.xoffset) {
        xx += _that.options.xoffset;
      }
      if (_that.options.yoffset) {
        yy += _that.options.yoffset;
      }
      xx = (xx < 20) ? 20 : xx;
      var style = { left: '' + xx + 'px',
                    top: ''+ yy + 'px' };
      if (_that.options.note_class == 'feed_submission') {
          style.bottom = ''+notes.getHeight() + 'px';
          style.top = null;
      }
      notes.setStyle(style);
    }
  },
  initialize: function(selector, opts) {
    this.options = Object.extend({},this.defaults);
    this.options = Object.extend(this.options, opts);
    this.selector = selector;
    if (this.options.note_class in this.form_builders) {
      var _that = this;
      $$(this.selector).each(function(el) {
        el.observe('click', function(ev) {
          _that.insert(ev);
          return false;
        });
      });
    }
  }
});
