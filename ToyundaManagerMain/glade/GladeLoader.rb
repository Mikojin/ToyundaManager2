
# ==========================================================
# Author : Mikomi
# ==========================================================
# Version : 2
# Create : 2007/05/10 
# Last version : 2012/02/25
# ==========================================================
# Glade Loader Module
# ==========================================================
# Description :
# Simplify the loading of glade file
# Require libglade2 to work.
# v2 : Switch to Gtk::Builder instead of Glade
# ==========================================================

puts "require GladeLoader"

# ----------------------------------------------------------
begin 
	require 'libglade2'
rescue LoadError
	puts "Cannot import libglade2"
end
require 'gtk2'
require $root + 'gui/GUI'
# ----------------------------------------------------------

puts "++ GladeLoader"

module GladeLoader
  include GetText

  attr_reader :glade

  # =================================
  private
  # ---------------------------------
  # initialize glade file .ui or .glade
  def iniGlade(fileName)
    bindtextdomain(nil, nil, nil, "UTF-8")
		
		# try to load .ui file
		return if iniGladeGtkBuilder(fileName+'.ui')
		
		# if it fails try to load .glade file
		return if iniGladeGtk2(fileName+'.glade')
		
		msg = "Cannot load Gtk::Builder/Glade2 file : #{fileName}"
		log(msg)
		GUI::popupError(msg)
  end

  # ---------------------------------
  # initialize glade
	def iniGladeGtkBuilder(fileName)
		return false unless File.exists?(fileName)
		begin
			@glade = Gtk::Builder.new
			@glade.add_from_file(fileName)
		  @glade.connect_signals { |handler|
				createProc(handler)
			}
			return true
		rescue Exception => e
			log("Cannot initialize Gtk::Builder : #{e}")
			return false
		end
	end
	
  # initialize glade
	def iniGladeGtk2(fileName)
		return false unless File.exists?(fileName)
		begin
			@glade = GladeXML.new(fileName, nil, nil, nil, GladeXML::FILE) { |handler| 
					createProc(handler)
			}
		rescue Exception => e
			log("Cannot initialize Glade2 : #{e}")
			return false
		end
  end

	# create a new Proc with error management
	def createProc(handler)
		#log("handler "+handler.class.to_s+" : "+handler.to_s)
		newProc = nil
		begin
			newMethod = method(handler)
			newProc = nil
			if newMethod.arity == 0
				newProc = createMethod0(handler, newMethod)
			else
				newProc = createMethod(handler, newMethod)
			end
		rescue NameError => excp
			# standard error when there is no binding
			log(excp.class.to_s+" >> "+excp.to_s)
			newProc = proc { |*bArg|
				GUI::popupError("binding missing for : #{handler}")
			}
		end
		return newProc
	end
	
	# configure and return a new method of arity 0
	def createMethod0(handler, newMethod)
		return proc { |*bArg|
				begin
					log(handler.to_s) {
						newMethod.call(*bArg)
					}
				rescue Exception => e
					manageError(handler, e, "An error occured while executing method #{handler}")
				end
			}
	end
	
	# configure and return a new method of arity N
	def createMethod(handler, newMethod)
		return proc { |*bArg|
				begin
					log(handler.to_s) {
						newMethod.call(*bArg)
					}
				rescue Exception => e
					manageError(handler, e, "An error occured while executing method #{handler}")
				end
			}
	end
	
	def manageError(handler, e, msg)
		msgList = [msg,e.to_s]
		msgList.concat(e.backtrace)
		GUI::popupError(msgList)
	end
  
end

puts "-- GladeLoader"

