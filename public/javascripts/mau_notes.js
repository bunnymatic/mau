/*
for all elements with 'send-mau-a-note' class, popup a form to fill
out the appropriate info and fire off a note to mau emails

avoids 'mailto' links
*/

MAU = window['MAU'] || {};

MAU.NotesMailer = Class.create();
MAU.browser = MAU.browser || {};
var FormConstructors = {};

FormConstructors.login_required = {
  title: "Login Required", 
  render: function() {
    var el = new Element('div');
    var msg = new Element('div');
    msg.innerHTML = "Sorry, but you need to login first.";
    var msg2 = new Element('div');
    msg2.innerHTML = "Click <a href='/login'>here to login.</a>";
    el.insert(msg);
    el.insert(msg2);
    return el;
  }
};

FormConstructors.entrythingy = {
  title: 'Flax Show Submission Help',
  render: function() {
    var el = new Element('div');
    el.innerHTML = "Sorry you're having trouble.  Have you read the EntryThingy instructions?  If not, check those out and see if they answer your question.   If you've already read all that and are still having issues, tell us as much as you can about the specific problem and we'll do our best to help you out.";

    var inputs = new Element('ul');
    var entries = [];
    
    MAU.Cookie.init({name:'mau'});
    var email = MAU.Cookie.getData('email') || '';
    entries.push( [
      new Element('label').update('Email'),
      new Element('div').insert(new Element('input', { type: 'text', id: 'email', name: 'email', value: email})) ]);
    entries.push( [
      new Element('label').update('Confirm Email'),
      new Element('div').insert(new Element('input', { type: 'text', id: 'email_confirm', name: 'email_confirm', value: email })) ]);
    entries.push( [
      new Element('label').update('Describe the problem'),
      new Element('div').insert(new Element('textarea', { columns: 80, rows: 7, id: 'inquiry', name: 'inquiry' })) ]);
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

FormConstructors.inquiry = {
  title: 'General Inquiry',
  render: function() {
    var el = new Element('div');
    el.innerHTML = "We love to hear from you.  Please let us know your thoughts, questions, rants.  We'll do our best to respond in a timely manner.";

    var inputs = new Element('ul');
    var entries = [];
    
    MAU.Cookie.init({name:'mau'});
    var email = MAU.Cookie.getData('email') || '';
    entries.push( [
      new Element('label').update('Email'),
      new Element('div').insert(new Element('input', { type: 'text', id: 'email', name: 'email', value: email})) ]);
    entries.push( [
      new Element('label').update('Confirm Email'),
      new Element('div').insert(new Element('input', { type: 'text', id: 'email_confirm', name: 'email_confirm', value: email })) ]);
    entries.push( [
      new Element('label').update('Question'),
      new Element('div').insert(new Element('textarea', { columns: 80, rows: 7, id: 'inquiry', name: 'inquiry' })) ]);
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

FormConstructors.event_submission = {
  title: "My Art Show",
  login_required: true,
  render: function() {
    var el = new Element('div');
    el.innerHTML = "Tell us about your art show or event.  We'll help you plug it by posting it on our Facebook and Twitter.  Please give as much information as you can.";

    var inputs = new Element('ul');
    var entries = [];

    entries.push( [
      new Element('label').update('Title'),
      new Element('div').insert(new Element('input', { type: 'text', id: 'eventtitle', name: 'eventtitle' })) ]);
    entries.push( [
      new Element('label').update('Description'),
      new Element('div').insert(new Element('textarea', { rows: 7, id: 'eventdesc', name: 'eventdesc' })) ]);
    entries.push( [
      new Element('label').update('Time & Date'),
      new Element('div').insert(new Element('input', { type: 'text', id: 'eventtimedate', name: 'eventtimedate' })) ]);
    entries.push( [
      new Element('label').update('Venue Name'),
      new Element('div').insert(new Element('input', { type: 'text', id: 'eventvenuename', name: 'eventvenuename' })) ]);
    entries.push( [
      new Element('label').update('Venue Address'),
      new Element('div').insert(new Element('input', { type: 'text', id: 'eventaddress', name: 'eventaddress' })) ]);
    entries.push( [
      new Element('label').update('Event Website'),
      new Element('div').insert(new Element('input', { type: 'text', id: 'eventlink', name: 'eventlink' })) ]);
    entries.push( [
      new Element('label').update('Participating MAU Artists (comma separated list)'),
      new Element('div').insert(new Element('input', { type: 'text', id: 'eventartists', name: 'eventartists' })) ]);
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

    MAU.Cookie.init({name:'mau'});
    var email = MAU.Cookie.getData('email') || '';

    entries.push( [
      new Element('label').update('Email'),
      new Element('div').insert(new Element('input', { type: 'text', id: 'email', name: 'email', value: email})) ]);
    entries.push( [
      new Element('label').update('Confirm Email'),
      new Element('div').insert(new Element('input', { type: 'text', id: 'email_confirm', name: 'email_confirm', value: email })) ]);
    entries.push( [
      new Element('label').update('Report your issue'),
      new Element('div').insert(new Element('textarea', { columns: 80, rows: 7, id: 'inquiry', name: 'inquiry' })) ]);
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

    MAU.Cookie.init({name:'mau'});
    var email = MAU.Cookie.getData('email') || '';

    entries.push( [
      new Element('div').update('Email:'),
      new Element('div').insert(new Element('input', { type: 'text', id: 'email', name: 'email', value: email })) ]);
    entries.push( [
      new Element('div').update('Confirm Email:'),
      new Element('div').insert(new Element('input', { type: 'text', id: 'email_confirm', name: 'email_confirm', value: email })) ]);
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
      if (formbuilder.login_required && !_that.options.username) {
        formbuilder = _that.form_builders['login_required'];
      }
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
      xx = xpos-250;
      yy = ypos;
      if (_that.options.note_class == 'feed_submission') {
        _that.options.xoffset = -100;
      }
      if (_that.options.xoffset) {
        xx += _that.options.xoffset;
      }
      if (_that.options.yoffset) {
        yy += _that.options.yoffset;
      }
      var style = { left: '' + xx + 'px',
                    top: ''+ yy + 'px' };
      if (_that.options.note_class == 'feed_submission') {
          style['bottom'] = ''+notes.getHeight() + 'px';
          style['top'] = null;
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
        Event.observe(Element.extend(el), 'click', function(ev) { 
          _that.insert(ev); 
        });
      });
    };
  }
});





