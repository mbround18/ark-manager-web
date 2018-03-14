require 'oga'
require 'open-uri'
require 'arkrb/server/mod'
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
      mod_info = Arkrb::Mod.new(mod_id)
      modified_config_mod_list << {
          id: mod_id,
          name: mod_info.name,
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
      mod_info = Arkrb::Mod.new(mod[:id])

      latest_update = Base64.encode64(mod_info.version_tag).strip
      if last_updated != latest_update
        $logger.warn("Mod version mismatch!!: #{last_updated} != #{latest_update}")
        mods_that_need_updates << {mod_id: mod[:id], latest_update: latest_update}
        mod[:name] = mod_info.name
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
    ark_server = SchedulerController.new
    ark_server.run_ark_manager_updates if ark_server.ark_server.update_available?[:update_available]
  end
end


$scheduler.every '15m', first_at: Time.now + 5 do
  if $dalli_cache.get('run_automatic_start')
    ark_server = SchedulerController.new.ark_server
    ark_server.start! unless ark_server.status!.fetch(:running, false)
  end
end