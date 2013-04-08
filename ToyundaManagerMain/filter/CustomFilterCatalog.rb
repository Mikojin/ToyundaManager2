
# ==========================================================
# Author : Mikomi
# ==========================================================
# Version : 0.1
# Create : 2007/10/18
# Last version : 2007/10/18
# ==========================================================
# Custom Filter Catalog
# ==========================================================
# Description :
# Map of custom filter.
# Each instance of custom filter are given a name.
# ==========================================================


puts "require CustomFilterCatalog"

# ----------------------------------------------------------
# require 'singleton'
require $root+ "Common"
# require "filter/FilterGeneric"
# ----------------------------------------------------------

puts "++ CustomFilterCatalog"

class CustomFilterCatalog
	include Common
#  include Singleton
  
	def initialize()
    @map = Hash.new
	end
	
  # add a filter for the given name
  def []=(pName, pFilter)
    @map[pName] = pFilter
  end
  
  # return the filter for the given name
  def [](pName)
    return @map[pName]
  end
  
  # remove custom with the given name
  def remove(pName)
    @map.delete(pName)
  end
  
  # clear this custom filter catalog
  def clear()
    @map.clear
  end
  
  # return a sorted list of custom filter name
  def getList()
    return @map.keys.sort
  end
  
  def getFilterIndex(pName)
    return getList().index(pName)
  end
  
  def contains?(pName)
    return !@map[pName].nil?
  end
  
end

puts "-- CustomFilterCatalog"
