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

# coding: utf-8

require 'English'

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'opensearch/extensions/version'

Gem::Specification.new do |s|
  s.name          = 'opensearch-extensions'
  s.version       = OpenSearch::Extensions::VERSION
  s.authors       = ['Jon Rogers']
  s.email         = ['jon@rcode5.com']
  s.description   = 'Extensions for the OpenSearch Rubygem'
  s.summary       = 'Extensions for the OpenSearch Rubygem'
  s.license       = 'Apache-2.0'
  s.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_dependency 'ansi'
  s.add_dependency 'opensearch-ruby'

  s.metadata['rubygems_mfa_required'] = 'true'
end
