require 'grape'
require_relative 'scheduler_controller'
class ApiApp < Grape::API
  version 'v1', using: :header, vendor: 'round18gaming'
  format :json
  prefix :api

  get 'get-server-info' do
    {
        'server_ip_address': SERVER_IP_ADDRESS
    }
  end

  get 'mods/status' do
    SchedulerController.new('main').get_mod_status
  end

  post 'run-command' do
    $logger.debug("post received: #{params}")
    if params.has_key? :cmd
      case
      when params.cmd == 'run_reboot_and_update'
          SchedulerController.new('main').run_ark_manager_updates((params[:run_reboot_and_update_safely] == 'true'))
          if (params[:run_reboot_and_update_safely] == 'true')
            'The server has been restarted! The server was restarted in safemode which means it will restart in about 40 minutes. It will broadcast periodically for 30 minutes then run the reboot command which takes roughly 10 minutes to come online.'
          else
            'The server has been restarted! The server was not restarted safely which means it will be rebooted immediately this process however can take up to 10 minutes to start, so the web page wont update until the servers status changes.'
          end
        when params.cmd == 'start_server'
          SchedulerController.new('main').run_ark_manager_start_server
          'The server has been started! The server can take up to 10 minutes to start, so the web page wont update until the servers status changes.'
        when params.cmd == 'stop_server'
          SchedulerController.new('main').run_ark_manager_stop_server
          if $dalli_cache.get('run_automatic_start')
            "The server has been stopped! The web page may take a few minutes before that status is updated. Also because you have automatic start checked a schedule will start the server again. Please disable the automatic start if you'd like to keep the server offline."
          else
            'The server has been stopped! The web page may take a few minutes before that status is updated.'
          end
        # when params.cmd == ''
        # when params.cmd == ''
        # when params.cmd == ''
        # when params.cmd == ''
        else
          error!('401 Unauthorized', 401)
      end
    else
      error!('401 Unauthorized', 401)
    end
  end

  get :status do
    SchedulerController.new.get_ark_manager_status
  end

  get 'schedule/states' do
    {
        run_automatic_start: $dalli_cache.get('run_automatic_start'),
        mod_update_check_schedule: $dalli_cache.get('mod_update_check_schedule'),
        server_update_check_schedule: $dalli_cache.get('server_update_check_schedule')
    }
  end

  post 'schedule/states' do
    $logger.debug("post received: #{params}")
    hash_param = params.to_hash
    run_automated_start = (hash_param['run_automatic_start'] == 'true')
    mod_check = (hash_param['mod_update_check_schedule'] == 'true')
    server_check = (hash_param['server_update_check_schedule'] == 'true')

    $dalli_cache.set('run_automatic_start', run_automated_start)
    $dalli_cache.set('mod_update_check_schedule', mod_check)
    $dalli_cache.set('server_update_check_schedule', server_check)
    File.write("#{WORKING_DIR}/config/schedules.json", "{\n\t\"run_automatic_start\": #{run_automated_start},\n\t\"mod_update_check_schedule\": #{mod_check},\n\t\"server_update_check_schedule\": #{server_check}\n}")
    'success'
  end

end