require File.expand_path('../lib/boot', __FILE__)

desc "Start an IRB environment with the Lagrange codebase loaded."
task :irb do
  sh "irb -r./lib/boot"
end