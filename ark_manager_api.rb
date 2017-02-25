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
        when params.cmd == 'run_ark_manager_updates'
          params.has_key? :safely_update_ark
          ArkManagerScheduler.new('main').run_ark_manager_updates(params[:safely_update_ark])
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

  get '*' do
    halt 401, "Unauthorized/Incorrect URL.\nThis Service belongs to only authorized personel of Round 18 Gaming"
  end

end