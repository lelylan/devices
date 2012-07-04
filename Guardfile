<<<<<<< HEAD
# --------
# Spork
# --------

guard 'spork', :rspec_env => { 'RAILS_ENV' => 'test' } do
  watch('config/application.rb')
  watch('config/environment.rb')
  watch(%r{^config/environments/.+\.rb$})
  watch(%r{^config/initializers/.+\.rb$})
  watch('Gemfile')
  watch('Gemfile.lock')
  watch('spec/spec_helper.rb') { :rspec }
end



# --------
# RSpec
# --------

guard 'rspec', cli: '--drb --format Fuubar --color', all_on_start: false, all_after_pass: false, :version => 2 do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})      { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')   { "spec" }

  watch(%r{^app/(.+)\.rb$})                           { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^app/(.*)(\.erb|\.haml)$})                 { |m| "spec/#{m[1]}#{m[2]}_spec.rb" }
  watch(%r{^app/controllers/(.+)\.rb})                { |m| "spec/requests/#{m[1]}_spec.rb" }  
  watch(%r{^spec/support/(.+)\.rb$})                  { "spec" }
  watch('app/controllers/application_controller.rb')  { "spec/requests" }

  watch(%r{^app/views/(.+)/(.+)\.rabl$})                 { |m| "spec/requests/#{m[1]}_controller_spec.rb" }
  watch(%r{^spec/requests/support/views/(.+)_view\.rb$}) { |m| "spec/requests/#{m[1]}_controller_spec.rb" }
=======
guard 'rspec', cli: '--format Fuubar --color', all_on_start: false, all_after_pass: false do
  watch(%r{^spec/.+_spec\.rb})
  watch(%r{^lib/(.+)\.rb})     { |m| "spec/lib/#{m[1]}_spec.rb" }

  watch(%r{^app/controllers/(.+)\.rb})                { |m| "spec/acceptance/#{m[1]}_spec.rb" }
  watch(%r{^app/models/(.+)\.rb})                     { |m| "spec/models/#{m[1]}_spec.rb" }
  watch(%r{^lib/(.+)\.rb})                            { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch(%r{^config/initializers/extensions/(.+)\.rb}) { |m| "spec/acceptance/extensions/#{m[1]}_spec.rb" }
>>>>>>> a94ab928ffed209bca7c3d87982a12be9974a750
end
