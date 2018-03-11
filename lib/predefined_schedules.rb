require 'oga'
require 'open-uri'
require_relative '../config/environment'
require_relative '../api/scheduler_controller'

$scheduler.every '1h', first_at: Time.now + 15 do
  config_mod_list = SchedulerController.new.get_mod_status
  modified_config_mod_list = config_mod_list
  fs_mod_list = Dir["#{ARK_SERVER_ROOT}/ShooterGame/Content/Mods/*.mod"]
  fs_mod_list.map! {|mod| File.basename(mod).gsub!('.mod', '')}
  fs_mod_list.delete('111111111')
  fs_mod_list.each do |mod_id|
    # config_mod_list.find {|mod| mod[:id] == mod_id}
    if config_mod_list.find {|mod| mod[:id] == mod_id}.nil?
      document = Oga.parse_html(open('https://steamcommunity.com/sharedfiles/filedetails/changelog/731604991'))
      name = document.at_css('div[class="workshopItemTitle"]').text
      modified_config_mod_list << {
          id: mod_id,
          name: name,
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
    ark_mod_list.each do |mod|
      last_updated = mod.fetch(:version)
      $logger.info("Checking mod: #{mod[:id]}")
      document = Oga.parse_html(open('https://steamcommunity.com/sharedfiles/filedetails/changelog/731604991'))
      name = document.at_css('div[class="workshopItemTitle"]').text
      version = document.at_css('div[class~="workshopAnnouncement"]:nth-child(3) > div[class="headline"]').text.strip
      latest_update = Base64.encode64(version).strip
      if last_updated != latest_update
        $logger.warn("Mod version mismatch!!: #{last_updated} != #{latest_update}")
        mods_that_need_updates << {mod_id: mod[:id], latest_update: latest_update}
        mod[:name] = name
        mod[:version] = latest_update
        mod[:last_updated] = Time.now.utc.strftime('%m-%d-%Y %H:%M:%S')
      else
        $logger.info("The following mod has passed the update check: #{mod[:id]}")
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