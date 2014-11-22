describe 'OsKeyGenerator', ->
  beforeEach ->
    loadFixtures 'open_studios_event_form.html'
    jQuery('#fixture input').val('')

  describe 'initialization', ->
    it 'sets the key if the start date is set', ->
      jQuery('#start_date').val('1 January 2012')
      new MAU.OsKeyGenerator jQuery('form.js-os-key-gen'),
        start_date_field: '#start_date'
        end_date_field: '#end_date'
        key_field: '#os_key'
      expect(jQuery('#fixture #os_key').val()).toEqual('201201')

    it 'does not set the key if start date is empty', ->
      new MAU.OsKeyGenerator jQuery('form.js-os-key-gen'),
        start_date_field: '#start_date'
        end_date_field: '#end_date'
        key_field: '#os_key'
      expect(jQuery('#fixture #os_key').val()).toEqual('')

    it 'does not set the key if start date is an invalid date', ->
      jQuery('#start_date').val('whatever, yo')
      new MAU.OsKeyGenerator jQuery('form.js-os-key-gen'),
        start_date_field: '#start_date'
        end_date_field: '#end_date'
        key_field: '#os_key'
      expect(jQuery('#fixture #os_key').val()).toEqual('')

