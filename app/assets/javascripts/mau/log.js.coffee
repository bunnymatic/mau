MAU = window.MAU = window.MAU || {};
# 
MAU.log = () ->
  if window.console && MAU.__debug__
    if console && console.log
      try 
        console.log arguments...
      catch e
        try
          msg = '';
          for args in arguments
            msg += arguments[i]
            console.log msg
        catch ee
          MAU.log = ->
