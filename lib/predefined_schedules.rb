require_relative '../config/environment'
require_relative '../api/scheduler_controller'

$scheduler.every '1h', first_at: Time.now + 15 do
	config_mod_list = SchedulerController.new.get_mod_status
	modified_config_mod_list = config_mod_list
	fs_mod_list = Dir["#{ARK_SERVER_ROOT}/ShooterGame/Content/Mods/*.mod"]
	fs_mod_list.map! { |mod| File.basename(mod).gsub!('.mod', '') }
	fs_mod_list.delete('111111111')
	fs_mod_list.each do |mod_id|
		unless config_mod_list.has_key? mod_id
			modified_config_mod_list[mod_id] = {
				version: Base64.encode64('Mod Not Tracked Yet').gsub!(/\n/, ''),
				last_updated: Time.now.utc.strftime('%m%d%Y%H%M%S')
			}
		end
	end
	File.write("#{WORKING_DIR}/config/mod_list.json", modified_config_mod_list.to_json)
end

$scheduler.every '15m', first_at: Time.now + 15 do
	if $dalli_cache.get('mod_update_check_schedule')
		$logger.info('Running Mod Check Job')
		ark_mod_list = SchedulerController.new.get_mod_status
		mods_that_need_updates = []
		ark_mod_list.each_pair do |mod_id, mod_info|
			last_updated = mod_info.fetch('version')
			$logger.info("Checking mod: #{mod_id}")
			latest_updates_list = `#{CURL_EXEC} --silent https://steamcommunity.com/sharedfiles/filedetails/changelog/#{mod_id} | #{EGREP_EXEC} "Update:"`
			latest_updates_list.gsub!('</div>', '')
			latest_updates_list.gsub!(/\t/, '')
			latest_updates_list.gsub!('Update: ', '')
			latest_updates_list.gsub!(/\r/, '')
			latest_update = Base64.encode64(latest_updates_list.split("\n").first).gsub!(/\n/, '')
			if last_updated != latest_update
				$logger.warn("Mod version mismatch!!: #{last_updated} != #{latest_update}")
				mods_that_need_updates << { mod_id: mod_id, latest_update: latest_update }
				ark_mod_list[mod_id] = {
					version: latest_update,
					last_updated: Time.now.utc.strftime('%m-%d-%Y %H:%M:%S')
				}
			else
				$logger.info("The following mod has passed the update check: #{mod_id}")
			end

		end if ark_mod_list.size != 0

		if mods_that_need_updates.count > 0
			$logger.info('Running Safe Update/Reboot')
			File.open("#{WORKING_DIR}/config/mod_list.json", 'w') do |f|
				f.write(ark_mod_list.to_json)
			end
			SchedulerController.new.run_ark_manager_updates
		end
	end
end

$scheduler.every '15m' do
	if $dalli_cache.get('server_update_check_schedule')
		status_info = SchedulerController.new.get_ark_manager_status
		if status_info[:server_build_id] != status_info[:available_version]
			SchedulerController.new.run_ark_manager_updates
		end
	end
end


$scheduler.every '15m', first_at: Time.now + 5 do
	if $dalli_cache.get('run_automatic_start')
		status_info = SchedulerController.new.get_ark_manager_status
		if status_info.fetch(:server_running, 'no') == 'no'
			SchedulerController.new.run_ark_manager_start_server
		end
	end
end