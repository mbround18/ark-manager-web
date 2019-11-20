require 'oga'
require 'open-uri'
require 'arkrb/server/mod'
require_relative '../config/environment'
require_relative '../agent/scheduler_controller'
require_relative 'mod_list'

$scheduler.every '1h', first_at: Time.now + 15 do

  mod_list = ModList.new
  mod_list.save_file
end

$scheduler.every '15m', first_at: Time.now + 15 do
  if $dalli_cache.get('mod_update_check_schedule')
    if $dalli_cache.get('reboot_required')
      $logger.info('Reboot required flag set to true! Skipping mod version check and running updates.')
      mod_list = ModList.new
      mod_list.mods.map! do |id|
        mod = Arkrb::Mod.new(id).to_h
        mod[:last_updated] = Time.now.utc.strftime('%m-%d-%Y %H:%M:%S')
      end
      mod_list.save_file
      SchedulerController.new.run_ark_manager_updates
    else
      $logger.info('Running Mod Check Job')
      mod_list = ModList.new
      ark_mod_list = mod_list.mods
      mods_that_need_updates = []
      ark_mod_list.each do |mod|
        last_updated = mod.fetch(:version_tag)
        $logger.info("Checking mod: #{mod[:id]}")
        mod_info = Arkrb::Mod.new(mod[:id])

        latest_update = Base64.encode64(mod_info.version_tag).strip
        if last_updated != latest_update
          $logger.warn("Mod version mismatch!!: #{last_updated} != #{latest_update}")
          mods_that_need_updates << {mod_id: mod[:id], latest_update: latest_update}
          mod[:name] = mod_info.name
          mod[:version_tag] = latest_update
          mod[:last_updated] = Time.now.utc.strftime('%m-%d-%Y %H:%M:%S')
        else
          $logger.info("The following mod has passed the update check: #{mod[:id]}")
        end
      end if ark_mod_list.size != 0

      if mods_that_need_updates.count > 0
        $logger.info('Running Safe Update/Reboot')
        mod_list.save_file
        # File.write("#{WORKING_DIR}/config/mod_list.json")
        # File.open(, 'w') do |f|
        #   f.write(ark_mod_list.to_json)
        # end
        SchedulerController.new.run_ark_manager_updates
      end
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
  if $dalli_cache.get('automated_start')
    ark_server = SchedulerController.new.ark_server
    ark_server.start! unless ark_server.status!.fetch(:running, false)
  end
end