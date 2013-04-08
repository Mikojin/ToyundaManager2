
# charge toutes les classes du module Tools
require $root+"Tools/FileHelper"
require $root+"Tools/Config"
require $root+"Tools/Chrono"
require $root+"Tools/Logger"
require $root+"Tools/Factory"
require $root+"Tools/Producer"
require $root+"Tools/Graph/Graph"

module Tools
  def self.min(pA, pB)
    return pA if pA <= pB
    return pB
  end
  def self.max(pA, pB)
    return pA if pA >= pB
    return pB
  end
end

