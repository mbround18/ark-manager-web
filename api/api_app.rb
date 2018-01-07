require 'json'
require 'grape'
require_relative 'scheduler_controller'
class ApiApp < Grape::API
	version 'v1', using: :header, vendor: 'gdz'
	format :json
	prefix :api

	get 'get-server-info' do
		{
			'server_ip_address': SERVER_IP_ADDRESS
		}
	end

	get 'mods/status' do
		SchedulerController.new.get_mod_status
	end

	post 'run-command' do
		$logger.debug("post received: #{params}")
		post_request = params
		post_request = post_request.symbolize_keys
		if post_request.has_key? :cmd
			case
				when post_request[:cmd] == 'run_reboot_and_update'
					SchedulerController.new.run_ark_manager_updates((post_request[:run_reboot_and_update_safely] == 'true'))
					if post_request[:run_reboot_and_update_safely] == 'true'
						'The server has been restarted! The server was restarted in safemode which means it will restart in about 40 minutes. It will broadcast periodically for 30 minutes then run the reboot command which takes roughly 10 minutes to come online.'
					else
						'The server has been restarted! The server was not restarted safely which means it will be rebooted immediately this process however can take up to 10 minutes to start, so the web page wont update until the servers status changes.'
					end
				when post_request[:cmd] == 'start_server'
					SchedulerController.new.run_ark_manager_start_server
					'The server has been started! The server can take up to 10 minutes to start, so the web page wont update until the servers status changes.'
				when post_request[:cmd] == 'stop_server'
					SchedulerController.new.run_ark_manager_stop_server
					if $dalli_cache.get('run_automatic_start')
						"The server has been stopped! The web page may take a few minutes before that status is updated. Also because you have automatic start checked a schedule will start the server again. Please disable the automatic start if you'd like to keep the server offline."
					else
						'The server has been stopped! The web page may take a few minutes before that status is updated.'
					end
				# when params[:cmd] == ''
				# when params[:cmd] == ''
				# when params[:cmd] == ''
				# when params[:cmd] == ''
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
		hash_param = JSON.parse!(params, symbolize_names: true)
		run_automated_start = (hash_param[:run_automatic_start] == 'true')
		mod_check = (hash_param[:mod_update_check_schedule] == 'true')
		server_check = (hash_param[:server_update_check_schedule] == 'true')

		$dalli_cache.set('run_automatic_start', run_automated_start)
		$dalli_cache.set('mod_update_check_schedule', mod_check)
		$dalli_cache.set('server_update_check_schedule', server_check)
		status_checks = {
			run_automated_start: run_automated_start,
			mod_update_check_schedule: mod_check,
			server_update_check_schedule: server_check
		}
		File.write("#{WORKING_DIR}/config/schedules.json", JSON.pretty_generate(status_checks) )
		'success'
	end

	get 'players/list' do

	end

end