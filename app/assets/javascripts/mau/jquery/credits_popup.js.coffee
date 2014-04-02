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

    #M.CREDITS_BG = 'credits_bg';
    #M.CREDITS_BG_CONTAIN = 'credits_bg_contain';
    #M.CREDITS_DIV = 'credits_div';

    # init credits popup
    fq = document.getElementById(@creditsTriggerId)
    if (fq)
      jQuery(fq).on 'click',(ev) =>
        @clearExisting()
        ev.preventDefault()
        
        bg = MAU.Utils.createElement 'div',  id: @backgroundId 
        cn = MAU.Utils.createElement 'div',  id: @backgroundContainerId
        d = MAU.Utils.createElement 'div', id: @creditsDivId
        hd = MAU.Utils.createElement 'div', 'class':'credits-hdr'
        hd.innerHTML = 'Credits'
        bd = MAU.Utils.createElement('div', {'class':'credits-bdy'})
        version = MAU.versionString || 'Charger 6';
        bd.innerHTML = '<div style="text-align: center;">
          <p>Web Design/QA: Trish Tunney</p>
          <p>Web Construction: <a href="http://rcode5.com">Mr Rogers @ Rcode5 </a></p>
          <p><span style="padding-bottom:14px; ">Built at MAU Headquarters</p>
          </div>
          <div class="credits-img"><img width="350" src="/images/mau-headquarters-small.jpg"/></div>
          <div class="close_btn">click to close</div>
          <div class="release_version">Release: ' + version + '</div><div class="clear"></div>'

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

        # center 
        dimensions = MAU.Utils.getSize(d)
        
        w = dimensions.width;
        h = dimensions.height;

        windowSize = document.viewport.getDimensions()
        soff = document.viewport.getScrollOffsets();
        pw = windowSize.width + soff.left;
        ph = windowSize.height + soff.top;
        tp = '' + ((ph/2) - (h/2)) + "px";
        lft = '' + ((pw/2) - (w/2)) + "px";
        cn.style.top = tp;
        cn.style.left = lft;
        return false
      
jQuery ->
  new MAU.CreditsPopup()
