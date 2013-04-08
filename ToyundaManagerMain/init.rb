#!/usr/bin/env ruby

# ==========================================================
# Author : Mikomi
# ==========================================================
# Version : 0.1
# Create : 2007/05/10 
# Last version : 2007/05/11 
# ==========================================================
# Toyunda Manager Launcher
# ==========================================================
# Description :
# Launch the Toyunda Manager Application.
# Require libglade2 and GTK+ to work.
# ==========================================================


puts "init ToyundaManangerMain"

# ----------------------------------------------------------
# Debug / Globale log
# ----------------------------------------------------------

require $root+ "constants/CstsMainConfig"

$debug = CstsMainConfig::MAP[CstsMainConfig::DEBUG]
puts("debugConsole = "+$debug.to_s)
$debugFile = CstsMainConfig::MAP[CstsMainConfig::DEBUG_FILE]
puts("debugFile = "+$debugFile.to_s)
$log = File.open(CstsMainConfig::MAP[CstsMainConfig::LOG_FILE_NAME], 'w')
puts("log file = "+CstsMainConfig::MAP[CstsMainConfig::LOG_FILE_NAME].to_s)

alias :old_puts :puts
if $debug <= 0
  def puts(pString)
    # delete console output
  end
end

# override the standard puts method to print log only if debug is active
def puts_console(pString)
  #~ $log.puts(pString) if $debugFile > 0
  old_puts(pString)
  #~ if $debug > 0

  #~ if $debug > 0
    #~ old_puts(pString) if $debug > 1
  #~ end
end
def puts_file(pString)
  $log.puts(pString) 
  #~ if $debugFile > 0
end

# ----------------------------------------------------------

puts "require ToyundaManangerMain"

# ----------------------------------------------------------
require $root + "gui/ToyundaManagerGUI.rb"
# ----------------------------------------------------------

puts "++ ToyundaManangerMain"
begin
  # Main program 
  Gtk.init
  toyundaManager = GUI::ToyundaManagerGUI.new()
  toyundaManager.start()
  Gtk.main

puts "-- ToyundaManangerMain"
rescue Exception => err
  puts err.to_s
  puts "    "+err.backtrace.join("\n    ")
ensure
  puts "closing log file"
  $log.close
end

