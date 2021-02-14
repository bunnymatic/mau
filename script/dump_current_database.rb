#!/usr/bin/env ruby
require 'yaml'

MYSQL_DUMP_EXEC = 'mysqldump'.freeze

class DbDumper
  def db_config
    @db_config ||= YAML.load_file(Rails.root.join('config/database.yml')).fetch(Rails.env)
  end

  def db_name
    db_config.fetch('database')
  end

  def db_cmdline_args
    # NOTE: Assuming that database is running on localhost
    # TODO - if you use other args like :socket, or ? they are ignored
    # we could add host, port etc to make this more flexible
    db_args = [['--user=', 'username'], ['--password=', 'password']].map do |entry|
      "#{entry[0]}#{db_config[entry[1]]}" if db_config[entry[1]].present?
    end.compact
    db_args + ['--single-transaction']
  end
end

def destination_file
  "mau_latest_#{Rails.env}.mysql"
end

dumper = DbDumper.new
cmd_args = [MYSQL_DUMP_EXEC] + dumper.db_cmdline_args + [dumper.db_name, " > #{destination_file}"]
cmd = cmd_args.join(' ')
print "Dumping #{dumper.db_name} to #{destination_file}..."
`#{cmd}`
puts 'done'
