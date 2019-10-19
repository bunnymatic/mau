# frozen_string_literal: true

Time::DATE_FORMATS[:pickadate] = '%d %B, %Y'
Time::DATE_FORMATS[:admin] = ->(time) { time.iso8601 }
Time::DATE_FORMATS[:admin_date_only] = '%Y-%m-%d'
Time::DATE_FORMATS[:os_day] = '%b %d'
