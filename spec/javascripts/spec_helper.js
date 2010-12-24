// Use this file to require common dependencies or to setup useful test functions.

var get_events = function(sel, event_name) {
  var events = [];
  try {
    var evs = $$(sel)[0].getStorage().get('prototype_event_registry');
    events = evs.get(event_name);
  } 
  catch(e) {}
  return events; 
};

var get_click_events = function(sel) {
  return get_events(sel, 'click');
};

