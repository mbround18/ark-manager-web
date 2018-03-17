require 'json'
require 'grape'
require_relative 'scheduler_controller'
require_relative '../lib/mod_list'
class ApiApp < Grape::API
  version 'v1', using: :header, vendor: 'gdz'
  format :json
  prefix :api

  helpers do

    # @return [SchedulerController]
    def scheduler_controller
      @scheduler_controller ||= SchedulerController.new
    end

  end

  get 'get-server-info' do
    {
        'server_ip_address': SERVER_IP_ADDRESS
    }
  end

  resource :server do
    post :start do
      begin
        scheduler_controller.ark_server.start!

        {
            status: 'success',
            message: 'The server has been started! The server can take up to 10 minutes to start, so the web page wont update until the servers status changes.'
        }
      rescue Arkrb::Error::ServerAlreadyRunning
        {
            status: 'error',
            message: 'The server has already been started! Please hang tight while it is booting up...'
        }
      end
    end

    post :stop do
      scheduler_controller.ark_server.stop!
      response = {status: 'success'}
      if $dalli_cache.get('run_automatic_start')
        response[:message] = "The server has been stopped! The web page may take a few minutes before that status is updated. Also because you have automatic start checked a schedule will start the server again. Please disable the automatic start if you'd like to keep the server offline."
      else
        response[:message] = 'The server has been stopped! The web page may take a few minutes before that status is updated.'
      end
      response
    end

    post :restart do
      scheduler_controller.ark_server.restart!
      {
          status: 'success',
          message: 'The server has been restarted! The server can take up to 10 minutes to start back up again.'
      }
    end

    params do
      requires :safely, type: Boolean, desc: 'Safely upgrade', default: true
    end
    post :upgrade do
      scheduler_controller.run_ark_manager_updates(params[:safely])
      response = {status: 'success'}
      if params[:safely]
        response[:message] = 'The server has been restarted! The server was restarted in safemode which means it will restart in about 40 minutes. It will broadcast periodically for 30 minutes then run the reboot command which takes roughly 10 minutes to come online.'
      else
        response[:message] = 'The server has been restarted! The server was not restarted safely which means it will be rebooted immediately this process however can take up to 10 minutes to start, so the web page wont update until the servers status changes.'
      end
      response
    end
  end

  resource :mods do

    desc 'Return the current mods.'
    get :status do
      scheduler_controller.get_mod_status
    end

    desc 'Installs a mod'
    params do
      requires :id, type: Integer, desc: 'Mod Id'
    end
    post :install do
      scheduler_controller.install_mod(params[:id])
      {status: 'success', message: "Success installing #{params[:id]}! Note with Mod Schedule enabled the server will schedule an automatic reboot in 30-45min. If you have it disabled you will have to manually reboot for the mod to fully be installed."}
    end
  end

  resource :players do

    desc 'Return the current list of players'
    get :list do
      begin
        scheduler_controller.get_player_list
      rescue Arkrb::Error::ServerOffline
        [{
             name: 'Loading...',
             steam_id: 'Loading...',
             player_id: 'Loading...'
         }]
      end
    end

  end

  # post 'run-command' do
  #   $logger.debug("post received: #{params}")
  #   post_request = params
  #   post_request = post_request.symbolize_keys
  #   if post_request.has_key? :cmd
  #     case
  #       when post_request[:cmd] == 'run_reboot_and_update'
  #         scheduler_controller.run_ark_manager_updates((post_request[:run_reboot_and_update_safely] == 'true'))
  #         if post_request[:run_reboot_and_update_safely] == 'true'
  #           'The server has been restarted! The server was restarted in safemode which means it will restart in about 40 minutes. It will broadcast periodically for 30 minutes then run the reboot command which takes roughly 10 minutes to come online.'
  #         else
  #           'The server has been restarted! The server was not restarted safely which means it will be rebooted immediately this process however can take up to 10 minutes to start, so the web page wont update until the servers status changes.'
  #         end
  #       when post_request[:cmd] == 'start_server'
  #         scheduler_controller.run_ark_manager_start_server
  #         'The server has been started! The server can take up to 10 minutes to start, so the web page wont update until the servers status changes.'
  #       when post_request[:cmd] == 'stop_server'
  #         scheduler_controller.run_ark_manager_stop_server
  #         if $dalli_cache.get('run_automatic_start')
  #           "The server has been stopped! The web page may take a few minutes before that status is updated. Also because you have automatic start checked a schedule will start the server again. Please disable the automatic start if you'd like to keep the server offline."
  #         else
  #           'The server has been stopped! The web page may take a few minutes before that status is updated.'
  #         end
  #       when post_request[:cmd] == 'broadcast'
  #       when post_request[:cmd] == 'save_world'
  #       when post_request[:cmd] == 'backup'
  #       else
  #         error!('401 Unauthorized', 401)
  #     end
  #   else
  #     error!('401 Unauthorized', 401)
  #   end
  # end

  get :status do
    scheduler_controller.ark_server.status!
  end

  get 'schedule/states' do
    hashh = {
        automated_start: $dalli_cache.get('automated_start'),
        mod_update_check_schedule: $dalli_cache.get('mod_update_check_schedule'),
        server_update_check_schedule: $dalli_cache.get('server_update_check_schedule')
    }
    $dalli_cache.set('automated_start', true) if hashh[:automated_start].nil?
    $dalli_cache.set('mod_update_check_schedule', true) if hashh[:mod_update_check_schedule].nil?
    $dalli_cache.set('server_update_check_schedule', true) if hashh[:server_update_check_schedule].nil?
    hashh
  end

  params do
    requires :automated_start, type: Boolean, desc: 'Run automatic start', default: true
    requires :mod_update_check_schedule, type: Boolean, desc: 'Run mod update checker', default: true
    requires :server_update_check_schedule, type: Boolean, desc: 'Run server update checker', default: true
  end
  post 'schedule/states' do
    $logger.debug("post received: #{params}")
    json = JSON.parse!(params.to_json, symbolize_names: true)
    $dalli_cache.set('automated_start', json[:automated_start])
    $dalli_cache.set('mod_update_check_schedule', json[:mod_update_check_schedule])
    $dalli_cache.set('server_update_check_schedule', json[:server_update_check_schedule])

    File.write("#{WORKING_DIR}/config/schedules.json", JSON.pretty_generate(json))
    'success'
  end

end