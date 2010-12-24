MAU = window["MAU"] || {};
MAU.Cookie = {
  data: {},
  options: {expires: 1, domain: "", path: "", secure: false},
  
  init: function(options, data) {
    MAU.Cookie.options = Object.extend(MAU.Cookie.options, options || {});
    
    var payload = MAU.Cookie.retrieve();
    if(payload) {
      MAU.Cookie.data = payload.evalJSON();
    }
    else {
      MAU.Cookie.data = data || {};
    }
    MAU.Cookie.store();
  },
  getData: function(key) {
    return MAU.Cookie.data[key];
  },
  setData: function(key, value) {
    MAU.Cookie.data[key] = value;
    MAU.Cookie.store();
  },
  removeData: function(key) {
    delete MAU.Cookie.data[key];
    MAU.Cookie.store();
  },
  retrieve: function() {
    var start = document.cookie.indexOf(MAU.Cookie.options.name + "=");
    
    if(start == -1) {
      return null;
    }
    if(MAU.Cookie.options.name != document.cookie.substr(start, MAU.Cookie.options.name.length)) {
      return null;
    }
    
    var len = start + MAU.Cookie.options.name.length + 1;   
    var end = document.cookie.indexOf(';', len);
    
    if(end == -1) {
      end = document.cookie.length;
    } 
    return unescape(document.cookie.substring(len, end));
  },
  store: function() {
    var expires = '';
    
    if (MAU.Cookie.options.expires) {
      var today = new Date();
      expires = MAU.Cookie.options.expires * 86400000;
      expires = ';expires=' + new Date(today.getTime() + expires);
    }
    
    document.cookie = MAU.Cookie.options.name + '=' + escape(Object.toJSON(MAU.Cookie.data)) + MAU.Cookie.getOptions() + expires;
  },
  erase: function() {
    document.cookie = MAU.Cookie.options.name + '=' + MAU.Cookie.getOptions() + ';expires=Thu, 01-Jan-1970 00:00:01 GMT';
  },
  getOptions: function() {
    return (MAU.Cookie.options.path ? ';path=' + MAU.Cookie.options.path : '') + (MAU.Cookie.options.domain ? ';domain=' + MAU.Cookie.options.domain : '') + (MAU.Cookie.options.secure ? ';secure' : '');      
  }
};
