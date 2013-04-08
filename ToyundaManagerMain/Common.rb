
# ==========================================================
# Author : Mikomi
# ==========================================================
# Version : 0.1
# Create : 2007/05/10 
# Last version : 2007/05/13
# ==========================================================
# Common module
# ==========================================================
# Description :
# Contains common methodes for all classes
# ==========================================================



puts "++ Common"

module Common
  
  # Constants for the color of the message
  MSG_COLOR = '#0000A0'
  INFO_COLOR = '#00A000'
  ERROR_COLOR = '#D00000'
  PROFILE_COLOR = '#000000'

  
  LOG_SEPERATEUR = " >> "
  LOG_INDENT = "  "
  LOG_BLOC_IN = "++ "
  LOG_BLOC_OUT = "-- "
  LOG_EXCEPTION = "ERROR : "
  LOG_MARGIN = 32
  
  @@indent = 0 
  
  # ---------------------------------
  # Log message for this classe
  def log(msg)
    
    @@indent = 0 unless @@indent
    unless block_given?
      log_puts(msg)
      return
    end
    log_puts(LOG_BLOC_IN+msg)
    log_indent()
    
    begin
      b = yield
    rescue Exception => pException
      log_exception(pException)
      raise
    ensure
      log_unindent()
      log_puts(LOG_BLOC_OUT+msg)
    end
    return b
  end

  # ---------------------------------
  # Log message for this class
  def log_puts(msg)
    #~ return unless (logDebug = ($debug >= debug_lvl())) or (logDebugFile = ($debugFile >= debug_lvl()))
    isLogConsole = (debug_lvl() <= $debug)
    isLogFile = (debug_lvl() <= $debugFile)
    return unless isLogConsole or isLogFile
    logmsg = log_prefix()+msg
    puts_file(logmsg) if isLogFile
    puts_console(logmsg) if isLogConsole
  end

  # ---------------------------------
  # Log list of messages for this class
  def log_list(pList)
    pList.each { |bMsg|
      log(bMsg)
    }
  end

	# log an exception
  def log_exception(pException)
    log(LOG_EXCEPTION+pException.to_s) {
        log_list(pException.backtrace)
    }
  end

	# return the prefix for the current log
  def log_prefix()
    className = self.class.to_s
    marginSize = LOG_MARGIN - className.size
    marginSize = 0 if marginSize < 0
    margin = " " * marginSize
    return (className + margin + LOG_SEPERATEUR + (LOG_INDENT * @@indent))
  end

  # ---------------------------------
  # indent the log
  def log_indent()
    @@indent = 0 unless @@indent
    @@indent = @@indent + 1
  end

  # unindent the log
  def log_unindent()
    @@indent = 1 unless @@indent
    @@indent = @@indent - 1
    @@indent = 0 if @@indent < 0
  end

  # ---------------------------------
  def debug_lvl()
    return @debugLvl if @debugLvl
    @debugLvl = 1
    return @debugLvl
  end

  def set_debug_lvl(pValue)
    @debugLvl = pValue
  end
  
end

puts "-- Common"
