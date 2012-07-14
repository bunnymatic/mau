beforeEach(function() {
  this.addMatchers({
    /** 
    toBePlaying: function(expectedSong) {
      var player = this.actual;
      return player.currentlyPlayingSong === expectedSong && 
             player.isPlaying;
    }
    **/
  });
});

var jasmine = jasmine || {}
jasmine.get_events = function(sel, event_name) {
  var events = [];
  try {
    var evs = $$(sel)[0].getStorage().get('prototype_event_registry');
    events = evs.get(event_name);
  } 
  catch(e) {}
  return events; 
};

jasmine.get_click_events = function(sel) {
  return this.get_events(sel, 'click');
};

var authenticityToken = 'faux_auth_token';