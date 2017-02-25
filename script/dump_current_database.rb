#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'

MYSQL_DUMP_EXEC = 'mysqldump'

def get_db_config
  @dbconfig ||= YAML.load_file(Rails.root.join('config', 'database.yml')).fetch(Rails.env)
end

def db_name
  get_db_config.fetch('database')
end

def get_db_cmdline_args
  dbcnf = get_db_config
  # NOTE: Assuming that database is running on localhost
  # TODO - if you use other args like :socket, or ? they are ignored
  # we could add host, port etc to make this more flexible
  db_args = [['--user=', 'username'], ['--password=', 'password']].map do |entry|
    "#{entry[0]}#{dbcnf[entry[1]]}" if dbcnf[entry[1]].present?
  end.compact
  db_args += ['--single-transaction']
end

def destination_file
  "mau_latest_#{Rails.env}.mysql"
end

cmd_args = [MYSQL_DUMP_EXEC] + get_db_cmdline_args + [db_name, " > #{destination_file}"]
cmd = cmd_args.join(' ')
print "Dumping #{db_name} to #{destination_file}..."
`#{cmd}`
puts 'done'
