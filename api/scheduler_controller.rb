require_relative '../config/environment'
class SchedulerController
  def initialize(instance=ARK_INSTANCE_NAME)
    @instance = instance

    @running_updates = File.exist?(File.join(TMP_DIR, 'running_updates.lock'))
  end

  def run_system_command(instance, command, std_out, std_err, detach_from_process=true)
    pid = spawn("#{ARK_MANAGER_CLI} #{command} @#{instance}", out: std_out, err: std_err)
    Process.detach(pid) if detach_from_process
    pid
  end

  def run_ark_manager_broadcast(delay='1s', message='boop', log_stdout='/dev/null', log_stderr='/dev/null')
    $scheduler.in delay do
      $logger.info("Broadcasting -- \"#{message}\"")
      run_system_command(@instance,"broadcast \"#{message}\"", log_stdout, log_stderr)
    end
  end

  def run_ark_manager_update(delay='3s', log_stdout='/dev/null', log_stderr='/dev/null')
    $logger.warn("Reboot has been scheduled to be triggered in: #{delay}")
    $scheduler.in delay do
      $logger.warn("Running reboot which was scheduled for: #{Time.now.utc.strftime('%m%d%Y%H%M%S')}")
      pid = run_system_command(@instance, 'update --update-mods', log_stdout, log_stderr)
      $dalli_cache.set('arkmanager_updates_running_pid', pid)
    end
  end

  def run_ark_manager_start_server(delay='3s', log_stdout='/dev/null', log_stderr='/dev/null')
    $scheduler.in delay do
      $logger.warn("The server has been started at: #{Time.now.utc.strftime('%m%d%Y%H%M%S')}")
      run_system_command(@instance, 'start', log_stdout, log_stderr)
    end
  end

  def run_ark_manager_stop_server(delay='3s', log_stdout='/dev/null', log_stderr='/dev/null')
    $scheduler.in delay do
      $logger.warn("The server has been stopped at: #{Time.now.utc.strftime('%m%d%Y%H%M%S')}")
      run_system_command(@instance, 'stop', log_stdout, log_stderr)
    end
  end

  def is_an_update_running?
    File.exist?(ARK_UPDATING_LOCK_PATH)
  end

  def create_update_running_lock!
    File.write(ARK_UPDATING_LOCK_PATH, '')
  end

  def run_ark_manager_updates(run_safely=true, log_stdout="#{WORKING_DIR}/log/ark_update.log.out", log_stderr="#{WORKING_DIR}/log/ark_update.log.err")
    run_safely = (run_safely.to_s == 'true')
    unless is_an_update_running?
      create_update_running_lock!
      if run_safely
        run_ark_manager_broadcast('3s',  'Server is updating/restarting in 30 minutes...',  log_stdout, log_stderr)
        run_ark_manager_broadcast('10m', 'Server is updating/restarting in 20 minutes..',  log_stdout, log_stderr)
        run_ark_manager_broadcast('20m', 'Server is updating/restarting in 10 minutes.',  log_stdout, log_stderr)
        run_ark_manager_broadcast('25m', 'Server is updating/restarting in 5 minutes!',     log_stdout, log_stderr)
        run_ark_manager_broadcast('26m', 'Server is updating/restarting in 4 minutes!!',    log_stdout, log_stderr)
        run_ark_manager_broadcast('27m', 'Server is updating/restarting in 3 minutes!!!',   log_stdout, log_stderr)
        run_ark_manager_broadcast('28m', 'Server is updating/restarting in 2 minutes!!!!',  log_stdout, log_stderr)
        run_ark_manager_broadcast('29m', 'Server is updating/restarting in 1 minutes!!!!!', log_stdout, log_stderr)
        run_ark_manager_update('30m',  log_stdout, log_stderr)
      else
        run_ark_manager_update('3s',  log_stdout, log_stderr)
      end
      $scheduler.in('30m') { File.delete(ARK_UPDATING_LOCK_PATH) }
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

  def get_mod_status
    file = File.read("#{WORKING_DIR}/config/mod_list.json")
    JSON.parse!(file, symbolize_names: true)
  end

  # def get_player_list(instance=@instance)
  #   final_hash = {}
  #   list_array = [`#{ARK_MANAGER_CLI} useconfig #{instance} rconcmd listplayers | sed '2d; $d; s/^ *//'`.split("\n")].flatten
  #   list_array.each do |player|
  #
  #   end
  # end

end