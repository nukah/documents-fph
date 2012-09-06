worker_processes 6
listen "/tmp/docs.primepress.socket", :backlog => 64
preload_app true
timeout 30
pid "/tmp/unicorn.docs.primepress.pid"
working_directory "/var/www/docs.primepress/current"
user 'user'
shared_path = "/var/www/docs.primepress/current"
stderr_path "#{shared_path}/log/unicorn.stderr.log"
stdout_path "#{shared_path}/log/unicorn.stdout.log"

after_fork do |server, worker|
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
  end
end