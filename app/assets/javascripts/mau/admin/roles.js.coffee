MAUAdmin =  window.MAUAdmin || {};

jQuery ->
  ctrls = document.getElementById('role_mgr')
  if (ctrls)
    $ctrls = jQuery(ctrls)
    $btn = $ctrls.find('.add_userrole')
    $btn.bind 'click', ->
      $ctrls.find('form.js-hook').toggleClass 'hidden'
