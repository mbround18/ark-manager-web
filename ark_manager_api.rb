require 'grape'
require_relative 'ark_manager_scheduler'
class ArkManagerAPI < Grape::API
  version 'v1', using: :header, vendor: 'round18gaming'
  format :json
  prefix :api

  get :hello do
    { hello: 'world' }
  end

  post 'run-command' do
    if params.has_key? :cmd
      case
        when params.cmd == 'run_upgrades_and_reboot'
          ArkManagerScheduler.new('main').run_ark_manager_updates(params[:run_reboot_and_update_safely])
        # when params.cmd == ''
        # when params.cmd == ''
        # when params.cmd == ''
        # when params.cmd == ''
        else
          error!('401 Unauthorized', 401)
      end



      `arkmanager update --update-mods`
      'success'
    else
      error!('401 Unauthorized', 401)
    end
  end

  get :players do
    {
        player_count: `arkmanager status | grep "Active Players"`.tr('Active Players: ', '').strip
    }
  end

  get :status do
    ArkManagerScheduler.new.get_ark_manager_status
  end

  get 'schedule/states' do
    {
        mod_update_check_schedule: $dalli_cache.get('mod_update_check_schedule'),
        server_update_check_schedule: $dalli_cache.get('server_update_check_schedule')
    }
  end

  post 'schedule/states' do
    hash_param = params.to_hash
    puts hash_param
    mod_check = hash_param['mod_update_check_schedule']
    server_check = hash_param['server_update_check_schedule']
    unless mod_check.is_a?(Boolean)
      if mod_check == 'true'
        mod_check = true
      elsif mod_check == 'false'
        mod_check = false
      else
        puts 'A'
        error!('401 Unauthorized A', 401)
      end
    end

    unless server_check.is_a?(Boolean)
      if server_check == 'true'
        server_check = true
      elsif server_check == 'false'
        server_check = false
      else
        puts 'B'
        error!('401 Unauthorized', 401)
      end
    end

    $dalli_cache.set('mod_update_check_schedule', mod_check)
    $dalli_cache.set('server_update_check_schedule', server_check)
    File.write("#{WORKING_DIR}/config/schedules.json", "{\n\t\"mod_update_check_schedule\": #{mod_check},\n\t\"server_update_check_schedule\": #{server_check}\n}")
    'success'

  end

end