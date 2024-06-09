# OpenSearch::Extensions

This library provides a set of extensions to the [`opensearch`](https://github.com/opensearch-project/opensearch-ruby) Rubygem.

## Installation

Currently this is only available here as a subcomponent of Mission Artists.

## Extensions

### Backup

NOTE: not tested with the move to opensearch - use with caution

Backup OpenSearch indices as flat JSON files on the disk via integration
with the [_Backup_](http://backup.github.io/backup/v4/) gem.

Use the Backup gem's DSL to configure the backup:

    require 'opensearch/extensions/backup'

    Model.new(:opensearch_backup, 'OpenSearch') do

      database OpenSearch do |db|
        db.url     = 'http://localhost:9200'
        db.indices = 'test'
      end

      store_with Local do |local|
        local.path = '/tmp/backups'
      end

      compress_with Gzip
    end

Perform the backup with the Backup gem's command line utility:

    $ backup perform -t opensearch_backup

See more information in the [`Backup::Database::OpenSearch`](lib/opensearch/extensions/backup.rb)
class documentation.

### Reindex

NOTE: not tested with the move to opensearch - use with caution


Copy documents from one index and cluster into another one, for example for purposes of changing
the settings and mappings of the index.

**NOTE:** OpenSearch natively supports re-indexing since version 2.3. This extension is useful
          when you need the feature on older versions.

When the extension is loaded together with the
[Ruby client for OpenSearch](../elasticsearch/README.md),
a `reindex` method is added to the client:

    require 'elasticsearch'
    require 'opensearch/extensions/reindex'

    client = OpenSearch::Client.new
    target_client = OpenSearch::Client.new url: 'http://localhost:9250', log: true

    client.index index: 'test', type: 'd', body: { title: 'foo' }

    client.reindex source: { index: 'test' },
                   dest: { index: 'test', client: target_client },
                   transform: lambda { |doc| doc['_source']['title'].upcase! },
                   refresh: true
    # => { errors: 0 }

    target_client.search index: 'test'
    # => ... hits ... "title"=>"FOO"

The method takes similar arguments as the core API
[`reindex`](http://www.rubydoc.info/gems/elasticsearch-api/OpenSearch/API/Actions#reindex-instance_method)
method.

You can also use the `Reindex` class directly:

    require 'elasticsearch'
    require 'opensearch/extensions/reindex'

    client = OpenSearch::Client.new

    reindex = OpenSearch::Extensions::Reindex.new \
                source: { index: 'test', client: client },
                dest: { index: 'test-copy' }

    reindex.perform

See more information in the [`OpenSearch::Extensions::Reindex::Reindex`](lib/opensearch/extensions/reindex.rb)
class documentation.

### ANSI

NOTE: not tested with the move to opensearch - use with caution


Colorize and format selected  OpenSearch response parts in terminal:

Display formatted search results:

    require 'opensearch/extensions/ansi'
    puts OpenSearch::Client.new.search.to_ansi

Display a table with the output of the `_analyze` API:

    require 'opensearch/extensions/ansi'
    puts OpenSearch::Client.new.indices.analyze(text: 'Quick Brown Fox Jumped').to_ansi

[Full documentation](http://rubydoc.info/gems/elasticsearch-extensions/OpenSearch/Extensions/ANSI)

### Test::Cluster

Allows to programatically start and stop an OpenSearch cluster suitable for isolating tests.

The HTTP service is running on ports `9250-*` by default.

Start and stop the default cluster:

    require 'opensearch/extensions/test/cluster'

    OpenSearch::Extensions::Test::Cluster.start
    OpenSearch::Extensions::Test::Cluster.stop

Start the cluster on specific port, with a specific OpenSearch version, number of nodes and cluster name:

    require 'opensearch/extensions/test/cluster'

    OpenSearch::Extensions::Test::Cluster.start \
      cluster_name:    "my-testing-cluster",
      command:         "path/to/opensearch",
      port:            9350,
      number_of_nodes: 3

    # Starting 3 OpenSearch nodes.....................
    # --------------------------------------------------------------------------------
    # Cluster:            my-testing-cluster
    # Status:             green
    # Nodes:              3
    #                     - node-1 | version: 1.0.0.Beta2, pid: 54469
    #                     + node-2 | version: 1.0.0.Beta2, pid: 54470
    #                     - node-3 | version: 1.0.0.Beta2, pid: 54468
    # => true

Stop this cluster:

    require 'opensearch/extensions/test/cluster'

    OpenSearch::Extensions::Test::Cluster.stop port: 9350

    # Stopping OpenSearch nodes... stopped PID 54469. stopped PID 54470. stopped PID 54468.
    # # => [54469, 54470, 54468]

You can control the cluster configuration with environment variables as well:

    TEST_CLUSTER_NAME=my-testing-cluster \
    TEST_CLUSTER_COMMAND=path/to/opensearch \
    TEST_CLUSTER_PORT=9350 \
    TEST_CLUSTER_NODES=3 \
    TEST_CLUSTER_NAME=my_testing_cluster \
    ruby -r opensearch-ruby -e "require 'opensearch/extensions/test/cluster'; OpenSearch::Extensions::Test::Cluster.start"

To prevent deleting data and configurations when the cluster is started, for example in a development environment,
use the `clear_cluster: false` option or the `TEST_CLUSTER_CLEAR=false` environment variable.

### Test::StartupShutdown


Allows to register `startup` and `shutdown` hooks for Test::Unit, similarly to RSpec's `before(:all)`,
compatible with the [Test::Unit 2](https://github.com/test-unit/test-unit/blob/master/lib/test/unit/testcase.rb) syntax.

The extension is useful for e.g. starting the testing OpenSearch cluster before the test suite is executed,
and stopping it afterwards.

** IMPORTANT NOTE ** You have to register the handler for `shutdown` hook before requiring 'test/unit':

    # File: test_helper.rb
    at_exit { MyTest.__run_at_exit_hooks }
    require 'test/unit'

Example of handler registration:

    class MyTest < Test::Unit::TestCase
      extend OpenSearch::Extensions::Test::StartupShutdown

      startup  { puts "Suite starting up..." }
      shutdown { puts "Suite shutting down..." }
    end

### Test::Profiling

NOTE: not tested with the move to opensearch - use with caution

Allows to define and execute profiling tests within [Shoulda](https://github.com/thoughtbot/shoulda) contexts.
Measures operations and reports statistics, including code profile.

Let's define a simple profiling test in a `profiling_test.rb` file:

    require 'test/unit'
    require 'shoulda/context'
    require 'opensearch/extensions/test/profiling'

    class ProfilingTest < Test::Unit::TestCase
      extend OpenSearch::Extensions::Test::Profiling

      context "Mathematics" do
        measure "divide numbers", count: 10_000 do
          assert_nothing_raised { 1/2 }
        end
      end

    end

Let's run it:

    $ QUIET=y ruby profiling_test.rb

    ...
    ProfilingTest

    -------------------------------------------------------------------------------
    Context: Mathematics should divide numbers (10000x)
    mean: 0.03ms | avg: 0.03ms | max: 0.14ms
    -------------------------------------------------------------------------------
         PASS (0:00:00.490) test: Mathematics should divide numbers (10000x).
    ...

When using the `QUIET` option, only the statistics on operation throughput are printed.
When omitted, the full code profile by [RubyProf](https://github.com/ruby-prof/ruby-prof) is printed.


## Development

To work on the code, clone and bootstrap the main repository first --
please see instructions in the main [README](../README.md#development).

To run tests, launch a testing cluster -- again, see instructions
in the main [README](../README.md#development) -- and use the Rake tasks:

```
time rake test:unit
time rake test:integration
```

Unit tests have to use Ruby 1.8 compatible syntax, integration tests
can use Ruby 2.x syntax and features.

## License

This software is licensed under the [Apache 2 license](./LICENSE).
