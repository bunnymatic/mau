guard :rspec, cmd: 'bundle exec rspec' do
  watch('spec/spec_helper.rb')  { "spec" }
  watch('spec/rails_helper.rb')  { "spec" }
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^spec/support/(.+)\.rb$}) { "spec" }
  watch(%r{^spec/factories/(.+)\.rb$}) { "spec" }
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }

  # Rails example
  watch(%r{^app/(.*)\.rb$})                           { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^app/(.*)(\.erb|\.haml)$})                 { |m| "spec/#{m[1]}#{m[2]}_spec.rb" }
  watch(%r{^app/controllers/(.+)_(controller)\.rb$})  { |m| ["spec/routing/#{m[1]}_routing_spec.rb", "spec/#{m[2]}s/#{m[1]}_#{m[2]}_spec.rb"] }
  watch('config/routes.rb')                           { "spec" }
  watch('app/controllers/application_controller.rb')  { "spec/controllers" }
  watch('config/environments/test.rb') { "spec" }
  watch('config/application.rb') { "spec" }

end

# guard 'cucumber' do
#   watch(%r{^features/.+\.feature$})
#   watch(%r{^features/support/.+$})                      { 'features' }
#   watch(%r{^features/step_definitions/(.+)_steps\.rb$}) { |m| Dir[File.join("**/#{m[1]}.feature")][0] || 'features' }
# end

# guard :jasmine do
#   watch(%r{spec/javascripts/spec\.(js\.coffee|js|coffee)$}) { 'spec/javascripts' }
#   watch(%r{spec/javascripts/.+_spec\.(js\.coffee|js|coffee)$})
#   watch(%r{spec/javascripts/fixtures/.+$})
#   watch(%r{app/assets/javascripts/(.+?)\.(js\.coffee|js|coffee)(?:\.\w+)*$}) { |m| "spec/javascripts/#{ m[1] }_spec.#{ m[2] }" }
# end
