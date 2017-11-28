require 'clockwork'
require 'mysql_dumper'
require 'yaml'

module Clockwork
  handler do |job, time|
    
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

    dumper.dump_to(ENV['BRAVURA_PATH']+"/tmp/backup/#{time.strftime("%Y%m%d-%H%M%S")}_bravura.sql")
    
    puts "dumping FINISH"
 
  end
  
  every(1.day, 'immediate.job', :at => "#{Time.now.hour}:#{Time.now.min+1}")
  every(1.day, 'midnight.job', :at => "01:00")
end