require 'mkmf'
require 'dalli'
require 'rufus-scheduler'
WORKING_DIR = File.dirname(__FILE__) unless defined?(WORKING_DIR)
USER_HOME   = Dir.home unless defined?(USER_HOME)
ARK_MANAGER_CLI = find_executable('arkmanager', "#{USER_HOME}/bin") unless defined?(ARK_MANAGER_CLI)
$scheduler = Rufus::Scheduler.new unless defined?($scheduler)
$dalli_cache = Dalli::Client.new('localhost:11211', { :namespace => 'arkmanager_web', :compress => true }) unless defined?($dalli_cache)
class ArkManagerScheduler
  def initialize(instance='main')
    @instance = instance
  end

  def run_system_command(instance, command, std_out, std_err, detach_from_process=true)
    pid = spawn("#{ARK_MANAGER_CLI} useconfig #{instance} #{command}", out: std_out, err: std_err)
    Process.detach(pid) if detach_from_process
    pid
  end

  def run_ark_manager_broadcast(delay='1s', message='boop', log_stdout='/dev/null', log_stderr='/dev/null')
    $scheduler.in delay do
      run_system_command(@instance,"broadcast #{message}", log_stdout, log_stderr)
    end
  end

  def run_ark_manager_update(delay='3s', update_mods=true, log_stdout='/dev/null', log_stderr='/dev/null')
    update_cmd = 'update'
    update_cmd + ' --update-mods' if update_mods
    $scheduler.in delay do
      pid = run_system_command(@instance, "#{update_cmd}", log_stdout, log_stderr)
      $dalli_cache.set('arkmanager_updates_running', pid)
    end
  end

  def run_ark_manager_start_server(delay='3s', log_stdout='/dev/null', log_stderr='/dev/null')
    $scheduler.in delay do
      run_system_command(@instance, 'start', log_stdout, log_stderr)
    end
  end

  def run_ark_manager_stop_server(delay='3s', log_stdout='/dev/null', log_stderr='/dev/null')
    $scheduler.in delay do
      run_system_command(@instance, 'start', log_stdout, log_stderr)
    end
  end

  def is_an_update_running?
    begin
      Process.getpgid( $dalli_cache.get('arkmanager_updates_running') )
      true
    rescue
      false
    end
  end

  def run_ark_manager_updates(run_safely=true, log_stdout="#{WORKING_DIR}/log/ark_update.log.out", log_stderr="#{WORKING_DIR}/log/ark_update.log.err")
    if run_safely == 'true'
      run_safely = true
    elsif run_safely == 'false'
      run_safely = false
    end

    unless is_an_update_running?
      if run_safely
        run_ark_manager_broadcast('3s',  'Server is updating/restarting in 30 minutes...',  log_stdout, log_stderr)
        run_ark_manager_broadcast('10m', 'Server is updating/restarting in 20 minutes...',  log_stdout, log_stderr)
        run_ark_manager_broadcast('20m', 'Server is updating/restarting in 10 minutes...',  log_stdout, log_stderr)
        run_ark_manager_broadcast('25m', 'Server is updating/restarting in 5 minutes!',     log_stdout, log_stderr)
        run_ark_manager_broadcast('26m', 'Server is updating/restarting in 4 minutes!!',    log_stdout, log_stderr)
        run_ark_manager_broadcast('27m', 'Server is updating/restarting in 3 minutes!!!',   log_stdout, log_stderr)
        run_ark_manager_broadcast('28m', 'Server is updating/restarting in 2 minutes!!!!',  log_stdout, log_stderr)
        run_ark_manager_broadcast('29m', 'Server is updating/restarting in 1 minutes!!!!!', log_stdout, log_stderr)
        run_ark_manager_update('30m', true,  log_stdout, log_stderr)
      else
        run_ark_manager_update('3s', true,  log_stdout, log_stderr)
      end
    end

  end

  def get_ark_manager_status(instance=@instance)
    hash = {}
    status_array = `#{ARK_MANAGER_CLI} useconfig #{instance} status | egrep -Ei 'listening|build id|status|active|online|running'`.gsub!(/\e\[([;\d]+)?m/, '').split("\n")
    update_info_array = `#{ARK_MANAGER_CLI} useconfig #{instance} checkupdate | egrep -Ei 'Available'`.gsub!(/\e\[([;\d]+)?m/, '').split("\n")
    status_array.shift
    status_array.concat(update_info_array)
    status_array.each do |element|
      arr = element.split(':')
      hash[arr[0].strip.downcase.tr(' ', '_').to_sym]=arr[1].strip.downcase
    end

    hash
  end

end



