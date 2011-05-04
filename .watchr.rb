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


watch("spec/.*/*_spec\.rb") do |match|
  run_spec match[0]
end

watch("app/(.*/.*)\.rb") do |match|
  exclusions = ["controllers/application_controller"]
  unless exclusions.include? match[1]
    run_spec %{spec/#{match[1]}_spec.rb}
  end
end

Signal.trap('QUIT') do
  run_spec "spec/"
  run_spec "spec/acceptance/"
end
