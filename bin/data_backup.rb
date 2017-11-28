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
    
    puts time.strftime("%Y%m%d-%H%M%S")

    dumper = MysqlDumper.new config

    dumper.dump_to(ENV['BRAVURA_PATH']+"/tmp/#{time}bravura.sql")
 
  end
  
  every(1.day, 'backup.job', :at => '19:50')

end