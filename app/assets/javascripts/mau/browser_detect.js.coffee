MAU = window.MAU = window.MAU || {}

MAU.BrowserDetect = class BrowserDetect
  constructor: ->
    @browser = @searchString(@dataBrowser) || 'unknown';
    @version = @searchVersion(navigator.userAgent) ||
    @searchVersion(navigator.appVersion) || "an unknown version";
    @OS = @searchString(this.dataOS) || "an unknown OS";

  searchString: (data) ->
    for item in data
      dataString = item.string
      dataProp = item.prop
      @versionSearchString = item.versionSearch || item.identity
      if (dataString)
        if (dataString.indexOf(item.subString) != -1)
          return item.identity
        else if (dataProp)
          return item.identity
    null
   searchVersion: (dataString) ->
      index = dataString.indexOf(@versionSearchString);
      return null if (index == -1)
      parseFloat(dataString.substring(index+@versionSearchString.length+1));

   dataBrowser: [
      string: navigator.userAgent,
      subString: "Chrome",
      identity: "Chrome"
    ,
      string: navigator.userAgent,
      subString: "OmniWeb",
      versionSearch: "OmniWeb/",
      identity: "OmniWeb"
    ,
      string: navigator.vendor,
      subString: "Apple",
      identity: "Safari",
      versionSearch: "Version"
    ,
      prop: window.opera,
      identity: "Opera"
    ,
      string: navigator.vendor,
      subString: "iCab",
      identity: "iCab"
    ,
      string: navigator.vendor,
      subString: "KDE",
      identity: "Konqueror"
    ,
      string: navigator.userAgent,
      subString: "Firefox",
      identity: "Firefox"
    ,
      string: navigator.vendor,
      subString: "Camino",
      identity: "Camino"
    ,
      # for newer Netscapes (6+)
      string: navigator.userAgent,
      subString: "Netscape",
      identity: "Netscape"
    ,
      string: navigator.userAgent,
      subString: "MSIE",
      identity: "Explorer",
      versionSearch: "MSIE"
    ,
      string: navigator.userAgent,
      subString: "Gecko",
      identity: "Mozilla",
      versionSearch: "rv"
    ,
      # for older Netscapes (4-)
      string: navigator.userAgent,
      subString: "Mozilla",
      identity: "Netscape",
      versionSearch: "Mozilla"
  ],
  dataOS : [
      string: navigator.platform,
      subString: "Win",
      identity: "Windows"
    ,
      string: navigator.platform,
      subString: "Mac",
      identity: "Mac"
    ,
      string: navigator.userAgent,
      subString: "iPhone",
      identity: "iPhone/iPod"
    ,
      string: navigator.platform,
      subString: "Linux",
      identity: "Linux"
  ]

