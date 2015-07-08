$ ->
  $window = $(window);
  $window.on 'scroll', (ev) ->
    top = $window.scrollTop();
    $(".back-to-top").toggleClass('shown', top > 2000);
    
