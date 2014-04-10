MAU = window.MAU = window.MAU || {}
MAU.GetInvolved = class GetInvolved

  TOGGLELNK_SUFFIX = '_toggle_lnk';
  NTRUNC = TOGGLELNK_SUFFIX.length;
  ITEMS = ['volunteer','donate','emaillist',
             'suggest','shop','venue','business'];

  _giToggle: (it) ->
    "gi_"+it+"toggle"
  _giToggleLink: (it) ->
    "gi_"+it+"_toggle_lnk"
  _giDiv: (it) ->
    "gi_"+it
  _giLnk2Div: (lnk) ->
    lnk.substr(0,lnk.length - NTRUNC);

  showSection: (s) ->
    items = jQuery('div.gi a');
    for tg in items
      if (tg)
        s2 = @_giLnk2Div(tg.id);
        dv = jQuery('#' + s2);
        if (dv)
          if (!dv.is(':visible'))
            if (s && s2 && (s == s2))
              dv.slideDown()
          else
            dv.slideUp()

  constructor: () ->
    showSection = (ev) =>
      t = ev.currentTarget
      ev.preventDefault()
      s = @_giLnk2Div(t.id)
      @showSection(s);

    # pick out special items
    # shop -> cafe press
    # email -> mailto:
    specialCases = ['shop'];

    jQuery('div.open-close-div a').bind 'click', showSection
    jQuery('div.content-block form').bind('submit', @validateEmailComment )

    cbx = jQuery('.content-block #feedback_comment')
 

  validateEmailComment: (ev) ->
    form = ev.currentTarget
    jQuery(form).find('#feedback_email, #feedback_name').each () ->
      $this = jQuery(this)
      if (this.id == 'feedback_email') && !MAU.Utils.validateEmail($this.val())
        alert("Please enter a valid email address.")
        ev.preventDefault()
        false
      true


jQuery () ->
  if (/involved/.match location.href )
    new MAU.GetInvolved()

