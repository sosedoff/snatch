require 'net/ssh'
require 'net/sftp'

require 'snatch/version'
require 'snatch/hash'
require 'snatch/handler'
require 'snatch/session'

module Snatch
  def self.run(config)
    s = Snatch::Session.new(config)
    s.run!
  end
end