module Lagrange
  module Git
    def self.versions(file)
      results=`cd #{Lagrange::repository.absolute_escaped}; git rev-list HEAD -- #{file.relative_escaped}`.chomp
      if(results == "")
        results = nil
      else
        results = results.split(/\n/)
      end
      return results
    end

    def self.current_version(file)
      commit=`cd #{Lagrange::repository.absolute_escaped}; git rev-list HEAD -1 -- #{file.relative_escaped}`.chomp
      commit = nil if(commit == "")
      return commit
    end

    def self.parent_version(commit)
      commit=`cd #{Lagrange::repository.absolute_escaped}; git rev-list -1 #{commit}^1`.chomp
      commit = nil if(commit == "")
      return commit
    end

    def self.get_version(file, commit)
      blob = `cd #{Lagrange::repository.absolute_escaped}; git ls-tree -r #{commit} | grep -E '^[0-9]{6} blob ' | perl -pse 's/(.*?\\s.*?\\s.*?)\\s+(.*)$/$1 $2/' | grep \\ #{file.relative_escaped}\\$ | cut -d" " -f3`.chomp
      blob = nil if(blob == "")
      if(!blob.nil?)
        contents = `cd #{Lagrange::repository.absolute_escaped}; git cat-file blob #{blob}`.chomp
        contents = nil if(contents == "")
      end
      return contents;
    end
  end
end
