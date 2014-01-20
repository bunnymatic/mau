/*jslint bitwise: false*/
var urlDecode = function(str){
  str=str.replace(new RegExp('\\+','g'),' ');
  return unescape(str);
};
var urlEncode = function(str){
  str=escape(str);
  str=str.replace(new RegExp('\\+','g'),'%2B');
  return str.replace(new RegExp('%20','g'),'+');
};

var END_OF_INPUT = -1;

var base64Chars = [
  'A','B','C','D','E','F','G','H',
  'I','J','K','L','M','N','O','P',
  'Q','R','S','T','U','V','W','X',
  'Y','Z','a','b','c','d','e','f',
  'g','h','i','j','k','l','m','n',
  'o','p','q','r','s','t','u','v',
  'w','x','y','z','0','1','2','3',
  '4','5','6','7','8','9','+','/'
];

var reverseBase64Chars = [];
for (var i=0; i < base64Chars.length; i++){
  reverseBase64Chars[base64Chars[i]] = i;
}

var base64Str;
var base64Count;
var setBase64Str = function(str){
  base64Str = str;
  base64Count = 0;
};
var readBase64 = function(){
  if (!base64Str) {
    return END_OF_INPUT;
  }
  if (base64Count >= base64Str.length) {
    return END_OF_INPUT;
  }
  var c = (base64Str.charCodeAt(base64Count) & 0xff);
  base64Count++;
  return c;
};
var encodeBase64 = function(str){
  setBase64Str(str);
  var result = '';
  var inBuffer = [ null, null, null ];
  var lineCount = 0;
  var done = false;
  while (!done && (inBuffer[0] = readBase64()) != END_OF_INPUT){
    inBuffer[1] = readBase64();
    inBuffer[2] = readBase64();
    result += (base64Chars[ inBuffer[0] >> 2 ]);
    if (inBuffer[1] != END_OF_INPUT){
      result += (base64Chars[(( inBuffer[0] << 4 ) & 0x30) | (inBuffer[1] >> 4) ]);
      if (inBuffer[2] != END_OF_INPUT){
        result += (base64Chars[((inBuffer[1] << 2) & 0x3c) | (inBuffer[2] >> 6) ]);
        result += (base64Chars[inBuffer[2] & 0x3F]);
      } else {
        result += (base64Chars[((inBuffer[1] << 2) & 0x3c)]);
        result += ('=');
        done = true;
      }
    } else {
      result += (base64Chars[(( inBuffer[0] << 4 ) & 0x30)]);
      result += ('=');
      result += ('=');
      done = true;
    }
    lineCount += 4;
    if (lineCount >= 76){
      result += ('\n');
      lineCount = 0;
    }
  }
  return result;
};
var readReverseBase64 = function(){
  if (!base64Str) {
    return END_OF_INPUT;
  }
  while (true){
    if (base64Count >= base64Str.length) { return END_OF_INPUT; }
    var nextCharacter = base64Str.charAt(base64Count);
    base64Count++;
    if (reverseBase64Chars[nextCharacter]){
      return reverseBase64Chars[nextCharacter];
    }
    if (nextCharacter == 'A') {
      return 0;
    }
  }
  return END_OF_INPUT;
};

var ntos = function(n){
  n=n.toString(16);
  if (n.length == 1) { n="0"+n; }
  n="%"+n;
  return unescape(n);
};

var decodeBase64 = function(str){
  setBase64Str(str);
  var result = "";
  var inBuffer = [null,null,null,null];
  var done = false;
  while (!done && (inBuffer[0] = readReverseBase64()) != END_OF_INPUT &&
         (inBuffer[1] = readReverseBase64()) != END_OF_INPUT){
    inBuffer[2] = readReverseBase64();
    inBuffer[3] = readReverseBase64();
    result += ntos((((inBuffer[0] << 2) & 0xff)| inBuffer[1] >> 4));
    if (inBuffer[2] != END_OF_INPUT){
      result +=  ntos((((inBuffer[1] << 4) & 0xff)| inBuffer[2] >> 2));
      if (inBuffer[3] != END_OF_INPUT){
        result +=  ntos((((inBuffer[2] << 6)  & 0xff) | inBuffer[3]));
      } else {
        done = true;
      }
    } else {
      done = true;
    }
  }
  return result;
};

/*jslint bitwise: true*/

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
    MAU.Cookie.data[key] =value;
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
    return decodeBase64(unescape(document.cookie.substring(len, end)));
  },
  store: function() {
    var expires = '';

    if (MAU.Cookie.options.expires) {
      var today = new Date();
      expires = MAU.Cookie.options.expires * 86400000;
      expires = ';expires=' + new Date(today.getTime() + expires);
    }

    document.cookie = MAU.Cookie.options.name + '=' +
      escape(encodeBase64(Object.toJSON(MAU.Cookie.data))) +
      MAU.Cookie.getOptions() + expires;
  },
  erase: function() {
    document.cookie = MAU.Cookie.options.name + '=' +
      MAU.Cookie.getOptions() + ';expires=Thu, 01-Jan-1970 00:00:01 GMT';
  },
  getOptions: function() {
    return (MAU.Cookie.options.path ? ';path=' + MAU.Cookie.options.path : '') +
      (MAU.Cookie.options.domain ? ';domain=' + MAU.Cookie.options.domain : '') +
      (MAU.Cookie.options.secure ? ';secure' : '');
  }
};
