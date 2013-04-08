
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

puts "require CstsConfigManager"

# ----------------------------------------------------------
require $root+ "constants/CstsMainConfig"
# ----------------------------------------------------------


puts "++ CstsConfigManager"

module CstsConfigManager

  # ====================
  # MAIN Config
  CONFIG_PATH = CstsMainConfig::MAP[CstsMainConfig::CONFIG_PATH]+"/"
  
  puts "CONFIG_PATH = "+CONFIG_PATH
  
  # ====================

  PROFILE_CONFIG_FILE = 'config.ini'
  PROFILE_DATA_FILE = 'data.csv'
  PROFILE_FILTER_FILE = 'filter.dat'
  PROFILE_STYLE_FILE = 'style.csv'
  PROFILE_CURRENT_PLAYLIST_FILE = 'last.ini'

  CONFIG_SUFFIXE = '_config.ini'
  DATA_SUFFIXE = '_data.csv'
  FILTER_SUFFIXE = '_filter.dat'
  STYLE_SUFFIXE = '_style.csv'
  CURRENT_PLAYLIST_SUFFIXE = '_last.ini'
  #~ COLUMN_SUFFIXE = '_column.dat'
  PLAYLIST_EXT = '.m3u'
  PLAYLIST_BACKUP = 'playlist'
  PLAYLIST_RESUME = 'resume'
  
  # ====================
  
  
  INI_FILE_PATH = 'ini_file_path'
  VIDEO_FILE_PATH = 'video_file_path'
  LYRICS_FILE_PATH = 'lyrics_file_path'
  PLAYLIST_FILE_NAME = 'playlist_file_name'
  BACKUP_FILE_PATH = 'backup_file_path'
  BACKUP_DATA_NUMBER = 'bakcup_data_number'
  MAX_BACKUP_DATA_NUMBER = 'max_bakcup_data_number'

  MPLAYER_TOYUNDA_EXE = 'mplayer_toyunda_exe'

  OS_SELECTED = 'os_selected'
  OS_WINDOWS_LBL = 'os_windows_lbl'
  OS_UNIX_LBL = 'os_unix_lbl'
  SEPARATOR_WINDOWS = 'separator_windows'
  SEPARATOR_UNIX = 'separator_unix'
  
  MPLAYER_OPTION = 'mplayer_option'
  FULL_SCREEN = 'full_screen'
  
  LAST_EXPORT_FILE_NAME = 'last_export_file_name'
  LAST_IMPORT_FILE_NAME = 'last_import_file_name'
  LAST_EXPORT_PLAYLIST_FILE_NAME = 'last_export_playlist_file_name'
  LAST_IMPORT_PLAYLIST_FILE_NAME = 'last_import_playlist_file_name'
  LAST_IMPORT_CONFIG_FILE_NAME = 'last_import_config_file_name'

  ALLOW_MULTIPLE_ENTRY = 'allow_multiple_entry'
  
  SAVE_ON_CLOSE = 'save_on_close'
  LAUNCH_ON_GENERATE = 'launch_on_generate'
  SHUFFLE_ON_GENERATE = 'shuffle_on_generate'
  
  COLUMN_ORDER = 'column_order'
  COLUMN_DISPLAY = 'column_display'
  COLUMN_STYLE_DEFAULT = 'column_style_default'
  COLUMN_STYLE_SELECTED = 'column_style_selected'
  
  PLAYLIST_DISPLAY_VERTICAL = 'playlist_display_vertical'
  PLAYLIST_SEPARATOR_POSITION = 'playlist_separator_position'
  
  LINE_NUMBER_SELECT_TITLE = 'line_number_select_title'
  LINE_NUMBER_CURRENT_PLAYLIST = 'line_number_current_playlist'

  CURRENT_FILTER = 'current_filter'
  
  # context
  TOTAL_USED_TITLE = 'total_used_title'
  
  # MIO
  MIO_LOGGER = 'MIO_logger'
end

puts "-- CstsConfigManager"
