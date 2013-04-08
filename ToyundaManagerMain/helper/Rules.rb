
# ==========================================================
# Author : Mikomi
# ==========================================================
# Version : 0.1
# Create : 2007/10/23
# Last version : 2007/10/23
# ==========================================================
# Module Rule
# ==========================================================
# Description :
# Module containing declaring rules classes
# ==========================================================

puts "require Rule"

# ----------------------------------------------------------
require $root+ "Common"
require $root+ "helper/Expressions"
# ----------------------------------------------------------

puts "++ Rule"

# Rule module
module Rule
  # generique rule, do nothing
  class Rule
    include Common
    attr_reader :name
    def initialize()
      set_debug_lvl(90)
      @name = self.class.name.to_s
    end
    def setName(pName)
      @name = pName
      return self
    end
    def activeDebug()
      set_debug_lvl(20)
      return self
    end
    # apply this rule to the given context and karaoke
    def call(pContext, pKaraoke = nil)
      log("Eval "+@name) {
        if pKaraoke.nil?
          callContext(pContext)
        else
          callKaraoke(pContext, pKaraoke)
        end
      }
    end
    # apply this rule for the given context
    # should be overridden
    def callContext(pContext)
      log("do nothing")
    end
    # apply this rule for the given context and karaoke
    # should be overridden
    def callKaraoke(pContext, pKaraoke)
      log("do nothing")
    end
  end
  
  # -------------------------------------------
  # Context Rules
  # -------------------------------------------
  
  # Reset context
  class RResetContext < Rule
    def callContext(pContext)
      pContext.totalUsedTitle = 0
    end
  end
  
  # Update the total used property of the context
  # add playlist size to the current value of totalUsedTitle
  class RUpdateTotalUsed < Rule
    def callContext(pContext)
      total = pContext.totalUsedTitle
      size = pContext.playlist.size
      log("TotalUsedTitle = "+total.to_s+" + "+size.to_s)
      pContext.totalUsedTitle = total + size
    end
  end
  
  # -------------------------------------------
  # Karaoke Rules
  # -------------------------------------------
  
  # Abstract Rule using column
  class RAbstractColumn < Rule
    attr_accessor :column
    def initialize(pColumn)
      super()
      @column = pColumn
    end
  end
  
  # affect the value return by the given expression to the given column of a karaoke
  class RAffectColumn < RAbstractColumn
    attr_accessor  :expression
    def initialize(pColumn, pExpression)
      super(pColumn)
      @expression = pExpression
    end
    def activeDebug()
      @expression.activeDebug() unless @expression.nil?
      return self
    end
    def callKaraoke(pContext, pKaraoke)
      v = @expression.eval(pContext, pKaraoke)
      pKaraoke[@column] = v
      v = 'nil' if v.nil?
      log(@column.to_s+" = "+v.to_s)
    end
  end

  # reset the value (set to nil) of the given column
  class RResetColumn < RAffectColumn
    def initialize(pColumn)
      super(pColumn, Expression::EConstant.new())
    end
  end

  # increment the value of the given column by the return value of the given expression
  # If the value for the column is nil, then it is initialize at 0
  # if expression is nil, increment is set to 1
  class RIncrementColumn < RAffectColumn
    def initialize(pColumn, pExpression = nil)
      super(pColumn, pExpression)
      pExpression.setName("Increment").activeDebug() unless pExpression.nil?
    end
    def callKaraoke(pContext, pKaraoke)
      v = pKaraoke[@column]
      v = 0 if v.nil?
      incr = 1
      unless @expression.nil?
        incr = @expression.eval(pContext, pKaraoke)
      end
      incr = 1 if incr.nil?
      pKaraoke[@column] = v + incr
      log(@column.to_s+" = "+v.to_s+' + '+incr.to_s)
    end
  end

end

puts "-- Rule"
