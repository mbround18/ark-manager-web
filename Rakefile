require 'rake'
require 'mkmf'
puts '============== Executable Loads =============='
WORKING_DIR = File.dirname(__FILE__) unless defined?(WORKING_DIR)
USER_HOME   = Dir.home unless defined?(USER_HOME)
BASH_EXEC   = find_executable 'bash'
CURL_EXEC   = find_executable 'curl'
ARK_MANAGER_CLI = find_executable('arkmanager', "#{USER_HOME}/bin") unless defined?(ARK_MANAGER_CLI)
puts '==================== Tasks/Output ==================='

directory 'tmp'
directory 'log'

desc 'Install Server Tools'
namespace :install do
  task :server_tools do
    server_tools_install_sh_path = "#{WORKING_DIR}/tmp/server_tools_install.sh"
    File.delete(server_tools_install_sh_path) if File.exist?(server_tools_install_sh_path)

    `#{CURL_EXEC} -sL http://git.io/vtf5N > #{server_tools_install_sh_path}`
    `#{BASH_EXEC} #{server_tools_install_sh_path} --me --perform-user-install`

    unless find_executable('arkmanager', "#{USER_HOME}/bin")
      File.open("#{USER_HOME}/.bashrc", 'a') do |file|
        file.write "export PATH=$PATH:#{File.expand_path(USER_HOME + '/bin')}"
      end
      puts 'Arkmanager was successfully added to your path' if find_executable('arkmanager', "#{USER_HOME}/bin")
    end
    raise 'arkmanager was not successfully added to your path' unless find_executable('arkmanager', "#{USER_HOME}/bin")
  end

  desc 'Install Ark Server with Server Tools'
  task :ark_server do
    if find_executable('arkmanager', "#{USER_HOME}/bin")
      puts 'Ignore the errors the program will fix them!!'
      system(ARK_MANAGER_CLI, 'install', out: $stdout, err: :out)
    else
      raise 'arkmanager is currently not in your path!!!! please run "bundle exec rake install_server_tools"'
    end

    puts

    File.open("#{WORKING_DIR}/config/mod_list.json", 'w') do |file|
      file.write "{\n}"
    end

  end
end