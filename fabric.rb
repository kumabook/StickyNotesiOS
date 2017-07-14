require 'json'

config = ""
open("StickyNotes/config.json") do |io|
  config = JSON.load(io)
end

if config["fabricApiKey"] == nil || config["fabricBuildSecret"] == nil
  puts "Skip fabric script because the config.json is not set correctly."
  exit
end
run_command = "${PODS_ROOT}/Fabric/run"
success = system("#{run_command} #{config["fabricApiKey"]} #{config["fabricBuildSecret"]}")
if success
  puts "Succeeded in running fabric script"
else
  puts "Failed to run fabric script"
end
