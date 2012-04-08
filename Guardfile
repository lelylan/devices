# -----------------
# Spork guardfile
# -----------------

guard 'spork', :rspec_env => { 'RAILS_ENV' => 'test' } do
  watch('config/application.rb')
  watch('config/environment.rb')
  watch(%r{^config/environments/.+\.rb$})
  watch(%r{^config/initializers/.+\.rb$})
  watch('Gemfile')
  watch('Gemfile.lock')
  watch('spec/spec_helper.rb') { :rspec }
end


# -----------------
# RSpec guardfile
# -----------------

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
end
