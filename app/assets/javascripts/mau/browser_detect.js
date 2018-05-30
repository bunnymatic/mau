// Generated by CoffeeScript 1.12.7
(function() {
  var BrowserDetect, MAU;

  MAU = window.MAU = window.MAU || {};

  MAU.BrowserDetect = BrowserDetect = (function() {
    function BrowserDetect() {
      this.browser = this.searchString(this.dataBrowser) || "unknown";
      this.version =
        this.searchVersion(navigator.userAgent) ||
        this.searchVersion(navigator.appVersion) ||
        "an unknown version";
      this.OS = this.searchString(this.dataOS) || "an unknown OS";
    }

    BrowserDetect.prototype.searchString = function(data) {
      var dataProp, dataString, i, item, len;
      for (i = 0, len = data.length; i < len; i++) {
        item = data[i];
        dataString = item.string;
        dataProp = item.prop;
        this.versionSearchString = item.versionSearch || item.identity;
        if (dataString) {
          if (dataString.indexOf(item.subString) !== -1) {
            return item.identity;
          } else if (dataProp) {
            return item.identity;
          }
        }
      }
      return null;
    };

    BrowserDetect.prototype.searchVersion = function(dataString) {
      var index;
      index = dataString.indexOf(this.versionSearchString);
      if (index === -1) {
        return null;
      }
      return parseFloat(
        dataString.substring(index + this.versionSearchString.length + 1)
      );
    };

    BrowserDetect.prototype.dataBrowser = [
      {
        string: navigator.userAgent,
        subString: "Chrome",
        identity: "Chrome"
      },
      {
        string: navigator.userAgent,
        subString: "OmniWeb",
        versionSearch: "OmniWeb/",
        identity: "OmniWeb"
      },
      {
        string: navigator.vendor,
        subString: "Apple",
        identity: "Safari",
        versionSearch: "Version"
      },
      {
        prop: window.opera,
        identity: "Opera"
      },
      {
        string: navigator.vendor,
        subString: "iCab",
        identity: "iCab"
      },
      {
        string: navigator.vendor,
        subString: "KDE",
        identity: "Konqueror"
      },
      {
        string: navigator.userAgent,
        subString: "Firefox",
        identity: "Firefox"
      },
      {
        string: navigator.vendor,
        subString: "Camino",
        identity: "Camino"
      },
      {
        string: navigator.userAgent,
        subString: "Netscape",
        identity: "Netscape"
      },
      {
        string: navigator.userAgent,
        subString: "MSIE",
        identity: "Explorer",
        versionSearch: "MSIE"
      },
      {
        string: navigator.userAgent,
        subString: "Gecko",
        identity: "Mozilla",
        versionSearch: "rv"
      },
      {
        string: navigator.userAgent,
        subString: "Mozilla",
        identity: "Netscape",
        versionSearch: "Mozilla"
      }
    ];

    BrowserDetect.prototype.dataOS = [
      {
        string: navigator.platform,
        subString: "Win",
        identity: "Windows"
      },
      {
        string: navigator.platform,
        subString: "Mac",
        identity: "Mac"
      },
      {
        string: navigator.userAgent,
        subString: "iPhone",
        identity: "iPhone/iPod"
      },
      {
        string: navigator.platform,
        subString: "Linux",
        identity: "Linux"
      }
    ];

    return BrowserDetect;
  })();
}.call(this));
