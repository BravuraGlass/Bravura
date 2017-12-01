bundle exec rake puma:stop
puma -e production -p 3001 -w 2 --pidfile tmp/pids/puma.pid -d

