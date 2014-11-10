describe('MauNotes', function() {
  var sxn = 'inquiry';
  var m;
  beforeEach(function() {
    jQuery('.send-mau-a-note').remove();
    loadFixtures('mau_notes.html');
  })
  afterEach(function() {
    jQuery('.send-mau-a-note').remove();
  });

  describe('initialize', function() {
    it ('nows how to get the parent class', function() {
      m = new MAU.NotesMailer("#fixture", { note_class: sxn });
      expect(m._parent_class()).toEqual( 'send-mau-a-note mau-notes-container-inquiry');
    });
    it ('nows how to get the parent class as a selector', function() {
      m = new MAU.NotesMailer("#fixture", { note_class: sxn });
      expect(m._parent_class(true)).toEqual( '.send-mau-a-note.mau-notes-container-inquiry');
    });
  });
  describe('submit', function() {
    beforeEach(function() {
      m = new MAU.NotesMailer("#fixture", { note_class: sxn, url: 'myurl'} );
      m.insert();
    });
    it ("form contains note_type", function() {
      var sel = m._parent_class(true) + " form";
      input_names = jQuery(sel).find('input').map(function() { return this.name });
      expect( jQuery.inArray("feedback_mail[note_type]", input_names) ).toBeTruthy();
    });

  });
  describe("close method", function() {
    beforeEach(function() {
      m = new MAU.NotesMailer("#fixture", { note_class: sxn, url: 'myurl'} );
      m.insert();
      m.close({stopPropagation:function() { return true;}});
    });
    it ("form gets hidden", function() {
      expect(jQuery('#fixture form').length).toEqual(0);
    });
  });
  describe("insert (on click)", function() {
    describe('feed submission', function() {
      beforeEach(function() {
        sxn = 'feed_submission';
        m = new MAU.NotesMailer("#fixture", { note_class: sxn, url: 'feeder'} );
        m.insert();
      });
      it ('has a close button', function() {
        expect(jQuery('.popup-mailer .popup-header .close-btn').length).toEqual(1);
      });
      it ("adds the popup-mailer container", function() {
        expect(jQuery(m._parent_class(true) + ' .popup-mailer').length).toEqual( 1);
      });
      it ('points to the right url', function() {
        expect(jQuery(m._parent_class(true) + ' .popup-mailer form[action=feeder]').length).toEqual(1);
      });
      it ('fills in the title', function() {
        expect(jQuery('.popup-mailer .popup-header')[0].innerHTML.match('Art Feeds')[0]).toEqual( 'Art Feeds');
      });
    });

    describe('help', function() {
      beforeEach(function() {
        sxn = 'help';
        m = new MAU.NotesMailer("#fixture", { note_class: sxn, url: 'help'} );
        m.insert();
      });
      it ('has a close button', function() {
        expect(jQuery('.popup-mailer .popup-header .close-btn').length).toEqual(1);
      });
      it ("adds the popup-mailer container", function() {
        expect(jQuery(m._parent_class(true) + ' .popup-mailer').length).toEqual( 1);
      });
      it ('points to the right url', function() {
        expect(jQuery(m._parent_class(true) + ' .popup-mailer form[action=help]').length).toEqual(1);
      });
      it ('fills in the title', function() {
        expect(jQuery('.popup-mailer .popup-header')[0].innerHTML.match('Help')[0]).toEqual( 'Help');
      });
    });
    describe("inquiry", function() {
      beforeEach(function() {
        sxn = 'inquiry'
        m = new MAU.NotesMailer("#fixture", { note_class: sxn, url: 'theurl'} );
        m.insert();
      });
      it ('has a close button', function() {
        expect(jQuery('.popup-mailer .popup-header .close-btn').length).toEqual(1);
      });
      it ("adds the popup-mailer container", function() {
        expect(jQuery(m._parent_class(true) + ' .popup-mailer').length).toEqual( 1);
      });
      it ('points to the right url', function() {
        expect(jQuery(m._parent_class(true) + ' .popup-mailer form[action=theurl]').length).toEqual(1);
      });
      it ('fills in the title', function() {

        expect(jQuery('.popup-mailer .popup-header')[0].innerHTML.match('General Inquiry')[0]).toEqual( 'General Inquiry');
      });
    });
    describe("both forms on same page", function() {
      var s1 = 'inquiry';
      var s2 = 'help';
      var m1;
      var m2;
      beforeEach(function() {
        m1 = new MAU.NotesMailer("#fixture .general", { note_class: s1, url: 'myurl'} );
        m2 = new MAU.NotesMailer("#fixture .help", { note_class: s2, url: 'myurl'} );
        m1.insert();
        m2.insert();
      });
      it("shows general form", function() {
        expect(jQuery(m1._parent_class(true) +' .popup-mailer').length).toEqual(1);
      });
      it("shows email form", function() {
        expect(jQuery(m2._parent_class(true) +' .popup-mailer').length).toEqual(1);
      });
    });
  });
});
