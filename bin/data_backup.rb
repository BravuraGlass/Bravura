require 'clockwork'
require 'mysql_dumper'
require 'yaml'

module Clockwork
  handler do |job, time|
    
    backup_dir = ENV['BRAVURA_PATH']+"/tmp/backup/"
    # Creates directory as long as it doesn't already exist
    Dir.mkdir(backup_dir) unless Dir.exist?(backup_dir)

    files = Dir.entries(backup_dir).sort.select { |f|  f.include?(".sql") }

    while files.size > 6 do
      File.delete(backup_dir + files.first)
      files.shift
    end
    
    data = YAML.load_file(ENV['BRAVURA_PATH']+"/config/database.yml")
    
    clock_env = ENV['BRAVURA_PATH'].include?("newbravura") ? "production" : "development"
     
    config = {
      "database" => data[clock_env]["database"],
      "username" => data[clock_env]["username"],
      "password" => data[clock_env]["password"]
    }
    
    puts "dumping START"
    puts time.strftime("%Y%m%d-%H%M%S")

    dumper = MysqlDumper.new config

    dumper.dump_to(backup_dir+"#{time.strftime("%Y%m%d-%H%M%S")}_bravura.sql")
    
    puts "dumping FINISH"
 
  end
  
  every(1.day, 'midnight.job', :at => "01:00")
end