MAU = window.MAU = window.MAU || {}
MAU.TagMediaHelper = class TagMediaHelper
  constructor: (items, type, renderLink, linkOptions) ->
    @items = _.flatten([items])
    @type = type
    @renderLink = renderLink || false
    @linkOptions = linkOptions || {}

  path_prefix: () ->
    switch(@type)
      when 'medium' then '/media/'
      when 'tag' then '/art_piece_tags/'

  _format_item: (item, pfx) ->
    try
      linkopts = @linkOptions || {}
      return '' if (!item.id)
      if @renderLink
        linkopts.href = pfx + item.id
        jQuery('<a>', linkopts).html(item.name)
      else
        item.name
    catch e
      MAU.log(e)
      null

  format: () ->
    strs = []
    path_prefix = @path_prefix()
    for item in @items
      strs.push @._format_item(item, path_prefix) if item
    strs
