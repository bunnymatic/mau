# frozen_string_literal: true
puts 'Server Timezone: %s' % Rails.configuration.time_zone
# try with ruby 1.8.7/1.9.2
# try with different rails apps timezones
springtime = '04/25/2013 1:30PM'
falltime = '11/12/2013 2:40PM'
# maybe print the app timezone here
times = [[:now, Time.now],
         [:now_zoned, Time.zone.now],
         [:spring_parsed, Time.parse(springtime)],
         [:spring_parsed_zoned, Time.zone.parse(springtime)],
         [:fall_parsed, Time.parse(falltime)],
         [:fall_parsed_zoned, Time.zone.parse(falltime)]]

times.each { |k, v| puts '[%s] %s' % [k.to_s.humanize.titleize, v] }
