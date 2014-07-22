namespace :snapshot do
  namespace :push do
    desc "Save information about all presently open Chrome windows/tabs."
    task :chrome do
      raw = `chrome-cli list windows`
      require 'pry'
      binding.pry
    end
  end
end
