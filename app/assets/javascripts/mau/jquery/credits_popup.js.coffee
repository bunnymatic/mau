MAU = window.MAU = window.MAU || {};
MAU.CreditsPopup = class CreditsPopup

  clearExisting: () ->
    bg = document.getElementById(@backgroundId)
    cn = document.getElementById(@backgroundContainerId)
    bg.parentNode.removeChild(bg) if bg
    cn.parentNode.removeChild(cn) if cn

  constructor: () ->
    @backgroundId = 'credits_bg'
    @backgroundContainerId = 'credits_bg_contain'
    @creditsDivId = 'credits_div'
    @creditsTriggerId = 'credits_lnk'

    # init credits popup
    fq = document.getElementById(@creditsTriggerId)
    if (fq)
      jQuery(fq).on 'click',(ev) =>
        @clearExisting()
        ev.preventDefault()

        bg = MAU.Utils.createElement 'div',  id: @backgroundId
        cn = MAU.Utils.createElement 'div',  id: @backgroundContainerId
        d = MAU.Utils.createElement 'div', id: @creditsDivId
        hd = MAU.Utils.createElement 'div', {'class':'credits-hdr popup-header'}
        hd.innerHTML = 'Credits'
        bd = MAU.Utils.createElement('div', {'class':'credits-bdy popup-text'})
        version = MAU.versionString || 'Charger 6';
        bd.innerHTML = '
          <div class="credits-img"><img width="350" src="/images/mau-headquarters-small.jpg"/></div>
          <p>Web Design/QA: Trish Tunney</p>
          <p>Web Construction: <a href="http://rcode5.com">Mr Rogers @ Rcode5 </a></p>
          <p>Built at MAU Headquarters</p>
          </div>
          <div class="close-btn popup-close"><i class="fa fa-close"></i></div>
          <div class="release_version">Release: ' + version + '</div>'

        if (d && hd && bd)
          d.appendChild(hd)
          d.appendChild(bd)
        jQuery(d).bind 'click', (ev) =>
          ev.preventDefault()
          @clearExisting();

        cn.appendChild(d)
        body = document.body
        body.insertBefore bg, body.firstChild
        body.insertBefore cn, bg

        return false

jQuery ->
  new MAU.CreditsPopup()
