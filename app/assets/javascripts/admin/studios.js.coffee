$ ->
  if $('.admin.studios').length

    $("#js-studio-arranger tbody").sortable
      cursor: "move",
      start: (event, ui) ->
      update: (event, ui) ->
        studioIds = _.map( $(ui.item.context).closest('tbody').find('tr'), (row) ->
          $(row).data('studioId')
        )
        ajaxOpts =
          url: "/admin/studios/reorder"
          method: "POST"
          data:
            studios: studioIds
        $.ajax(ajaxOpts).done((data) ->
          (new MAU.Flash()).show({notice: "Studio Order has been updated", timeout: 2000});
        ).fail( (data) ->
          (new MAU.Flash()).show({error: "There was trouble updating the studio order"});
          $(ui.sender).sortable('cancel');
        )
