var MauPrototypeExtensions = {
  firstParentByTagName: function(el, tagname){
    el = $(el);
    var entry = null;
    var parents = el.ancestors();
    var ii = 0;
    var n = parents.length;
    var tagMatch = tagname.toUpperCase();
    for (; ii < n; ++ii ) {
      var p = parents[ii];
      if (p.tagName === tagMatch) {
        return p;
      }
    }
    return null;
  }
};

Element.addMethods(MauPrototypeExtensions);