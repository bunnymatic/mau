describe('MauNotes', function() {
  beforeEach(function() {
    loadFixtures('mau_notes.html');
    $$('.send-mau-a-note').each(function(el) {
      if (el) { el.remove(); }
    });
  });
  describe('initialize', function() {
    it ('nows how to get the parent class', function() {
      var sxn = 'inquiry';
      var m = new MAU.NotesMailer("#fixture", { note_class: sxn });
      expect(m._parent_class()).toEqual( 'send-mau-a-note mau-notes-container-inquiry');
    });
    it ('nows how to get the parent class as a selector', function() {
      var sxn = 'inquiry';
      var m = new MAU.NotesMailer("#fixture", { note_class: sxn });
      expect(m._parent_class(true)).toEqual( '.send-mau-a-note.mau-notes-container-inquiry');
    });
    it ("sets up help-me inputs", function() {
      var sxn = 'help';
      var m = new MAU.NotesMailer("#fixture .help-me", { note_class: sxn });
      var clickEvents = jasmine.get_click_events("#fixture .help-me");
      expect(clickEvents.length).toEqual(1);
    });
    it ("sets up feed inputs", function() {
      var sxn = 'feed_submission';
      var m = new MAU.NotesMailer("#fixture .feed-me", { note_class: sxn });
      var clickEvents = jasmine.get_click_events("#fixture .feed-me");
      expect(clickEvents.length).toEqual(1);
    });
    it ("sets up inquiry inputs", function() {
      var sxn = 'inquiry';
      var m = new MAU.NotesMailer("#fixture .general", { note_class: sxn });
      var clickEvents = jasmine.get_click_events("#fixture .general");
      expect(clickEvents.length).toEqual(1);
    });
    it ("fails to setup 'blah' inputs - not a valid note type", function() {
      var sxn = 'blah';
      var m = new MAU.NotesMailer("#fixture .blah", { note_class: sxn });
      var clickEvents = jasmine.get_click_events("#fixture .blah");
      expect(clickEvents.length).toEqual(0);
    });
    it ("sets up email notes", function() {
      var sxn = 'email_list';
      var m = new MAU.NotesMailer("#fixture .emailus", { note_class: sxn });
      var clickEvents = jasmine.get_click_events("#fixture .emailus");
      expect(clickEvents.length).toEqual(1);
    });
  });
  describe('submit', function() {
    var sxn = 'email_list';
    var m;
    beforeEach(function() {
      m = new MAU.NotesMailer("#fixture", { note_class: sxn, url: 'myurl'} );
      m.insert();
    });
    it ("has handler", function() {
      var sel = m._parent_class(true) + " form";
      var events = jasmine.get_events(sel, 'submit');
      expect(events.length).toEqual( 1);
    });
    it ("form contains authenticityToken", function() {
      var sel = m._parent_class(true) + " form";
      $$(sel).each(function(el) {
        expect($(el).select('input[name=authenticity_token]').length).toEqual( 1);
      });
    });
    it ("form contains note_type", function() {
      var sel = m._parent_class(true) + " form";
      input_names = jQuery(sel).find('input').map(function() { return this.name });
      expect( jQuery.inArray("feedback_mail[note_type]", input_names) ).toBeTruthy();
    });

  });
  describe("close button", function() {
    var sxn = 'email_list';
    it ("sets up a close button with click handler", function() {
      var sxn = 'inquiry';
      var m = new MAU.NotesMailer("#fixture", { note_class: sxn });
      m.insert();
      var clickEvents = jasmine.get_click_events(m._parent_class(true) + " .close-btn");
      expect(clickEvents.length).toEqual(1);
    });
  });
  describe("close method", function() {
    var m;
    var sxn = 'inquiry';
    beforeEach(function() {
      m = new MAU.NotesMailer("#fixture", { note_class: sxn, url: 'myurl'} );
      m.insert();
      m.close({stopPropagation:function() { return true;}});
    });
    it ("form gets hidden", function() {
      expect($$('#fixture form').length).toEqual(0);
    });
  });
  describe("insert (on click)", function() {
    describe("email_list", function() {
      var sxn = 'email_list';
      var m;
      beforeEach(function() {
        m = new MAU.NotesMailer("#fixture", { note_class: sxn, url: 'myurl'} );
        m.insert();
      });
      it ("adds the popup-mailer container", function() {
        expect($$(m._parent_class(true) + ' .popup-mailer').length).toEqual( 1);
      });
      it ("adds 2 email inputs", function() {
        expect($$(m._parent_class(true) + ' .popup-mailer .popup-content form input#email').length).toEqual( 1);
        expect($$(m._parent_class(true) + ' .popup-mailer .popup-content form input#email_confirm').length).toEqual( 1);
      });
      it ('has a submit button', function() {
        expect($$(m._parent_class(true) + ' .popup-mailer .popup-content form input[type=submit]').length).toEqual( 1);
      });
      it ('points to the right url', function() {
        expect($$(m._parent_class(true) + ' .popup-mailer .popup-content form[action=myurl]').length).toEqual(1);
      });
      it ('fills in the title', function() {
        expect($$('.popup-mailer .popup-header')[0].innerHTML.match('Join our mailing list')[0]).toEqual( 'Join our mailing list');
      });
      it ('has a close button', function() {
        expect($$('.popup-mailer .popup-header .close-btn').length).toEqual(1);
      });
    });
    describe("double insert", function() {
      var sxn = 'email_list';
      var m;
      beforeEach(function() {
        m = new MAU.NotesMailer("#fixture", { note_class: sxn, url: 'myurl'} );
        m.insert();
      });
      it ("doesn't add 2 of everything", function() {
        expect($$(m._parent_class(true) + ' .popup-mailer').length).toEqual( 1);
        expect($$(m._parent_class(true) + ' .popup-mailer .popup-content form input#email').length).toEqual( 1);
        expect($$(m._parent_class(true) + ' .popup-mailer .popup-content form input#email_confirm').length).toEqual( 1);
        expect($$(m._parent_class(true) + ' .popup-header .close-btn').length).toEqual(1);
      });
    });
    describe('feed submission', function() {
      var sxn = 'feed_submission';
      var m;
      beforeEach(function() {
        m = new MAU.NotesMailer("#fixture", { note_class: sxn, url: 'feeder'} );
        m.insert();
      });
      it ('has a close button', function() {
        expect($$('.popup-mailer .popup-header .close-btn').length).toEqual(1);
      });
      it ("adds the popup-mailer container", function() {
        expect($$(m._parent_class(true) + ' .popup-mailer').length).toEqual( 1);
      });
      it ('points to the right url', function() {
        expect($$(m._parent_class(true) + ' .popup-mailer form[action=feeder]').length).toEqual(1);
      });
      it ('fills in the title', function() {
        expect($$('.popup-mailer .popup-header')[0].innerHTML.match('Art Feeds')[0]).toEqual( 'Art Feeds');
      });
      it ('has a feedlink input', function() {
        expect($$(m._parent_class(true) + ' #feedlink').length).toEqual( 1);
      });
    });

    describe('help', function() {
      var sxn = 'help';
      var m;
      beforeEach(function() {
        m = new MAU.NotesMailer("#fixture", { note_class: sxn, url: 'help'} );
        m.insert();
      });
      it ('has a close button', function() {
        expect($$('.popup-mailer .popup-header .close-btn').length).toEqual(1);
      });
      it ("adds the popup-mailer container", function() {
        expect($$(m._parent_class(true) + ' .popup-mailer').length).toEqual( 1);
      });
      it ('points to the right url', function() {
        expect($$(m._parent_class(true) + ' .popup-mailer form[action=help]').length).toEqual(1);
      });
      it ('fills in the title', function() {
        expect($$('.popup-mailer .popup-header')[0].innerHTML.match('Help')[0]).toEqual( 'Help');
      });
    });
    describe("inquiry", function() {
      var sxn = 'inquiry';
      var m;
      beforeEach(function() {
        m = new MAU.NotesMailer("#fixture", { note_class: sxn, url: 'theurl'} );
        m.insert();
      });
      it ('has a close button', function() {
        expect($$('.popup-mailer .popup-header .close-btn').length).toEqual(1);
      });
      it ("adds the popup-mailer container", function() {
        expect($$(m._parent_class(true) + ' .popup-mailer').length).toEqual( 1);
      });
      it ('points to the right url', function() {
        expect($$(m._parent_class(true) + ' .popup-mailer form[action=theurl]').length).toEqual(1);
      });
      it ('fills in the title', function() {
        expect($$('.popup-mailer .popup-header')[0].innerHTML.match('General Inquiry')[0]).toEqual( 'General Inquiry');
      });
    });
    describe("both forms on same page", function() {
      var s1 = 'inquiry';
      var s2 = 'email_list';
      var m1;
      var m2;
      beforeEach(function() {
        m1 = new MAU.NotesMailer("#fixture .general", { note_class: s1, url: 'myurl'} );
        m2 = new MAU.NotesMailer("#fixture .emailus", { note_class: s2, url: 'myurl'} );
        m1.insert();
        m2.insert();
      });
      it("shows general form", function() {
        expect($$(m1._parent_class(true) +' .popup-mailer').length).toEqual(1);
      });
      it("shows email form", function() {
        expect($$(m2._parent_class(true) +' .popup-mailer').length).toEqual(1);
      });
    });
  });
});
