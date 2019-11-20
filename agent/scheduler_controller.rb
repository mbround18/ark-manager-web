require 'arkrb/server'
require_relative '../config/environment'
class SchedulerController
  def initialize(instance = ARK_INSTANCE_NAME)
    @instance = instance
    @running_updates = File.exist?(File.join(TMP_DIR, 'running_updates.lock'))
  end

  # @return [Arkrb::Server]
  def ark_server
    @ark_server ||= Arkrb::Server.new(@instance)
  end

  def mod_list
    @mod_list ||= ModList.new
  end

  # @deprecated
  def run_system_command(instance, command, std_out, std_err, detach_from_process = true)
    pid = spawn("#{ARK_MANAGER_CLI} #{command} @#{instance}", out: std_out, err: std_err)
    Process.detach(pid) if detach_from_process
    pid
  end

  def run_ark_manager_broadcast(delay = '1s', message = 'boop')
    $scheduler.in delay do
      $logger.info("Broadcasting -- \"#{message}\"")
      ark_server.broadcast(message)
    end
  end

  def run_ark_manager_update(delay = '3s')
    $logger.warn("Reboot has been scheduled to be triggered in: #{delay}")
    $scheduler.in delay do
      $logger.warn("Running reboot which was scheduled for: #{Time.now.utc.strftime('%m%d%Y%H%M%S')}")
      ark_server.update!(true)
    end
  end

  def run_ark_manager_start_server(delay = '3s')
    $scheduler.in delay do
      $logger.warn("The server has been started at: #{Time.now.utc.strftime('%m%d%Y%H%M%S')}")
      # run_system_command(@instance, 'start', log_stdout, log_stderr)
      $dalli_cache.set('reboot_required', false) unless ark_server.status![:running]
      ark_server.start!
    end
  end

  def run_ark_manager_stop_server(delay = '3s')
    $scheduler.in delay do
      $logger.warn("The server has been stopped at: #{Time.now.utc.strftime('%m%d%Y%H%M%S')}")
      ark_server.stop!
    end
  end

  def is_an_update_running?
    File.exist?(ARK_UPDATING_LOCK_PATH)
  end

  def create_update_running_lock!
    File.write(ARK_UPDATING_LOCK_PATH, '')
  end

  def run_ark_manager_updates(run_safely = true)
    run_safely = (run_safely.to_s == 'true')
    unless is_an_update_running?
      create_update_running_lock!
      if run_safely
        begin
          ark_server.broadcast('Server is updating/restarting in 30 minutes...')
        rescue Arkrb::Error::ServerOffline
          File.delete(ARK_UPDATING_LOCK_PATH)
          $logger.warn('The server appears to be offline! Running updates outside of scheduler')
          $dalli_cache.set('reboot_required', false)
          ark_server.stop!
          return ark_server.update!(true)
        end
        run_ark_manager_broadcast('3s', 'Server is updating/restarting in 30 minutes...')
        run_ark_manager_broadcast('10m', 'Server is updating/restarting in 20 minutes..')
        run_ark_manager_broadcast('20m', 'Server is updating/restarting in 10 minutes.')
        run_ark_manager_broadcast('25m', 'Server is updating/restarting in 5 minutes!')
        run_ark_manager_broadcast('26m', 'Server is updating/restarting in 4 minutes!!')
        run_ark_manager_broadcast('27m', 'Server is updating/restarting in 3 minutes!!!')
        run_ark_manager_broadcast('28m', 'Server is updating/restarting in 2 minutes!!!!')
        run_ark_manager_broadcast('29m', 'Server is updating/restarting in 1 minutes!!!!!')
        run_ark_manager_update('30m')
        $scheduler.in('30m') {
          File.delete(ARK_UPDATING_LOCK_PATH)
          $dalli_cache.set('reboot_required', false)
        }
      else
        $scheduler.in('3s') {
          $dalli_cache.set('reboot_required', false)
          ark_server.stop! rescue Arkrb::Error::ServerAlreadyStopped
          ark_server.update!(true)
          File.delete(ARK_UPDATING_LOCK_PATH)
        }
      end
    end
  end

  def get_ark_manager_status
    ark_server.status!
  end

  def get_player_list
    ark_server.get_player_list.map {|p| p.to_h}
  end

  def get_mod_status
    mod_list.mods
    # ModList.new.load_file
    # file = File.read("#{WORKING_DIR}/config/mod_list.json")
    # JSON.parse!(file, symbolize_names: true)
  end

  def install_mod(id)
    mod_list.add_mod(id)
    ark_server.install_mod(id)
    ark_server.enable_mod(id)
    mod_list.save_file
    $dalli_cache.set('reboot_required', true)
    true
  rescue => e
    e
  end

  # def get_player_list(instance=@instance)
  #   final_hash = {}
  #   list_array = [`#{ARK_MANAGER_CLI} useconfig #{instance} rconcmd listplayers | sed '2d; $d; s/^ *//'`.split("\n")].flatten
  #   list_array.each do |player|
  #
  #   end
  # end

end