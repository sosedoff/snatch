require 'net/ssh'
require 'net/sftp'

require 'snatch/version'
require 'snatch/hash'
require 'snatch/handler'
require 'snatch/session'

module Snatch
  def self.root
    File.join(ENV['HOME'], '.snatch')
  end
  
  def self.run(config)
    s = Snatch::Session.new(config)
    s.run!
  end
  
  # Returns true if snatch config is valid
  def self.valid_config?(path)
    data = YAML.load_file(path)
    if data.kind_of?(Hash)
      (data.keys & ['host']).size == 1
    else
      false
    end
  end
end