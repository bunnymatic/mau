/* older IE's don't have trim function */
if (!String.prototype.trim) {
  String.prototype.trim = function() { return this.replace(/^\s\s*/, '').replace(/\s\s*$/, ''); };
}

/*
 *= require jquery
 *= require jquery_ujs
 *= require jquery_noconflict
 *= require jquery-ui-1.10.4.custom
 *= require jquery.spin
 *= require pickadate/picker
 *= require pickadate/picker.date
 *= require pickadate/picker.time
 *= require thirdparty/underscore.min.js
 *= require thirdparty/prototype/1.7/prototype.min
 *= require thirdparty/scriptaculous.all.min
 *= require thirdparty/event.simulate.js
 *= require thirdparty/prototype.feedback
 *= require thirdparty/autocomplete
 *= require jquery.flot
 *= require jquery.flot.resize
 *= require_tree ./mau
*/
