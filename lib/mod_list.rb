require 'json'
require 'arkrb/server/mod'
class ModList
  def initialize(path = File.join(File.expand_path('..', File.dirname(__FILE__)), 'config', 'mod_list.json'))
    @file_path = path
    @mod_list = load_file
  end

  attr :mod_list, :file_path

  def add_mod(mod_id)
    mod_info = mod_model(mod_id)
    @mod_list << {
        id: mod_id,
        name: mod_info.name,
        version: Base64.encode64('Mod Not Tracked Yet').gsub!(/\n/, ''),
        last_updated: Time.now.utc.strftime('%m%d%Y%H%M%S')
    }
    refresh
  end

  def delete_mod(id)
    @mod_list.delete_if {|m| m[:id].to_s == id.to_s }
    refresh
  end

  def refresh
    save_file
    load_file
  end

  def save_file
    File.write(@file_path, @mod_list.to_json)
  end

  def load_file
    file = File.read(@file_path)
    JSON.parse!(file, symbolize_names: true)
  end

  private

  def mod_model(mod_id)
    Arkrb::Mod.new(mod_id)
  end
end