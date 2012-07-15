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
  findChildByTagName: function(elem, tagname) {
    var el = $(elem);
    var entry = null;
    var kids = el.descendants();
    var tagMatch = tagname.toUpperCase();
    var ii = 0, n = kids.length;
    for (; ii < n; ++ii ) {
      var kid = kids[ii];
      if (kid && kid.tagName == tagMatch) {
        return kid
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
  outerDimensions: function(elem) {
    if (!elem) {return;}
    var l = new Element.Layout(elem);
    return ({ width: Math.max(l.get('width'), l.get('border-box-width'), l.get('margin-box-width')),
             height: Math.max(l.get('height'), l.get('border-box-height'), l.get('margin-box-height'))
            });
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