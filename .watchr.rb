# Ctrl-L - Run all spec
# Ctrl-C - Quit watchr

def run_spec(file)
  unless File.exist?(file)
    puts "#{file} does not exist"
    return
  end
  run_spec_cmd(file)
end

def run_spec_cmd(cmd)
  puts   "------------------------"
  puts   "Running #{cmd}"
  system "bundle exec rspec #{cmd}"
end


# Specs
watch("spec/.*/*_spec\.rb") do |match|
  run_spec match[0]
end

# Models specs
watch("app/models/(.*/.*)\.rb") do |match|
  run_spec %{spec/models/#{match[1]}_spec.rb}
end

# Acceptance specs for every controller (not the best solution, 
# but it works pretty well)
watch("app/controllers/(.*/.*)\.rb") do |match|
  exclusions = ["controllers/application_controller"]
  unless exclusions.include? match[1]
    run_spec %{spec/acceptance/#{match[1]}_spec.rb}
  end
end


Signal.trap('QUIT') do
  run_spec "spec/"
end
