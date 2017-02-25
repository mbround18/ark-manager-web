require 'mkmf'
require 'rufus-scheduler'
ARK_MANAGER_CLI = find_executable 'arkmanager' unless defined?(ARK_MANAGER_CLI)
$scheduler = Rufus::Scheduler.new unless defined?($scheduler)
class ArkManagerScheduler
  def initialize(instance='main')
    @instance = instance
  end

  def run_system_command(command, std_out, std_err, detach=true)
    pid = spawn("#{ARK_MANAGER_CLI} #{command}", out: std_out, err: std_err)
    Process.detect(pid) if detach
  end

  def run_ark_manager_broadcast(instance=@instance, delay='1s', message='boop', log_stdout='/dev/null', log_stderr='/dev/null')
    $scheduler.in delay do
      run_system_command(
          "useconfig #{instance} broadcast #{message}",
          log_stdout,
          log_stderr
      )
    end
  end

  def run_ark_manager_update(instance=@instance, delay='3s', update_mods=true, log_stdout='/dev/null', log_stderr='/dev/null')
    update_cmd = 'update'
    update_cmd + ' --update-mods' if update_mods
    $scheduler.in delay do
      run_system_command("useconfig #{instance} #{update_cmd}", log_stdout, log_stderr)
    end
  end

  def run_ark_manager_updates(run_safely=true, instance=@instance, log_stdout="#{WORKING_DIR}/log/ark_update.log.out", log_stderr="#{WORKING_DIR}/log/ark_update.log.err")
    if run_safely
      run_ark_manager_broadcast(instance, '3s',  'Server is updating/restarting in 30 minutes...',  log_stdout, log_stderr)
      run_ark_manager_broadcast(instance, '10m', 'Server is updating/restarting in 20 minutes...',  log_stdout, log_stderr)
      run_ark_manager_broadcast(instance, '20m', 'Server is updating/restarting in 10 minutes...',  log_stdout, log_stderr)
      run_ark_manager_broadcast(instance, '25m', 'Server is updating/restarting in 5 minutes!',     log_stdout, log_stderr)
      run_ark_manager_broadcast(instance, '26m', 'Server is updating/restarting in 4 minutes!!',    log_stdout, log_stderr)
      run_ark_manager_broadcast(instance, '27m', 'Server is updating/restarting in 3 minutes!!!',   log_stdout, log_stderr)
      run_ark_manager_broadcast(instance, '28m', 'Server is updating/restarting in 2 minutes!!!!',  log_stdout, log_stderr)
      run_ark_manager_broadcast(instance, '29m', 'Server is updating/restarting in 1 minutes!!!!!', log_stdout, log_stderr)
      run_ark_manager_update(instance, '30m', true,  log_stdout, log_stderr)
    else
      run_ark_manager_update(instance, '3s', true,  log_stdout, log_stderr)
    end
  end

  def get_ark_manager_status(instance=@instance)
    hash = {}
    status_array = `#{ARK_MANAGER_CLI} useconfig #{instance} status | egrep -Ei 'listening|build id|status|active|online|running'`.gsub!(/\e\[([;\d]+)?m/, '').split("\n")

    status_array.shift
    status_array.each do |element|
      arr = element.split(':')
      hash[arr[0].strip.downcase.tr(' ', '_').to_sym]=arr[1].strip
    end

    hash
  end

end