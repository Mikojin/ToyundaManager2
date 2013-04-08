#!/usr/bin/env ruby

# ==========================================================
# Author : Mikomi
# ==========================================================
# Version : 0.1
# Create : 2007/05/10 
# Last version : 2007/05/11 
# ==========================================================
# Toyunda Manager Launcher Uncompress mode
# ==========================================================
# Description :
# Launch the Toyunda Manager Application.
# ==========================================================

$root = File.dirname(__FILE__) +"/ToyundaManagerMain/"

INFO_VERSION = '1.3'
INFO_AUTHOR = 'Mikomi'

$config_file = ARGV[0] if ARGV.size > 0

require $root + "application/ClientMIO"
