$ ->
  $window = $(window);
  $window.on 'scroll', (ev) ->
    top = $window.scrollTop();
    $(".back-to-top").toggleClass('shown', top > 2000);
  $(".back-to-top").on 'click', () ->
    $('body,html').animate( { scrollTop: 0 }, 800);
    false;
