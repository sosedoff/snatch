module Snatch
  class TransferHandler
    def on_open(downloader, file)
      puts "ftp: downloading: #{file.remote} -> #{file.local}"
    end

    def on_close(downloader, file)
      puts "ftp: finished downloading #{File.basename(file.remote)}"
    end

    def on_finish(downloader)
      puts "ftp: file saved."
    end
  end
end