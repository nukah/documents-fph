# config valid only for Capistrano 3.1
lock '3.1.0'

set :application, 'document_storage'
set :repo_url, 'https://github.com/nukah/documents-fph.git'

set :domain_dir, "docs.primepress"
set :user, "user"
# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }
set :default_env, { path: "~/.rbenv/shims:~/.rbenv/bin:$PATH" }
set :deploy_to, "/var/www/#{fetch(:domain_dir)}"
set :shell, "/usr/bin/bash"
set :rbenv_type, :user
set :rbenv_ruby, '2.1.1'
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w{rake gem bundle ruby rails unicorn unicorn_rails}
# Default value for :linked_files is []
# set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      # execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end
namespace :db do
  desc "Creates Postgres database and appropriate user"
  task :setup do
    password = Capistrano::CLI.password_prompt
    commands = ""
    commands << "CREATE USER #{fetch(:user)} WITH PASSWORD #{fetch(:password)};"
    commands << "CREATE DATABASE primepress;"
    commands << "GRANT ALL PRIVELEGES ON DATABASE primepress TO #{fetch(:user)};"
    run "sudo -u postgres psql < #{commands.to_s}"

    database_template = <<-EOF
      production:
        database: primepress
        adapter: postgresql
        username: #{user}
        password: #{password}
        encoding: unicode
        host: localhost
        pool: 5
    EOF

    database_yml = ERB.new(database_template).result(binding)
    put database_yml, "#{fetch(:current_path)}/config/database.yml"
  end
end