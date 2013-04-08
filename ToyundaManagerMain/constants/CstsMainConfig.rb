
# ==========================================================
# Author : Mikomi
# ==========================================================
# Version : 0.1
# Create : 2007/05/10 
# Last version : 2007/05/13
# ==========================================================
# Constants Karaoke module
# ==========================================================
# Description :
# Contains constants for the Karaoke class
# ==========================================================

puts "require CstsMainConfig"

# ----------------------------------------------------------
require $root+ "helper/Property.rb"
# ----------------------------------------------------------


puts "++ CstsMainConfig"

module CstsMainConfig

  # ====================
  # MAIN Config
  
  # config file : either the given file in program parameters or the default value
  CONFIG_INI = ($config_file  || 'config.ini')

  # config path for saved data (like profile info etc.)
  CONFIG_PATH = 'config_path'
  # debug level displayed in the console (users should set this to 0)
  DEBUG = 'debug'
  # debug level written in the log file
  DEBUG_FILE = 'debug_file'
  # log file name (and/or absolute path
  LOG_FILE_NAME = 'log_file'
  
  def CstsMainConfig::iniMainConfig()
    needSave = false
    configMap = Property::load(CONFIG_INI)
    if configMap.nil?
      needSave = true
      configMap = Hash.new
    end
    # default config
    if configMap[CONFIG_PATH].nil?
      needSave = true
      configMap[CONFIG_PATH] = 'config'
    end
    
    if configMap[DEBUG].nil?
      needSave = true
      configMap[DEBUG] = 0
    else
      # convert value in integer
      configMap[DEBUG] = configMap[DEBUG].to_i
    end

    if configMap[DEBUG_FILE].nil?
      needSave = true
      configMap[DEBUG_FILE] = 500
    else
      # convert value in integer
      configMap[DEBUG_FILE] = configMap[DEBUG_FILE].to_i
    end
    
    if configMap[LOG_FILE_NAME].nil?
      needSave = true
      configMap[LOG_FILE_NAME] = 'debug.log'
    end

    # save if necessary
    Property::save(CONFIG_INI, configMap) if needSave
    return configMap
  end
  
  MAP = CstsMainConfig::iniMainConfig()
  
end

puts "-- CstsMainConfig"
