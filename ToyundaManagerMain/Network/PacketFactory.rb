
require 'singleton'

require $root+"Tools/Tools"

module Network
  # Factory générant les packet en fonction de leur id
  class PacketFactory < Tools::Factory

    # @override
    def getKey(pObjectClass)
      return pObjectClass._id()
    end
    
    def self.add(pObjectClass)
      instance << pObjectClass
    end
    
    def self.create(pId)
      instance.create(pId)
    end
    
  end
end