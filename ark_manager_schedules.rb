require 'oj'
require 'json'
require 'dalli'
require 'base64'
require_relative 'ark_manager_scheduler'
WORKING_DIR = File.dirname(__FILE__) unless defined?(WORKING_DIR)
USER_HOME   = Dir.home unless defined?(USER_HOME)
CURL_EXEC   = find_executable 'curl'
EGREP_EXEC   = find_executable 'egrep'
ARK_MANAGER_CLI = find_executable('arkmanager', "#{USER_HOME}/bin") unless defined?(ARK_MANAGER_CLI)

$scheduler = Rufus::Scheduler.new unless defined?($scheduler)
$dalli_cache = Dalli::Client.new('localhost:11211', { :namespace => 'arkmanager_web', :compress => true }) unless defined?($dalli_cache)

$scheduler.every '1h', first_at: Time.now + 10 do
  config_mod_list = Oj.load_file("#{WORKING_DIR}/config/mod_list.json", Hash.new)
  modified_config_mod_list = config_mod_list
  fs_mod_list = Dir["#{USER_HOME}/ARK/ShooterGame/Content/Mods/*.mod"]
  fs_mod_list.map! {|mod| File.basename(mod).gsub!('.mod', '') }
  fs_mod_list.delete('111111111')
  fs_mod_list.each  do |mod_id|
    unless config_mod_list.has_key? mod_id
      modified_config_mod_list[mod_id] = Base64.encode64('Mod Not Tracked Yet').gsub!(/\n/, '')
    end
  end
  File.write("#{WORKING_DIR}/config/mod_list.json", modified_config_mod_list.to_json)
end

$scheduler.every '15m', first_at: Time.now + 15 do
  if $dalli_cache.get('mod_update_check_schedule')
    puts 'Running Mod Check Job'
    ark_mod_list = Oj.load_file("#{WORKING_DIR}/config/mod_list.json", Hash.new)
    mods_that_need_updates = []
    ark_mod_list.each_pair do |mod_id, last_updated|
      puts "Checking mod: #{mod_id}"
      latest_updates_list = `#{CURL_EXEC} https://steamcommunity.com/sharedfiles/filedetails/changelog/#{mod_id} | #{EGREP_EXEC} "Update:"`
      latest_updates_list.gsub!('</div>', '')
      latest_updates_list.gsub!( /\t/, '')
      latest_updates_list.gsub!('Update: ','')
      latest_updates_list.gsub!(/\r/ ,'')
      latest_update =  Base64.encode64(latest_updates_list.split("\n").first).gsub!(/\n/, '')
      if last_updated != latest_update
        puts "Mod version mismatch!!: #{last_updated} != #{latest_update}"
        mods_that_need_updates << {mod_id: mod_id, latest_update: latest_update}
        ark_mod_list[mod_id] =latest_update
      else
        puts "The following mod has passed the update check: #{mod_id}"
      end

    end if ark_mod_list.size != 0

    if mods_that_need_updates.count > 0
      puts 'Running Safe Update/Reboot'
      File.open("#{WORKING_DIR}/config/mod_list.json", 'w') do |f|
        f.write(ark_mod_list.to_json)
      end
      ArkManagerScheduler.new('main').run_ark_manager_updates
    end
  end
end

$scheduler.every '15m' do
  if $dalli_cache.get('server_update_check_schedule')
    status_info = ArkManagerScheduler.new('main').get_ark_manager_status
    if status_info[:server_build_id] != status_info[:available_version]
      ArkManagerScheduler.new('main').run_ark_manager_updates
    end
  end
end






