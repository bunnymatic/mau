MAU = window.MAU || {};

var MauPrototypeExtensions = {
  firstParentByTagName: function(elem, tagname){
    var el = $(elem);
    var entry = null;
    var parents = el.ancestors();
    var ii = 0;
    var n = parents.length;
    var tagMatch = tagname.toUpperCase();
    for (; ii < n; ++ii ) {
      var p = parents[ii];
      if (p && (p.tagName === tagMatch)) {
        return p;
      }
    }
    return null;
  },
  hover: function(elem,infunc, outfunc) {
    if (!elem) { return; }
    var el = $(elem);
    el.observe('mouseover',infunc);
    el.observe('mouseout',outfunc);
  },
  html: function(elem, val) {
    if (!elem) {return;}
    elem.innerHTML = val;
  },
  data: function(elem, key, val) {
    var DATA_REGEX = /data-(\w+)/;
    var ii = 0;
    var nattr = elem.attributes.length;
    for (; ii < nattr; ++ii ) {
      var attr = elem.attributes[ii];
      if (attr && attr.name) {
        var m = attr.name.match(DATA_REGEX);
        if (m && m.length > 1) {
          var datakey = m[1];
          if (datakey === key) {
            if (val) {
              throw 'not ready to set values yet';
            }
            else {
              return attr.value;
            }
          }
        }
      }
    }
  }
};


Element.addMethods(MauPrototypeExtensions);