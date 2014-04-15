/*
for all elements with 'send-mau-a-note' class, popup a form to fill
out the appropriate info and fire off a note to mau emails

avoids 'mailto' links
*/

MAU.NotesMailer = Class.create();
var FormConstructors = function() {

  this.types = ['inquiry', 'feed_submission', 'help'];

  this.inquiry = {
    title: 'General Inquiry',
    render: function() {
      return document.getElementById('feedback-inquiry').innerHTML
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
}

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
    ev.preventDefault();
    jQuery(this._parent_class(true)).fadeOut(300, function() {
      jQuery(this).remove();
    });
  },
  insert: function(ev) {
    var browser = new MAU.BrowserDetect()
    var xpos = 0, ypos = 0;
    if (ev) {
      xpos = ev.clientX;
      ypos = ev.clientY;
    }
    var _that = this;
    if (jQuery(_that._parent_class(true)).length === 0 ) {
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
    this.options = _.extend({},this.defaults, opts)
    this.selector = jQuery(selector);
     if (this.options.note_class in this.form_builders) {
      var _that = this;
      jQuery(this.selector).bind('click', function(ev) {
        _that.insert(ev);
      });
    }
  }
});


jQuery(function() {
  jQuery('.mau-note-link').each(function(idx, note) {
    console.log('attach to ', note)
    var noteClass = jQuery(note).data('notetype');
    new MAU.NotesMailer(note,
                        { note_class: noteClass,
                          url: "/main/notes_mailer" });
  });
});
