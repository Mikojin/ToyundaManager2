
require $root+"Tools/Chrono"
require $root+"Tools/FileHelper"

# profondeur de debug
#~ $log = File.open('debug.log', 'w')
#~ $debug = 100
#~ $debugFile = 100

module Tools

  # constante lié au module de log
  module CstLogger
    LOGGER_LOG = 'Logger.log'
    LOGGER_DEBUG = 'Logger.debug'
    LOGGER_DEBUG_FILE = 'Logger.debugFile'
  end

  # module permettant la gestion de log
  module Logger

    LOG_SEPERATEUR = " | "
    LOG_INDENT = "  "
    LOG_BLOC_IN = "++ "
    LOG_BLOC_OUT = "-- "
    LOG_EXCEPTION = "ERR : "
    LOG_MARGIN = 32

    @@indent = 0 
    @@chrono = Chrono.new

    def Logger::configure(pConfig)
      Logger.setLogFile(pConfig[CstLogger::LOGGER_LOG])
      Logger.setDebug(pConfig.to_i(CstLogger::LOGGER_DEBUG))
      Logger.setDebugFile(pConfig.to_i(CstLogger::LOGGER_DEBUG_FILE))
    end

    # definit le fichier de log
    def Logger::setLogFile(pLogFile)
      FileHelper.checkFileWrite(pLogFile)
      @@logFile = File.open(pLogFile, 'w')
    end
    
    # definit le niveau de debug console
    def Logger::setDebug(pDebug)
      @@debug = pDebug
    end
    # definit le niveau de debug dans le fichier de log
    def Logger::setDebugFile(pDebug)
      @@debugFile = pDebug
    end
    
    def Logger::close()
      begin
        @@logFile.close
      rescue
      end
    end

    # log un messages
    def log(msg)
      #@@indent = 0 unless @@indent
      unless block_given?
        log_puts(msg)
        return
      end
      log_puts(LOG_BLOC_IN+msg)
      Logger::_log_indent()
      
      begin
        b = yield
      rescue Exception => pException
        log_exception(pException)
        raise
      ensure
        Logger::_log_unindent()
        log_puts(LOG_BLOC_OUT+msg)
      end
      return b
    end



    # ---------------------------------
    protected
    # ---------------------------------
    # Log message for this class
    def log_puts(msg)
      #~ return unless (logDebug = ($debug >= debug_lvl())) or (logDebugFile = ($debugFile >= debug_lvl()))
      isLogConsole = (@@indent <= @@debug)
      isLogFile = (@@indent <= @@debugFile)
      return unless isLogConsole or isLogFile
      logmsg = log_prefix()+msg
      Logger::_puts_file(logmsg) if isLogFile
      Logger::_puts_console(logmsg) if isLogConsole
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
      return (@@chrono.getStr() + ' | ' + className + margin + LOG_SEPERATEUR + (LOG_INDENT * @@indent))
    end

    # ---------------------------------
    public
    def self._log(msg)
      isLogConsole = (@@indent <= @@debug)
      isLogFile = (@@indent <= @@debugFile)
      return unless isLogConsole or isLogFile
      logmsg = _log_prefix()+msg
      Logger::_puts_file(logmsg) if isLogFile
      Logger::_puts_console(logmsg) if isLogConsole
    end
    
    # ---------------------------------
    protected
    # ---------------------------------
    def self._log_prefix()
      margin = "Logger" + (" " * (LOG_MARGIN - 6))
      return (@@chrono.getStr() + ' | ' + margin + LOG_SEPERATEUR + (LOG_INDENT * @@indent))
    end
    
    # ecrit sur la console
    def self._puts_console(pString)
      puts(pString)
    end
    
    # ecrit dans le fichier de log
    def self._puts_file(pString)
      @@logFile.puts(pString) 
    end


    # indent the log
    def self._log_indent()
      @@indent = 0 unless @@indent
      @@indent = @@indent + 1
    end

    # unindent the log
    def self._log_unindent()
      @@indent = 1 unless @@indent
      @@indent = @@indent - 1
      @@indent = 0 if @@indent < 0
    end
  end
end