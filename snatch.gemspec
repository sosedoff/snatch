require 'lib/snatch/version'

Gem::Specification.new do |s|
  s.name        = "snatchdb"
  s.version     = Snatch::VERSION
  s.date        = Time.now.strftime("%Y-%m-%d")
  s.description = "Remote database downloader"
  s.summary     = "Snatch is a remote database downloader based on SSH"
  s.authors     = ["Dan Sosedoff"]
  s.email       = "dan.sosedoff@gmail.com"
  s.homepage    = "http://github.com/sosedoff/snatch"

  s.files = %w[
    bin/snatch
    lib/snatch.rb
    lib/snatch/version.rb
    lib/snatch/hash.rb
    lib/snatch/handler.rb
    lib/snatch/session.rb
  ]

  s.executables = ["snatch"]
  s.default_executable = "snatch"
  
  s.add_dependency('net-ssh', '2.0.24')
  s.add_dependency('net-sftp', '2.0.5')
  
  s.rubygems_version = '1.3.7'
end