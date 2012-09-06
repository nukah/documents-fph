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


before_fork do |server,worker|
    old_pid = "/tmp/unicorn.my_site.pid.oldbin"
    if File.exists?(old_pid) && server.pid != old_pid
        begin
            Process.kill("QUIT", File.read(old_pid).to_i)
        rescue Errno::ENOENT, Errno::ESRCH
        end
    end
end
after_fork do |server, worker|
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
  end
end