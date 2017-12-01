namespace :puma do 
  desc 'stop puma'

  task :stop do
    puts "puma stop start"
    pid_file = 'tmp/pids/puma.pid'
    pid = File.read(pid_file).to_i
    Process.kill 9, pid
    File.delete pid_file
    puts "puma stop finish"
  end
end  