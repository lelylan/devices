guard 'rspec', cli: '--format Fuubar --color', all_on_start: false, all_after_pass: false do
  watch(%r{^spec/.+_spec\.rb})
  watch(%r{^lib/(.+)\.rb})     { |m| "spec/lib/#{m[1]}_spec.rb" }

  watch(%r{^app/controllers/(.+)\.rb})                { |m| "spec/acceptance/#{m[1]}_spec.rb" }
  watch(%r{^app/models/(.+)\.rb})                     { |m| "spec/models/#{m[1]}_spec.rb" }
  watch(%r{^lib/(.+)\.rb})                            { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch(%r{^config/initializers/extensions/(.+)\.rb}) { |m| "spec/acceptance/extensions/#{m[1]}_spec.rb" }
end
