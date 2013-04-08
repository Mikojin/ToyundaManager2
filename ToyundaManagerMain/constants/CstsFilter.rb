
# ==========================================================
# Author : Mikomi
# ==========================================================
# Version : 0.1
# Create : 2007/05/10 
# Last version : 2007/05/13
# ==========================================================
# Constants Filter module
# ==========================================================
# Description :
# Contains constants for the Filter classes.
# Essencialy name of filter
# ==========================================================

puts "++ CstsFilter"

module CstsFilter
  
  # Node
  F_AND = 'And'
  F_OR = 'Or'
  F_NOT = 'Not'

  # Leaves
  F_NIL = 'Nil?'
  F_NOT_NIL = 'Not nil'
  F_EQUAL = '='
  F_DIFFERENT = '!='
  F_SUPERIOR = '>'
  F_INFERIOR = '<'
  F_CONTAINS = 'Contains'
  
end

puts "-- CstsFilter"
