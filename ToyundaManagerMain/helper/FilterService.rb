
# ==========================================================
# Author : Mikomi
# ==========================================================
# Version : 0.1
# Create : 2007/11/13 
# Last version : 2007/11/13
# ==========================================================
# Filter service class
# ==========================================================
# Description :
# Load / Save filter
# ==========================================================

puts "require FilterService"

# ----------------------------------------------------------
require 'csv'
require $root+ "Common"
require $root+ "filter/Filter"
require $root+ "filter/CustomFilterCatalog"
# ----------------------------------------------------------

puts "++ FilterService"

class FilterService
  include Common
  
  CHILDREN_OPEN  = '{'
  CHILDREN_CLOSE = '}'
  INDENT  = '  '
  SEPARATOR = ';'
  EMPTY_LINE = /^\s*$/
  IS_CHILDREN_OPEN = /^\s*\{\s*$/
  IS_CHILDREN_CLOSE = /^\s*\}\s*$/
  GET_CSV = /^\s*(.*)$/
  
  # ============================================================
	public
  # ============================================================
  
  def initialize()
    set_debug_lvl(7)
  end
  
  # save the given custom Filter catalog
  def saveCustomFilterCatalog(pCustomFilterCatalog, pFileName)
    log("save Filter : "+pFileName) {
      File.open(pFileName,'w') { |bFile|
        pCustomFilterCatalog.getList().each { |bCustomFilterName|
          customFilter = pCustomFilterCatalog[bCustomFilterName]
          bFile.puts(bCustomFilterName)
          bFile.puts(CHILDREN_OPEN)
          writeCustomFilter(bFile, customFilter)
          bFile.puts(CHILDREN_CLOSE)
        }
      }
    }
  end
  
  # load a custom Filter catalog form the given file
  def loadCustomFilterCatalog(pFileName)
    log("loadCustomFilterCatalog : "+pFileName) {
      customFilterCatalog = CustomFilterCatalog.new
      return customFilterCatalog unless File.exist?(pFileName)
      File.open(pFileName,'r') { |bFile|
        # read the first line
        line = readNextLine(bFile)
        while line
          # if the line isn't empty nor nil, 
          # then it should be the name of a new custom filter
          line.chomp!
          customFilterName = line
          customFilter = readCustomFilter(bFile, customFilterName)
          customFilterCatalog[customFilterName] = customFilter
          
          line = readNextLine(bFile)
        end
      }
      return customFilterCatalog
    }
  end

  # ============================================================
	private
  # ============================================================
  
  # write the given custom filter in the given file
  def writeCustomFilter(pFile, pCustomFilter, pDepth = 1)
    line = createCSVLine(pCustomFilter)
    prefix = getIndentPrefix(pDepth)
    pFile.puts(prefix+line)
    pFile.puts(prefix+CHILDREN_OPEN)
    pCustomFilter.each_children { |bChildrenFilter|
      writeCustomFilter(pFile, bChildrenFilter, pDepth + 1)
    }
    pFile.puts(prefix+CHILDREN_CLOSE)
  end
  
  # read data for a custom filter
  def readCustomFilter(pFile, pCustomFilterName)
    log("custom filter : "+pCustomFilterName) {
      readChildrenOpen(pFile)

      # this loop should go only 2 times
      # the first time read a filter
      # the second should be nil and stop the reading process
      filter = nil
      tmpFilter = nil
      begin
        tmpFilter = readFilter(pFile)
        filter = tmpFilter unless tmpFilter.nil?
      end until tmpFilter.nil?
      
      return filter
    }
  end
  
  # read a custom filter from the given file
  def readFilter(pFile)
    line = readNextLine(pFile)
    line.chomp!
    
    if line =~ IS_CHILDREN_CLOSE
      log("}")
      # no more filter
      return nil
    end
    log("new filter : "+line) {
      filter = nil
      if line =~ GET_CSV
        csvLine = $1
        filterType, key, value = CSV.parse_line(csvLine, SEPARATOR)
        filter = Filter.new(filterType.to_s, key.to_s, value.to_s)
      end

      readChildrenOpen(pFile)
      
      # each children is added to this filter until nil is found
      begin
        childFilter = readFilter(pFile)
        filter << childFilter unless childFilter.nil?
      end until childFilter.nil?
      
      return filter
    }
  end

  # read the children open brack
  def readChildrenOpen(pFile)
    line = readNextLine(pFile)
    line.chomp!
    unless line =~ IS_CHILDREN_OPEN
      log "format error : filter not open : "+line
      return nil
    else
      log("{")
    end
  end
  
  def readNextLine(pFile)
    line = nil
    if pFile.eof?
      log("eof")
      return nil 
    end
    begin
      line = pFile.readline
    end until !(line =~ EMPTY_LINE) or pFile.eof?
    return nil if (line =~ EMPTY_LINE)
    #~ log("readline : "+line)
    return line
  end
  
  # create a CSV string from the given custom filter
  def createCSVLine(pCustomFilter)
    row = [pCustomFilter.filter, pCustomFilter.key, pCustomFilter.value]
    line = CSV.generate_line(row, SEPARATOR)
    return line
  end
  
  # get the prefix string for indentation
  def getIndentPrefix(pDepth)
    return INDENT * pDepth
  end
  
end

puts "-- FilterService"
