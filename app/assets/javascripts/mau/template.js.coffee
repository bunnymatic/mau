class Template
  constructor: (templateId) ->
    @_id = templateId
  load: ->
    script = _.find $('body').find('script#'+@_id), (item) => $(item).attr('type') == 'template/html'
    @contents = (if script then script.innerHTML else '')
      
  interpolate: (data) ->
    if (data)
      for key, value of data
        value ||= ''
        @contents = @contents.replace("{{" + key + "}}", value)
    @contents    
  html: (data) ->
    @load()
    @interpolate(data)
  

MAU = MAU || window.MAU = window.MAU || {}
MAU.Template = Template
