
# ==========================================================
# Author : Mikomi
# ==========================================================
# Version : 0.1
# Create : 2007/05/13 
# Last version : 2007/05/14
# ==========================================================
# Property module
# ==========================================================
# Description :
# Helper to read and write Property files
# ==========================================================

puts "++ Property"

module Property
  PROPERTY_SEPARATOR = '='

  # ---------------------------------
  # return the key and the value of a property line
  def Property::getKeyValue(pLine)
    m = pLine.match(/^(.*?)\s*=\s*(.*)/)
    return m[1], m[2]
  end


  # ---------------------------------
  # Load a property file.
  # yield (key, value) for each property
  def Property::load(fileName)
    return nil unless File.exists?(fileName)
    map = Hash.new
    File.open(fileName,'r') { |bFile|
      bFile.each_line { |bLine|
        bLine.chomp!
        key, value = Property::getKeyValue(bLine)
        if Property::isNumber(value)
          map[key] = value.to_i
        elsif Property::isBoolean(value)
          map[key] = (true.to_s == value)
        else
          map[key] = value
        end
        if block_given?
          yield(key, value)
        end
      }
    }
    return map
  end
  
  # ---------------------------------
  # save a map to a property file.
  # block : key, value = yield (key, value)
  # Block is called before the effective save.
  # therefore, you can convert your key and value if necessary.
  def Property::save(fileName, map)
    File.open(fileName,'w') { |bFile|
      keyList = map.keys
      keyList.sort!
      keyList.each { |key|
        value = map[key]
        k, v = key, value
        if block_given?
          k, v = yield(key, value)
        end
        bFile.puts k.to_s + PROPERTY_SEPARATOR + v.to_s
      }
    }
  end
  
  # =================================
  private
  # ---------------------------------

  # test if the given value is a number
  def Property::isNumber(pValue)
    return pValue.to_s === pValue.to_i.to_s
  end

  # test if the given value is a boolean
  def Property::isBoolean(pValue)
    return ((true.to_s == pValue.to_s) || false.to_s == pValue.to_s)
  end


end

puts "-- Property"
  
  