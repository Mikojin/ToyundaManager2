
# ==========================================================
# Author : Mikomi
# ==========================================================
# Version : 0.1
# Create : 2007/10/18
# Last version : 2007/10/18
# ==========================================================
# Filter Catalog
# ==========================================================
# Description :
# Contain all standard filter available in the application
# ==========================================================

puts "require FilterCatalog"

# ----------------------------------------------------------
require 'singleton'
require $root+ "Common"
require $root+ "filter/FilterGeneric"
# ----------------------------------------------------------

puts "++ FilterCatalog"

class FilterCatalog
	include Common
  include Singleton
  
	def initialize()
    @map = Hash.new
    @nameList = Array.new
    self << FilterAnd.new
    self << FilterOr.new
    self << FilterNot.new
    self << FilterNil.new
    self << FilterNotNil.new
    self << FilterEqual.new
    self << FilterDifferent.new
    self << FilterSuperior.new
    self << FilterInferior.new
    self << FilterContains.new
	end
	
  # add a filter to the catalog
  def <<(pFilter)
    @map[pFilter.name] = pFilter
    @nameList << pFilter.name
  end
  
  # return the filter for the given name
  def [](pName)
    return @map[pName]
  end
  
  def getList()
    #return @map.keys.sort
    return @nameList
  end
  
  # call the filter for the given name with the given parameters.
  def call(pName, pElement, pKey, pValue, pChildren)
    filter = @map[pName]
    if filter.nil?
      raise "Filter not found ["+pName+"]"
    end
    return filter.validate(pElement, pKey, pValue, pChildren)
  end
  
end

puts "-- FilterCatalog"
