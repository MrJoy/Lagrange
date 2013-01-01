desc "Start an IRB environment with the Lagrange codebase loaded."
task :irb => :environment do
  ARGV.clear
  require 'irb'
  IRB.start
end
