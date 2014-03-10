(function() {

  autocompleter = null;
  Event.observe(window, 'load', function() {
    var artist_list_inp = $('event_artist_list');
    if (!artist_list_inp) { return; }
    artist_list_inp.observe('focus', function() {
      var options={
        script:'/artists/suggest?', // form elements tagged on the end
        varname:'input',
        valueSep: ', ',
        json:true,
        minchars:2,
        shownoresults:false,
        maxresults:10,
        callback: null
      };
      autocompleter=new AutoComplete('event_artist_list', options);
      return true;
    });
  });

})();
