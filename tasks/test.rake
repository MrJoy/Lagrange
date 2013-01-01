task :test do
  # The 'rescue nil' clauses are so the remainder of the test suite will
  # execute even if a test failure occurs in one of them.
  sh 'rspec' rescue nil
  sh 'cucumber' rescue nil
end

namespace :test do
  task :coverage do
    ENV['USING_COVERAGE']='1'
    Rake::Task[:test].invoke
  end
end

CLOBBER.include('coverage')
