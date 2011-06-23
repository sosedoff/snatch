module Snatch
  class CredentialsError < Exception ; end
  class NoDatabaseError  < Exception ; end
  class NoServiceError   < Exception ; end
  
  class Session
    attr_reader :config, :filename
    
    def initialize(config)
      @config = config
      @config[:port] = config[:port] || 22
      @ssh = nil
      @filename = "#{@config[:host]}_#{Time.now.strftime("%Y%m%d%H%M%S")}.sql.gz"
    end
    
    def run!
      connect
      test
      dump
      download
      cleanup
      disconnect
    end
    
    private
    
    # Connect to remote server
    def connect
      puts "ssh: connecting..."
      begin
        @ssh = Net::SSH.start(@config[:host], @config[:user], :port => @config[:port], :password => @config[:password])
      rescue Net::SSH::AuthenticationFailed
        raise CredentialsError, 'Invalid SSH user or password'
      end
      puts "ssh: connected."
    end
    
    # Close ssh connection
    def disconnect
      @ssh.close
      puts "ssh: disconnected."
    end
    
    # Check configuration options
    def test
      raise NoServiceError, "No mysql found." unless @ssh.exec!("which mysql") =~ /mysql/i
      raise NoServiceError, "No mysqldump found." unless @ssh.exec!("which mysqldump") =~ /mysqldump/i
      
      resp = @ssh.exec!("mysql --execute='SHOW DATABASES;' --user=#{@config[:db_user]} --password=#{@config[:db_password]}")
      if resp =~ /ERROR 1045/
        raise CredentialsError, 'Invalid MySQL user or password'
      end
      
      list = resp.split("\n").map { |s| s.strip }.select { |s| !s.empty? }.drop(1)
      diff = @config[:db_list] - list
      
      unless diff.empty?
        raise NoDatabaseError, "Database(s) not found: #{diff.join(', ')}"
      end
    end
    
    # Generate MySQL database dump
    def dump
      cmd = []
      cmd << "--user=#{@config[:db_user]}"
      cmd << "--password=#{@config[:db_password]}" unless @config[:db_password].to_s.strip.empty?
      cmd << "--add-drop-database"
      cmd << "--add-drop-table"
      cmd << "--compact"
      cmd << "--databases #{@config[:db_list].join(' ')}"
      cmd = "mysqldump #{cmd.join(' ')} | gzip --best > /tmp/#{filename}"
      
      puts "mysql: creating a dump..."
      @ssh.exec!(cmd)
      puts "mysql: done."
    end
    
    # Cleanup dump
    def cleanup
      @ssh.exec!("rm -f /tmp/#{filename}")
    end
    
    # Fetch remote dump to local filesystem
    def download
      Net::SFTP.start(@config[:host], @config[:user], :port => @config[:port], :password => @config[:password]) do |sftp|
        t = sftp.download!(
          "/tmp/#{filename}",                  # Remote file
          "#{Dir.pwd}/#{filename}",            # Local file
          :progress => TransferHandler.new     # Handler
        )
        t.wait
      end
    end
  end
end
