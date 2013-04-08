
# ==========================================================
# Author : Mikomi
# ==========================================================
# Version : 0.1
# Create : 2007/10/18
# Last version : 2007/10/18
# ==========================================================
# Abstract Filter
# ==========================================================
# Description :
# Filter that test if an element is valide
# can contain sub filter
# An element is a map, the validation is done using a key
# and a value
# ==========================================================


puts "require FilterGeneric"

# ----------------------------------------------------------
require $root+ "Common"
require $root+ "constants/CstsFilter"
# ----------------------------------------------------------

puts "++ FilterGeneric"

class FilterGeneric
	include Common
  
  #=====================================================
  # Instance
  #=====================================================
  attr_accessor :name, :isLeaf
  
	def initialize(pName, pIsLeaf)
    @name = pName
    @isLeaf = pIsLeaf
	end
	
	# return true if the given element validate this filter
	def validate(pElement, pKey, pValue, pChildren)
    msg = nil
    if @isLeaf
      msg = @name+" : e["+pKey.to_s+"] = "+pElement[pKey].to_s+" : "+pValue.to_s
    else
      msg = @name
    end
    #~ log(msg) {
      v = doValidate(pElement, pKey, pValue, pChildren)
      #~ log("=> "+v.to_s)
      return v
    #~ }
	end
  
  protected
  
  # actual validation, method to override
  def doValidate(pElement, pKey, pValue, pChildren)
    return true
  end
end

#=====================================================
#=====================================================
# Filter Specific
#=====================================================
#=====================================================

#=====================================================
# Filter Node
#=====================================================

#-----------------------------------------------------
# validate if all children are not validate
# Actually, it's a !F1 & !F2 & !F3 etc...
class FilterNot < FilterGeneric
  def initialize()
    super(CstsFilter::F_NOT, false)
  end
  def doValidate(pElement, pKey, pValue, pChildren)
    i = 0
    ok = true
    while ok and i < pChildren.size
      filter = pChildren[i]
      ok = (ok and !filter.validate(pElement))
      i = i+1
    end
    return ok
  end
end


#-----------------------------------------------------
# validate if all children are valide
class FilterAnd < FilterGeneric
  def initialize()
    super(CstsFilter::F_AND, false)
  end
  def doValidate(pElement, pKey, pValue, pChildren)
    i = 0
    ok = true
    while ok and i < pChildren.size
      filter = pChildren[i]
      ok = (ok and filter.validate(pElement))
      i = i+1
    end
    return ok
  end
end

#-----------------------------------------------------
# validate if at least 1 children is valide
class FilterOr < FilterGeneric
  def initialize()
    super(CstsFilter::F_OR, false)
  end
  def doValidate(pElement, pKey, pValue, pChildren)
    i = 0
    ok = false
    while !ok and i < pChildren.size
      filter = pChildren[i]
      ok = (ok or filter.validate(pElement))
      i = i+1
    end
    return ok
  end
end

#=====================================================
# Filter Leaves
#=====================================================

#-----------------------------------------------------
# validate if pElement[pKey] is nil
# children are ignored
class FilterNil < FilterGeneric
  def initialize()
    super(CstsFilter::F_NIL, true)
  end
  def doValidate(pElement, pKey, pValue, pChildren)
    value = pElement[pKey]
    return value.nil?
  end
end

#-----------------------------------------------------
# validate if pElement[pKey] is not nil
# children are ignored
class FilterNotNil < FilterGeneric
  def initialize()
    super(CstsFilter::F_NOT_NIL, true)
  end
  def doValidate(pElement, pKey, pValue, pChildren)
    value = pElement[pKey]
    return !value.nil?
  end
end

#-----------------------------------------------------
# validate if pElement[pKey] == pValue
# children are ignored
class FilterEqual < FilterGeneric
  def initialize()
    super(CstsFilter::F_EQUAL, true)
  end
  def doValidate(pElement, pKey, pValue, pChildren)
    return pElement[pKey] == pValue
  end
end

#-----------------------------------------------------
# validate if pElement[pKey] != pValue
# children are ignored
class FilterDifferent < FilterGeneric
  def initialize()
    super(CstsFilter::F_DIFFERENT, true)
  end
  def doValidate(pElement, pKey, pValue, pChildren)
    return pElement[pKey] != pValue
  end
end

#-----------------------------------------------------
# validate if pElement[pKey] > pValue
# children are ignored
class FilterSuperior < FilterGeneric
  def initialize()
    super(CstsFilter::F_SUPERIOR, true)
  end
  def doValidate(pElement, pKey, pValue, pChildren)
    value = pElement[pKey]
    return false if value.nil?
    return value > pValue
  end
end

#-----------------------------------------------------
# validate if pElement[pKey] < pValue
# children are ignored
class FilterInferior < FilterGeneric
  def initialize()
    super(CstsFilter::F_INFERIOR, true)
  end
  def doValidate(pElement, pKey, pValue, pChildren)
    value = pElement[pKey]
    return false if value.nil?
    return value < pValue
  end
end

#-----------------------------------------------------
# validate if pElement[pKey] contains the string in pValue
# children are ignored
class FilterContains < FilterGeneric
  def initialize()
    super(CstsFilter::F_CONTAINS, true)
  end
  def doValidate(pElement, pKey, pValue, pChildren)
    return true if pValue.nil?
    value = pElement[pKey]
    return false if value.nil?
    regexp = Regexp.new(Regexp.escape(pValue),Regexp::IGNORECASE)
    return (regexp === value)
  end
end

  

puts "-- FilterGeneric"
