
# ==========================================================
# Author : Mikomi
# ==========================================================
# Version : 0.1
# Create : 2007/10/18
# Last version : 2007/10/18
# ==========================================================
# Filter invoqueur
# ==========================================================
# Description :
# Definition of a filter call / invocation.
# Contains the name of the filter to call, key, value
# and children for this filter.
# ==========================================================


puts "require Filter"

# ----------------------------------------------------------
require $root+ "Common"
require $root+ "filter/FilterCatalog"
# ----------------------------------------------------------

puts "++ Filter"

class Filter
	include Common
  
  #=====================================================
  # Instance
  #=====================================================
  attr_accessor :filter, :key, :value
  
	def initialize(pFilter=nil, pKey=nil, pValue=nil)
		@children = Array.new
    @filter = getNilIfEmpty(pFilter)
    @key = getNilIfEmpty(pKey)
    self.value = getNilIfEmpty(pValue)
	end
  
  def value=(pValue)
    if isNumber(pValue)
      @value = pValue.to_i
    else
      @value = pValue
    end
  end
	
  def getNilIfEmpty(pValue)
    return nil if pValue.to_s =~ /^\s*$/
    return pValue
  end
  
  # return a new instance of this filter.
  # clone all the children of this filter
  def duplicate()
    newFilter = Filter.new(@filter, @key, @value)
    self.each_children() { |bChild|
      newChild = bChild.duplicate()
      newFilter << newChild
    }
    return newFilter
  end
  
	# add a sub filter
	def <<(pFilter)
		@children << pFilter
	end
	
  # remove a sub filter
  def remove(pFilter)
    @children.delete(pFilter)
  end
  
  # remove all children
  def clear_children()
    @children.clear()
  end
  
  # execute the given action on each children
  def each_children(&action)
    @children.each { |bChild|
      action.call(bChild)
    }
  end
  
  # return if this filter is a leaf or not
  def isLeaf()
    return false if @filter.nil?
    filter = FilterCatalog.instance[@filter]
    return false if filter.nil?
    return filter.isLeaf()
  end
  
  # test if this filter is consistant
  # node should have children and leaf shouldn't
  def isChildrenOK()
    return (isLeaf() == @children.empty?) 
  end
  
  # leaf should have a key
  def isKeyOK()
    return (isLeaf() == !@key.nil? )
  end
  
  # leaf should have a value
  def isValueOK()
    return (isLeaf() == !@value.nil? )
  end
  
	# return true if the given element validate this filter
	# should be override by sub classes
	def validate(pElement)
    begin
      return FilterCatalog.instance.call(@filter, pElement, @key, @value, @children)
    rescue Exception => err
      log_exception(err)
      return false
    end
	end
  
  # string representation of this filter
  def to_s()
    filter = ''
    key = ''
    value = ''
    filter = @filter.to_s if @filter
    key = @key.to_s if @key
    value = @value.to_s if @value
    if isLeaf()
      return key+' '+filter+' '+value
    else
      return filter+' ['+@children.size.to_s+' children]'
    end
  end
  
  # test if the given value is a number
  def isNumber(pValue)
    return false if pValue.nil?
    return pValue.to_s === pValue.to_i.to_s
  end

  
end

puts "-- Filter"
