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

require 'timeout'
require 'net/http'
require 'fileutils'
require 'socket'
require 'uri'
require 'json'
require 'ansi'
require 'debug'
require 'open3'
$stdout.sync = true
$stderr.sync = true

class String
  # Redefine the ANSI method: do not print ANSI when not running in the terminal
  #
  def ansi(*args)
    $stdout.tty? ? ANSI.ansi(self, *args) : self
  end
end

module OpenSearch
  module Extensions
    module Test
      # A convenience Ruby class for starting and stopping an OpenSearch cluster,
      # eg. for integration tests
      #
      # @example Start a cluster with default configuration,
      #          assuming `elasticsearch` is on $PATH.
      #
      #      require 'opensearch/extensions/test/cluster'
      #      OpenSearch::Extensions::Test::Cluster.start
      #
      # @example Start a cluster with a specific OpenSearch launch script,
      #          eg. from a downloaded `.tar.gz` distribution
      #
      #      system 'wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-5.1.1.tar.gz'
      #      system 'tar -xvf elasticsearch-5.1.1.tar.gz'
      #
      #      require 'opensearch/extensions/test/cluster'
      #      OpenSearch::Extensions::Test::Cluster.start command: 'elasticsearch-5.1.1/bin/elasticsearch'
      #
      # @see Cluster#initialize
      #
      module Cluster
        # Starts a cluster
        #
        # @see Cluster#start
        #
        def start(arguments = {})
          Cluster.new(arguments).start
        end

        # Stops a cluster
        #
        # @see Cluster#stop
        #
        def stop(arguments = {})
          Cluster.new(arguments).stop
        end

        # Returns true when a specific test node is running within the cluster
        #
        # @see Cluster#running?
        #
        def running?(arguments = {})
          Cluster.new(arguments).running?
        end

        # Waits until the cluster is green and prints information
        #
        # @see Cluster#wait_for_green
        #
        def wait_for_green(arguments = {})
          Cluster.new(arguments).wait_for_green
        end

        module_function :start, :stop, :running?, :wait_for_green

        class Cluster
          attr_reader :arguments

          COMMANDS = {
            '2.13' => lambda { |arguments, node_number|
              <<-COMMAND.gsub('                ', '').gsub(/\n$/, '')
                #{arguments[:command]} \
                -E cluster.name=#{arguments[:cluster_name]} \
                -E node.name=#{arguments[:node_name]}-#{node_number} \
                -E http.port=#{arguments[:port].to_i + (node_number - 1)} \
                -E path.data=#{arguments[:path_data]} \
                -E path.logs=#{arguments[:path_logs]} \
                -E cluster.routing.allocation.disk.threshold_enabled=false \
                -E network.host=#{arguments[:network_host]} \
                -E node.attr.testattr=test \
                -E path.repo=/tmp \
                -E repositories.url.allowed_urls=http://snapshot.test* \
                #{'-E discovery.type=single-node' if arguments[:number_of_nodes] < 2} \
                -E discovery.seed_hosts=#{arguments[:number_of_nodes] - 1} \
                -E node.max_local_storage_nodes=#{arguments[:number_of_nodes]} \
                -E logger.level=#{ENV['DEBUG'] ? 'DEBUG' : 'INFO'} \
                #{arguments[:es_params]}
              COMMAND
            },
            '2.14' => lambda { |arguments, node_number|
              <<-COMMAND.gsub('                ', '').gsub(/\n$/, '')
                #{arguments[:command]} \
                -E cluster.name=#{arguments[:cluster_name]} \
                -E node.name=#{arguments[:node_name]}-#{node_number} \
                -E http.port=#{arguments[:port].to_i + (node_number - 1)} \
                -E path.data=#{arguments[:path_data]} \
                -E path.logs=#{arguments[:path_logs]} \
                -E cluster.routing.allocation.disk.threshold_enabled=false \
                -E network.host=#{arguments[:network_host]} \
                -E node.attr.testattr=test \
                -E path.repo=/tmp \
                -E repositories.url.allowed_urls=http://snapshot.test* \
                #{'-E discovery.type=single-node' if arguments[:number_of_nodes] < 2} \
                -E discovery.seed_hosts=#{arguments[:number_of_nodes] - 1} \
                -E node.max_local_storage_nodes=#{arguments[:number_of_nodes]} \
                -E logger.level=#{ENV['DEBUG'] ? 'DEBUG' : 'INFO'} \
                #{arguments[:es_params]}
              COMMAND
            },
            '2.15' => lambda { |arguments, node_number|
              <<-COMMAND.gsub('                ', '').gsub(/\n$/, '')
                #{arguments[:command]} \
                -E cluster.name=#{arguments[:cluster_name]} \
                -E node.name=#{arguments[:node_name]}-#{node_number} \
                -E http.port=#{arguments[:port].to_i + (node_number - 1)} \
                -E path.data=#{arguments[:path_data]} \
                -E path.logs=#{arguments[:path_logs]} \
                -E cluster.routing.allocation.disk.threshold_enabled=false \
                -E network.host=#{arguments[:network_host]} \
                -E node.attr.testattr=test \
                -E path.repo=/tmp \
                -E repositories.url.allowed_urls=http://snapshot.test* \
                #{'-E discovery.type=single-node' if arguments[:number_of_nodes] < 2} \
                -E discovery.seed_hosts=#{arguments[:number_of_nodes] - 1} \
                -E node.max_local_storage_nodes=#{arguments[:number_of_nodes]} \
                -E logger.level=#{ENV['DEBUG'] ? 'DEBUG' : 'INFO'} \
                #{arguments[:es_params]}
              COMMAND
            },
          }.freeze

          # Create a new instance of the Cluster class
          #
          # @option arguments [String]  :cluster_name Cluster name (default: `opensearch_test`)
          # @option arguments [Integer] :number_of_nodes Number of desired nodes (default: 2)
          # @option arguments [String]  :command      OpenSearch command (default: `opensearch`)
          # @option arguments [String]  :port         Starting port number; will be auto-incremented (default: 9250)
          # @option arguments [String]  :node_name    The node name (will be appended with a number)
          # @option arguments [String]  :path_data    Path to the directory to store data in
          # @option arguments [String]  :path_work    Path to the directory with auxiliary files
          # @option arguments [String]  :path_logs    Path to the directory with log files
          # @option arguments [Boolean] :multicast_enabled Whether multicast is enabled (default: true)
          # @option arguments [Integer] :timeout      Timeout when starting the cluster (default: 60)
          # @option arguments [Integer] :timeout_version Timeout when waiting for `elasticsearch --version` (default: 2.13.0)
          # @option arguments [String]  :network_host The host that nodes will bind on and publish to
          # @option arguments [Boolean] :clear_cluster Wipe out cluster content on startup (default: true)
          # @option arguments [Boolean] :quiet         Disable printing to STDERR (default: false)
          #
          # You can also use environment variables to set the constructor options (see source).
          #
          # @see Cluster#start
          #
          def initialize(arguments = {})
            @arguments = arguments.dup

            @arguments[:command]           ||= ENV.fetch('TEST_CLUSTER_COMMAND',   'opensearch')
            @arguments[:port]              ||= ENV.fetch('TEST_CLUSTER_PORT',      9250).to_i
            @arguments[:cluster_name]      ||= ENV.fetch('TEST_CLUSTER_NAME',      __default_cluster_name).chomp
            @arguments[:node_name]         ||= ENV.fetch('TEST_CLUSTER_NODE_NAME', 'node')
            @arguments[:path_data]         ||= ENV.fetch('TEST_CLUSTER_DATA',      '/tmp/opensearch_test')
            @arguments[:path_work]         ||= ENV.fetch('TEST_CLUSTER_TMP',       '/tmp')
            @arguments[:path_logs]         ||= ENV.fetch('TEST_CLUSTER_LOGS',      '/tmp/log/opensearch')
            @arguments[:es_params]         ||= ENV.fetch('TEST_CLUSTER_PARAMS',    '')
            @arguments[:multicast_enabled] ||= ENV.fetch('TEST_CLUSTER_MULTICAST', 'true')
            @arguments[:timeout]           ||= ENV.fetch('TEST_CLUSTER_TIMEOUT',   60).to_i
            @arguments[:timeout_version]   ||= ENV.fetch('TEST_CLUSTER_TIMEOUT_VERSION', '2.13.0').to_i
            @arguments[:number_of_nodes]   ||= ENV.fetch('TEST_CLUSTER_NODES', 2).to_i
            @arguments[:network_host]      ||= ENV.fetch('TEST_CLUSTER_NETWORK_HOST', __default_network_host)
            @arguments[:quiet]             ||= !ENV.fetch('QUIET', '').empty?

            @clear_cluster = if @arguments[:clear_cluster].nil?
                               (ENV.fetch('TEST_CLUSTER_CLEAR', 'true') != 'false')
                             else
                               !!@arguments[:clear_cluster]
                             end

            # Make sure `cluster_name` is not dangerous
            raise ArgumentError, 'The `cluster_name` argument cannot be empty string or a slash' \
              if %r{^[/\\]?$}.match?(@arguments[:cluster_name])
          end

          # Starts a cluster
          #
          # Launches the specified number of nodes in a test-suitable configuration and prints
          # information about the cluster -- unless this specific cluster is already running.
          #
          # @example Start a cluster with the default configuration (2 nodes, installed version, etc)
          #      OpenSearch::Extensions::Test::Cluster::Cluster.new.start
          #
          # @example Start a cluster with a custom configuration
          #      OpenSearch::Extensions::Test::Cluster::Cluster.new(
          #        cluster_name: 'my-cluster',
          #        number_of_nodes: 3,
          #        node_name: 'my-node',
          #        port: 9350
          #      ).start
          #
          # @example Start a cluster with a different OpenSearch version
          #      OpenSearch::Extensions::Test::Cluster::Cluster.new(
          #        command: "/usr/local/Cellar/elasticsearch/1.0.0.Beta2/bin/elasticsearch"
          #      ).start
          #
          # @return Boolean,Array
          # @see Cluster#stop
          #
          def start
            if running?
              __log '[!] OpenSearch cluster already running'.ansi(:red)
              return false
            end

            __remove_cluster_data if @clear_cluster

            __log 'Starting '.ansi(:faint) + arguments[:number_of_nodes].to_s.ansi(:bold, :faint) +
                  " OpenSearch #{arguments[:number_of_nodes] < 2 ? 'node' : 'nodes'}..".ansi(:faint),
                  :print

            pids = []

            __log "\nUsing OpenSearch version [#{version}]" if ENV['DEBUG']

            arguments[:number_of_nodes].times do |n|
              n += 1

              command =  __command(version, arguments, n)
              command += '> /dev/null' unless ENV['DEBUG']

              __log command.gsub(/ {1,}/, ' ').ansi(:bold) if ENV['DEBUG']

              pid = Process.spawn(command)
              Process.detach pid
              pids << pid
              sleep 1
            end

            __check_for_running_processes(pids)
            wait_for_green
            __log __cluster_info

            true
          end

          # Stops the cluster
          #
          # Fetches the PID numbers from "Nodes Info" API and terminates matching nodes.
          #
          # @example Stop the default cluster
          #      OpenSearch::Extensions::Test::Cluster::Cluster.new.stop
          #
          # @example Stop the cluster reachable on specific port
          #      OpenSearch::Extensions::Test::Cluster::Cluster.new(port: 9350).stop
          #
          # @return Boolean,Array
          # @see Cluster#start
          #
          def stop
            begin
              nodes = __get_nodes
            rescue Exception => e
              __log "[!] Exception raised when stopping the cluster: #{e.inspect}".ansi(:red)
              nil
            end

            return false if nodes.blank?

            pids = nodes['nodes'].map { |_id, info| info['process']['id'] }

            return false if pids.empty?

            __log 'Stopping OpenSearch nodes... '.ansi(:faint), :print

            pids.each_with_index do |pid, _i|
              %w[INT KILL].each do |signal|
                begin
                  Process.kill signal, pid
                rescue Exception => e
                  __log "[#{e.class}] PID #{pid} not found. ".ansi(:red), :print
                end

                # Give the system some breathing space to finish...
                Kernel.sleep 1

                # Check that pid really is dead
                begin
                  Process.getpgid pid
                  # `getpgid` will raise error if pid is dead, so if we get here, try next signal
                  next
                rescue Errno::ESRCH
                  __log "Stopped PID #{pid}".ansi(:green) +
                        (ENV['DEBUG'] ? " with #{signal} signal".ansi(:green) : '') +
                        '. '.ansi(:green),
                        :print
                  break # pid is dead
                end
              end
            end

            __log "\n"

            pids
          end

          # Returns true when a specific test node is running within the cluster
          #
          # @return Boolean
          #
          def running?
            num_tries = 20
            cluster_health = nil
            begin
              cluster_health = __get_cluster_health
            rescue StandardError
              sleep(0.2)
              num_tries -= 1
              retry unless num_tries.negative?
            end
            if cluster_health
              cluster_health['cluster_name'] == arguments[:cluster_name] &&
                cluster_health['number_of_nodes'] == arguments[:number_of_nodes]
            else
              false
            end
          end

          # Waits until the cluster is green and prints information about it
          #
          # @return Boolean
          #
          def wait_for_green
            __wait_for_status('green', arguments[:timeout])
          end

          # Returns the major version of OpenSearch
          #
          # @return String
          # @see __determine_version
          #
          def version
            @version ||= __determine_version
          end

          # Returns default `:network_host` setting based on the version
          #
          # @api private
          #
          # @return String
          #
          def __default_network_host
            case version
            when /^2/
              '0.0.0.0'
            else
              '_local_'
            end
          end

          # Returns a reasonably unique cluster name
          #
          # @api private
          #
          # @return String
          #
          def __default_cluster_name
            "opensearch-test-#{Socket.gethostname.downcase}"
          end

          # Returns the HTTP URL for the cluster based on `:network_host` setting
          #
          # @api private
          #
          # @return String
          #
          def __cluster_url
            if arguments[:network_host] == '_local_'
              "http://localhost:#{arguments[:port]}"
            else
              "http://#{arguments[:network_host]}:#{arguments[:port]}"
            end
          end

          # Determine OpenSearch version to be launched
          #
          # Tries to get the version from the arguments passed,
          # if not available, it parses the version number from the `lib/elasticsearch-X.Y.Z.jar` file,
          # if that is not available, uses `elasticsearch --version` or `elasticsearch -v`
          #
          # @api private
          #
          # @return String
          #
          def __determine_version
            version = if arguments[:version]
                        arguments[:version]
                      else
                        if ENV['DEBUG']
                          __log "[!] Cannot find OpenSearch .jar from path to command [#{arguments[:command]}], using `#{arguments[:command]} --version`"
                        end

                        unless File.exist? arguments[:command]
                          __log "File [#{arguments[:command]}] does not exists, checking full path by `which`: ", :print if ENV['DEBUG']

                          begin
                            full_path = `which #{arguments[:command]}`.strip
                            __log "#{full_path.inspect}\n", :print if ENV['DEBUG']
                          rescue Exception
                            raise "Cannot determine full path to [#{arguments[:command]}] with 'which'"
                          end

                          if full_path.empty?
                            raise Errno::ENOENT, "Cannot find OpenSearch launch script from [#{arguments[:command]}] -- did you pass a correct path?"
                          end
                        end

                        output = ''

                        begin
                          # First, try the new `--version` syntax...
                          __log "Running [#{arguments[:command]} --version] to determine version" if ENV['DEBUG']
                          output = nil
                          status = nil

                          Timeout.timeout(arguments[:timeout_version]) do
                            output, status = Open3.capture2e("#{arguments[:command]} --version")
                          end
                        rescue Timeout::Error
                          # ...else, the old `-v` syntax
                          __log "Running [#{arguments[:command]} -V] to determine version" if ENV['DEBUG']
                          output, status = Open3.capture2e("#{arguments[:command]} -V")
                        end

                        warn "> #{output}" if ENV['DEBUG']

                        if output.empty? || !status.success?
                          raise "Cannot determine OpenSearch version from [#{arguments[:command]} --version] or [#{arguments[:command]} -v]"
                        end

                        @dist = output.match(%r{Build: ([a-z]+)/})&.[](1)

                        unless (m = output.match(/Version: (\d+\.\d+.\d+).*,/))
                          raise "Cannot determine OpenSearch version from opensearch --version output [#{output}]"
                        end

                        m[1]

                      end

            version.split('.')[0..1].join('.')
          end

          # Returns the launch command for a specific version
          #
          # @api private
          #
          # @return String
          #
          def __command(version, arguments, node_number)
            raise ArgumentError, "Cannot find command for version [#{version}]" unless (command = COMMANDS[version])

            arguments[:dist] = @dist
            command.call(arguments, node_number)
          end

          # Blocks the process and waits for the cluster to be in a "green" state
          #
          # Prints information about the cluster on STDOUT if the cluster is available.
          #
          # @param status  [String]  The status to wait for (yellow, green)
          # @param timeout [Integer] The explicit timeout for the operation
          #
          # @api private
          #
          # @return Boolean
          #
          def __wait_for_status(status = 'green', timeout = 30)
            begin
              Timeout.timeout(timeout) do
                loop do
                  response = __get_cluster_health(status)
                  __log response if ENV['DEBUG']

                  if response && response['status'] == status && (arguments[:number_of_nodes].nil? || arguments[:number_of_nodes].to_i == response['number_of_nodes'].to_i)
                    break
                  end

                  __log '.'.ansi(:faint), :print
                  sleep 1
                end
              end
            rescue Timeout::Error => e
              message = "\nTimeout while waiting for cluster status [#{status}]"
              message += " and [#{arguments[:number_of_nodes]}] nodes" if arguments[:number_of_nodes]
              __log message.ansi(:red, :bold)
              raise e
            end

            true
          end

          # Return information about the cluster
          #
          # @api private
          #
          # @return String
          #
          def __cluster_info
            health = JSON.parse(Net::HTTP.get(URI("#{__cluster_url}/_cluster/health")))
            nodes  = if version == '0.90'
                       JSON.parse(Net::HTTP.get(URI("#{__cluster_url}/_nodes/?process&http")))
                     else
                       JSON.parse(Net::HTTP.get(URI("#{__cluster_url}/_nodes/process,http")))
                     end
            master = JSON.parse(Net::HTTP.get(URI("#{__cluster_url}/_cluster/state")))['master_node']

            result = [
              "\n",
              ('-' * 80).ansi(:faint),
              'Cluster: '.ljust(20).ansi(:faint) + health['cluster_name'].to_s.ansi(:faint),
              'Status:  '.ljust(20).ansi(:faint) + health['status'].to_s.ansi(:faint),
              'Nodes:   '.ljust(20).ansi(:faint) + health['number_of_nodes'].to_s.ansi(:faint),
            ].join("\n")

            nodes['nodes'].each do |id, info|
              m = id == master ? '*' : '-'
              result << ("\n" +
                        ''.ljust(20) +
                        "#{m} ".ansi(:faint) +
                        "#{info['name'].ansi(:bold)} ".ansi(:faint) +
                        "| version: #{begin
                          info['version']
                        rescue StandardError
                          'N/A'
                        end}, ".ansi(:faint) +
                        "pid: #{begin
                          info['process']['id']
                        rescue StandardError
                          'N/A'
                        end}, ".ansi(:faint) +
                        "address: #{begin
                          info['http']['bound_address']
                        rescue StandardError
                          'N/A'
                        end}".ansi(:faint))
            end

            result
          end

          # Tries to load cluster health information
          #
          # @api private
          #
          # @return Hash,Nil
          #
          def __get_cluster_health(status = nil)
            uri = URI("#{__cluster_url}/_cluster/health")
            uri.query = "wait_for_status=#{status}" if status

            begin
              response = Net::HTTP.get(uri)
            rescue Exception => e
              warn e.inspect if ENV['DEBUG']
              return nil
            end
            JSON.parse(response)
          end

          # Remove the data directory
          #
          # @api private
          #
          def __remove_cluster_data
            FileUtils.rm_rf arguments[:path_data]
          end

          # Check whether process for PIDs are running
          #
          # @api private
          #
          def __check_for_running_processes(pids)
            return unless `ps -p #{pids.join(' ')}`.split("\n").size < arguments[:number_of_nodes] + 1

            __log "\n[!!!] Process failed to start (see output above)".ansi(:red)
            exit(1)
          end

          # Get the information about nodes
          #
          # @api private
          #
          def __get_nodes
            JSON.parse(Net::HTTP.get(URI("#{__cluster_url}/_nodes/process")))
          end

          # Print to STDERR
          #
          def __log(message, mode = :puts)
            $stderr.__send__ mode, message unless @arguments[:quiet]
          end
        end
      end
    end
  end
end
