# Licensed to OpenSearch B.V. under one or more contributor
# license agreements. See the NOTICE file distributed with
# this work for additional information regarding copyright
# ownership. OpenSearch B.V. licenses this file to you under
# the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

# encoding: utf-8

require 'pathname'
require 'fileutils'

require 'multi_json'

begin
  require 'oj'
rescue LoadError
  warn('The "oj" gem could not be loaded. JSON parsing and serialization performance may not be optimal.')
end

begin
  require 'patron'
rescue LoadError
  warn('The "patron" gem could not be loaded. HTTP requests may not be performed optimally.')
end

require 'elasticsearch'

module Backup
  module Database
    # Integration with the Backup gem [http://backup.github.io/backup/v4/]
    #
    # This extension allows to backup OpenSearch indices as flat JSON files on the disk.
    #
    # @example Use the Backup gem's DSL to configure the backup
    #
    #     require 'opensearch/extensions/backup'
    #
    #     Model.new(:elasticsearch_backup, 'OpenSearch') do
    #
    #       database OpenSearch do |db|
    #         db.url     = 'http://localhost:9200'
    #         db.indices = 'articles,people'
    #         db.size    = 500
    #         db.scroll  = '10m'
    #       end
    #
    #       store_with Local do |local|
    #         local.path = '/tmp/backups'
    #         local.keep = 3
    #       end
    #
    #       compress_with Gzip
    #     end
    #
    # Perform the backup with the Backup gem's command line utility:
    #
    #     $ backup perform -t elasticsearch_backup
    #
    # The Backup gem can store your backup files on S3, Dropbox and other
    # cloud providers, send notifications about the operation, and so on;
    # read more in the gem documentation.
    #
    # @example Use the integration as a standalone script (eg. in a Rake task)
    #
    #     require 'backup'
    #     require 'opensearch/extensions/backup'
    #
    #     Backup::Logger.configure do
    #       logfile.enabled   = true
    #       logfile.log_path  = '/tmp/backups/log'
    #     end; Backup::Logger.start!
    #
    #     backup  = Backup::Model.new(:elasticsearch, 'Backup OpenSearch') do
    #       database Backup::Database::OpenSearch do |db|
    #         db.indices = 'test'
    #       end
    #
    #       store_with Backup::Storage::Local do |local|
    #         local.path = '/tmp/backups'
    #       end
    #     end
    #
    #     backup.perform!
    #
    # @example A simple recover script for the backup created in the previous examples
    #
    #     PATH = '/path/to/backup/'
    #
    #     require 'elasticsearch'
    #     client  = OpenSearch::Client.new log: true
    #     payload = []
    #
    #     Dir[ File.join( PATH, '**', '*.json' ) ].each do |file|
    #       document = MultiJson.load(File.read(file))
    #       item = document.merge(data: document['_source'])
    #       document.delete('_source')
    #       document.delete('_score')
    #
    #       payload << { index: item }
    #
    #       if payload.size == 100
    #         client.bulk body: payload
    #         payload = []
    #       end
    #
    #       client.bulk body: payload
    #     end
    #
    # @see http://backup.github.io/backup/v4/
    #
    class OpenSearch < Base
      class Error < ::Backup::Error; end

      attr_accessor :url, :indices, :size, :scroll, :mode

      def initialize(model, database_id = nil, &)
        super

        @url     ||= 'http://localhost:9200'
        @indices ||= '_all'
        @size    ||= 100
        @scroll  ||= '10m'
        @mode    ||= 'single'

        instance_eval(&) if block
      end

      def perform!
        super

        case mode
        when 'single'
          __perform_single
        else
          raise Error, "Unsupported mode [#{mode}]"
        end

        log!(:finished)
      end

      def client
        @client ||= ::OpenSearch::Client.new url:, logger:
      end

      def path
        Pathname.new File.join(dump_path, dump_filename.downcase)
      end

      def logger
        logger = Backup::Logger.__send__(:logger)
        logger.instance_eval do
          def debug(*args); end
          # alias :debug :info
          alias :fatal :warn
        end
        logger
      end

      def __perform_single
        r = client.search(index: indices, search_type: 'scan', scroll:, size:)
        raise Error, "No scroll_id returned in response:\n#{r.inspect}" unless r['_scroll_id']

        while ((r = client.scroll(scroll_id: r['_scroll_id'], scroll:))) && !r['hits']['hits'].empty?
          r['hits']['hits'].each do |hit|
            FileUtils.mkdir_p path.join(hit['_index'], hit['_type']).to_s
            File.write("#{path.join hit['_index'], hit['_type'], __sanitize_filename(hit['_id'])}.json", MultiJson.dump(hit))
          end
        end
      end

      def __sanitize_filename(name)
        name
          .encode(Encoding::UTF_8, invalid: :replace, undef: :replace, replace: '�')
          .strip
          .tr("\u{202E}%$|:;/\t\r\n\\", '-')
      end
    end
  end
end

Backup::Config::DSL::OpenSearch = Backup::Database::OpenSearch
