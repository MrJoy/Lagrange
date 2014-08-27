desc "Start an IRB environment with the Lagrange codebase loaded."
task :irb => :environment do
  # TODO: Include debugging pattern...
  ARGV.clear
  require 'irb'
  IRB.start
end
