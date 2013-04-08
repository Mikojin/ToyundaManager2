
# ==========================================================
# Author : Mikomi
# ==========================================================
# Version : 0.1
# Create : 2007/10/23
# Last version : 2007/10/23
# ==========================================================
# Module Expression
# ==========================================================
# Description :
# Expression used for Rules evaluation
# ==========================================================

puts "require Expression"

# ----------------------------------------------------------
require $root+ "Common"
# ----------------------------------------------------------

puts "++ Expression"

# module experssion for karaoke
module Expression
  
  # Abstract Expression
  class Expression
    include Common
    attr_reader :name
    def initialize()
      @name = self.class.name.to_s
      @subExpressionList = Array.new
      set_debug_lvl(100)
    end
    
    def activeDebug()
      set_debug_lvl(25)
      @subExpressionList.each { |bSubExpression|
        bSubExpression.activeDebug()
      }
      return self
    end
    
    def setName(pName)
      @name = pName
      return self
    end
    
    alias :name= :setName
    
    def <<(pExpression)
      @subExpressionList << pExpression
    end
    
    def eval(pContext, pKaraoke = nil)
      v = doEval(pContext, pKaraoke)
      vStr = 'nil'
      vStr = v.to_s unless v.nil?
      log("eval "+self.to_s+' = '+vStr)
      return v
    end
    def doEval(pContext, pKaraoke)
      log('do nothing')
    end
    def to_s()
      subStr = ''
      subStr = '('+@subExpressionList.join(' ; ')+')' unless @subExpressionList.empty?
      return @name+subStr
    end
  end

  # ---------------------------------------
  # Context Expression
  # ---------------------------------------

  # Return a constant value
  class EConstant < Expression
    attr_accessor :value
    def initialize(pValue = nil)
      super()
      @value = pValue
    end
    def doEval(pContext, pKaraoke)
      return @value
    end
    def to_s()
      v = @value
      v = 'nil' if v.nil?
      return @name+'='+v.to_s
    end
  end

  # return the size of the title list
  class ETotalSize < Expression
    def doEval(pContext, pKaraoke)
      return pContext.globalList.size if pContext.globalList
      return 0
    end
  end
  
  # return the size of the current playlist
  class EPlaylistSize < Expression
    def doEval(pContext, pKaraoke)
      return pContext.playlist.size if pContext.playlist
      return 0
    end
  end

  # return the total used title
  class ETotalUsed < Expression
    def doEval(pContext, pKaraoke)
      return pContext.totalUsedTitle
    end
  end

  # ---------------------------------------
  # Karaoke Expression
  # ---------------------------------------
  
  # return the value of the given column
  class EColumnValue < Expression
    attr_accessor :column
    def initialize(pColumn)
      super()
      @column = pColumn
    end
    def doEval(pContext, pKaraoke)
      return pKaraoke[@column]
    end
    def to_s
      return @name+'['+@column.to_s+']'
    end
  end

  # ---------------------------------------

  # sum each sub expression of this expression
  class EOpAdd < Expression
    def doEval(pContext, pKaraoke)
      result = 0
      @subExpressionList.each { |bSubExpression|
        v = bSubExpression.eval(pContext, pKaraoke)
        begin
          result += v
        rescue
          v = 'nil' if v.nil?
          log("can't add "+v.to_s+" to "+result.to_s)
        end
      }
      return result
    end
    def to_s()
      subStr = ''
      subStr = '( '+@subExpressionList.join(' + ')+' )' unless @subExpressionList.empty?
      return @name+subStr
    end
  end

  # Divide the first sub expression by each other sub expression
  class EOpDivide < Expression
    def doEval(pContext, pKaraoke)
      result = nil
      @subExpressionList.each { |bSubExpression|
        v = bSubExpression.eval(pContext, pKaraoke)
        if result
          begin
            result /= v
          rescue
            v = 'nil' if v.nil?
            log("can't divide "+result.to_s+" by "+v.to_s)
          end
        else
          result = v  
        end
      }
      return result.to_i
    end
    def to_s()
      subStr = ''
      subStr = '( '+@subExpressionList.join(' / ')+' )' unless @subExpressionList.empty?
      return @name+subStr
    end
  end

  # multiply each sub expression
  class EOpMultiply < Expression
    def doEval(pContext, pKaraoke)
      result = 1
      @subExpressionList.each { |bSubExpression|
        v = bSubExpression.eval(pContext, pKaraoke)
		if v.nil?
			v = 0 
			log("can't multiply "+result.to_s+" by "+v.to_s+" => 0")
		end
		result *= v
      }
      return result.to_i
    end
    def to_s()
      subStr = ''
      subStr = '( '+@subExpressionList.join(' * ')+' )' unless @subExpressionList.empty?
      return @name+subStr
    end
  end


end

puts "-- Expression"
