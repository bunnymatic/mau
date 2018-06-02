// Generated by CoffeeScript 1.12.7
(function() {
  MAU = window.MAU = window.MAU || {};

  MAU.CreditsPopup =
    MAU.CreditsPopup ||
    (function() {
      CreditsPopup.prototype.clearExisting = function() {
        var bg, cn;
        bg = document.getElementById(this.backgroundId);
        cn = document.getElementById(this.backgroundContainerId);
        if (bg) {
          bg.parentNode.removeChild(bg);
        }
        if (cn) {
          return cn.parentNode.removeChild(cn);
        }
      };

      function CreditsPopup() {
        var fq;
        this.backgroundId = "credits_bg";
        this.backgroundContainerId = "credits_bg_contain";
        this.creditsDivId = "credits_div";
        this.creditsTriggerId = "credits_lnk";
        fq = document.getElementById(this.creditsTriggerId);
        if (fq) {
          jQuery(fq).on(
            "click",
            (function(_this) {
              return function(ev) {
                var bd, bg, body, cn, d, hd, version;
                _this.clearExisting();
                ev.preventDefault();
                bg = MAU.Utils.createElement("div", {
                  id: _this.backgroundId
                });
                cn = MAU.Utils.createElement("div", {
                  id: _this.backgroundContainerId
                });
                d = MAU.Utils.createElement("div", {
                  id: _this.creditsDivId
                });
                hd = MAU.Utils.createElement("div", {
                  class: "credits-hdr popup-header"
                });
                hd.innerHTML = "Credits";
                bd = MAU.Utils.createElement("div", {
                  class: "credits-bdy popup-text"
                });
                version = MAU.versionString || "Charger 6";
                bd.innerHTML =
                  '<div class="credits-img"><img class="pure-img" src="/images/mau-headquarters-small.jpg"/></div> <p>Built at MAU Headquarters by <a href="http://trishtunney.com">Trish Tunney</a> and <a href="http://rcode5.com">Mr Rogers.</a></p> <div class="close-btn popup-close"><i class="fa fa-close"></i></div> <div class="release_version">Release: ' +
                  version +
                  "</div>";
                if (d && hd && bd) {
                  d.appendChild(hd);
                  d.appendChild(bd);
                }
                jQuery(d).bind("click", function(ev) {
                  ev.preventDefault();
                  return _this.clearExisting();
                });
                cn.appendChild(d);
                body = document.body;
                body.insertBefore(bg, body.firstChild);
                body.insertBefore(cn, bg);
                return false;
              };
            })(this)
          );
        }
      }

      return CreditsPopup;
    })();

  jQuery(function() {
    return new MAU.CreditsPopup();
  });
}.call(this));
