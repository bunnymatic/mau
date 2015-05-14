// /*
// for all elements with 'send-mau-a-note' class, popup a form to fill
// out the appropriate info and fire off a note to mau emails

// avoids 'mailto' links
// */

// var MAU = window.MAU = window.MAU || {};

// var FormConstructors = function() {

//   var renderForm = function(formId) {
//     var helpForm = document.getElementById(formId);
//     if (helpForm) {
//       return helpForm.innerHTML;
//     }
//     else {
//       return '';
//     }
//   }

//   this.types = ['inquiry', 'feed_submission', 'help'];

//   this.inquiry = {
//     title: 'General Inquiry',
//     render: function() { return renderForm('feedback-inquiry'); }
//   };

//   this.feed_submission = {
//     title: "Art Feeds",
//     render: function() { return renderForm('feedback-feed-submission'); }
//   };

//   this.help = {
//     title: "Help!",
//     render: function() { return renderForm('feedback-help'); }
//   };
// }

// MAU.NotesMailer = (function() {
//   function NotesMailer(selector, opts) {
//     this.options = _.extend({},this.defaults, opts)
//     this.selector = jQuery(selector);
//     if (this.options.note_class in this.form_builders) {
//       var _that = this;
//       jQuery(this.selector).bind('click', function(ev) {
//         _that.insert(ev);
//       });
//     }
//   }
//   return NotesMailer;
// })();

// _.extend(MAU.NotesMailer.prototype,{
//   defaults: {
//     url: '/email'
//   },
//   form_builders: new FormConstructors(),
//   selector: null,
//   _parent_class: function(selector) {
//     if (selector) {
//       return '.send-mau-a-note.mau-notes-container-' + this.options.note_class;
//     } else {
//       return 'send-mau-a-note mau-notes-container-' + this.options.note_class;
//     }
//   },
//   close: function(ev) {
//     if(ev && ev.preventDefault) { ev.preventDefault(); }
//     jQuery(this._parent_class(true)).fadeOut(300, function() {
//       jQuery(this).remove();
//     });
//   },
//   insert: function(ev) {
//     var browser = new MAU.BrowserDetect()
//     var xpos = 0, ypos = 0;
//     if (ev) {
//       xpos = ev.clientX;
//       ypos = ev.clientY;
//     }
//     var _that = this;
//     if (jQuery(_that._parent_class(true)).length === 0 ) {
//       var note_class = _that.options.note_class;
//       var formbuilder = _that.form_builders[note_class];
//       var inner = '';
//       if (formbuilder.render) {
//         inner = formbuilder.render();
//       }
//       var $f = jQuery('<form>', { method: 'post', "data-remote": 'true', action: _that.options.url });
//       $f.append(jQuery('<input>', { name: 'authenticity_token',
//                                     type: 'hidden',
//                                     value: unescape(authenticityToken) }));
//       $f.append(jQuery('<input>', { name: 'feedback_mail[note_type]',
//                                     type: 'hidden',
//                                     value: _that.options.note_class }));
//       $f.append(jQuery('<input>', { name: 'feedback_mail[browser]',
//                                     type: 'hidden',
//                                     value: browser.browser + ' ' + browser.version }));
//       $f.append(jQuery('<input>', { name: 'feedback_mail[operating_system]',
//                                     type: 'hidden',
//                                     value: browser.OS }));
//       $f.append(inner);
//       $f.bind('ajax:error', function(ev,xhr,status) {
//         jQuery('li').removeClass('fieldWithErrors');
//         var errorFields = xhr.responseJSON.errors;
//         if (errorFields) {
//           var fieldNames = _.keys(errorFields);
//           var ii = 0;
//           var nn = fieldNames.length;
//           for (;ii < nn; ++ii) {
//             var finder = "#feedback_mail_" + fieldNames[ii];
//             jQuery(finder).closest('li').addClass('fieldWithErrors');
//           }
//         }
//       });
//       $f.bind('ajax:success', function(ev,xhr,status) {
//         _that.close()
//       });
//       var $h = jQuery('<div>', { "class": 'popup-hdr' }).html( formbuilder.title );
//       var $x = jQuery('<div>', { "class": 'popup-close' }).html('x');
//       $h.append($x);
//       $x.bind('click', function(ev) { _that.close(ev); });

//       var $c = jQuery('<div>', { "class": 'popup-text' });
//       var $m = jQuery('<div>', { "class": 'popup-mailer' });
//       $m.append($h);
//       $m.append($c);
//       $c.append($f);
//       var $notes = jQuery('<div>', { "class": _that._parent_class() }).append($m);
//       jQuery('body').append($notes);

//       xx = xpos-250;
//       yy = ypos;
//       if (_that.options.note_class == 'feed_submission') {
//         _that.options.xoffset += 250;
//       }
//       if (_that.options.xoffset) {
//         xx += _that.options.xoffset;
//       }
//       if (_that.options.yoffset) {
//         yy += _that.options.yoffset;
//       }
//       xx = (xx < 20) ? 20 : xx;
//       var style = { left: '' + xx + 'px',
//                     top: ''+ yy + 'px' };
//       if (_that.options.note_class == 'feed_submission') {
//           style.bottom = ''+$notes.height() + 'px';
//           style.top = null;
//       }
//       $notes.css(style);
//     }
//   },
// });


// jQuery(function() {
//   jQuery('.mau-note-link').each(function(idx, note) {
//     var noteClass = jQuery(note).data('notetype');
//     new MAU.NotesMailer(note,
//                         { note_class: noteClass,
//                           url: "/main/notes_mailer" });
//   });
// });
