require 'json'
require 'arkrb/server/mod'
require_relative '../config/environment'
MOD_LIST_PATH = File.join(File.expand_path('..', File.dirname(__FILE__)), 'config', 'mod_list.json')
class ModList
  include Enumerable

  def initialize(mods = build_mod_list)
    @mods = mods
    save_file
  end

  attr :mods

  def each &block
    @mods.each(&block)
  end

  def add_mod(mod_id)
    mod_info = mod_model(mod_id)
    mod_info.version_tag = Base64.encode64('Mod Not Tracked Yet').gsub!(/\n/, '')
    @mods << mod_info
    refresh
  end

  def delete_mod(id)
    @mods.delete_if {|m| m[:id].to_s == id.to_s}
    refresh
  end

  def refresh
    save_file
    load_file
  end

  def save_file
    File.write(MOD_LIST_PATH, @mods.to_json)
  end

  def load_file
    file = File.read(MOD_LIST_PATH)
    JSON.parse!(file, symbolize_names: true)
  end

  private

  def mod_model(mod_id)
    Arkrb::Mod.new(mod_id)
  end

  def get_installed_mod_ids
    fs_mod_list = Dir["#{ARK_SERVER_ROOT}/ShooterGame/Content/Mods/*.mod"]
    fs_mod_list
    fs_mod_list.map! {|mod| File.basename(mod).gsub!('.mod', '')}
    fs_mod_list.delete('111111111')
    fs_mod_list.map! {|i| i.to_i}
  end

  def build_mod_list
    if File.exist?(MOD_LIST_PATH)
      File.zero?(MOD_LIST_PATH) ? mod_list = [] : mod_list = load_file
      (get_installed_mod_ids - mod_list.map {|m| m[:id].to_i}).each do |id|
        mod = Arkrb::Mod.new(id).to_h
        mod[:last_updated] = Time.now.utc.strftime('%m-%d-%Y %H:%M:%S')
        mod_list << mod
      end
      mod_list
      else
      get_installed_mod_ids.map! do |id|
        mod = Arkrb::Mod.new(id).to_h
        mod[:last_updated] = Time.now.utc.strftime('%m-%d-%Y %H:%M:%S')
      end
      end

  end
end