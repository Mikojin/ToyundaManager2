
# ==========================================================
# Author : Mikomi
# ==========================================================
# Version : 0.1
# Create : 2007/10/23
# Last version : 2007/10/23
# ==========================================================
# Update rules service class
# ==========================================================
# Description :
# Apply rules for the given context
# ==========================================================

puts "require UpdateRulesService"

# ----------------------------------------------------------
require $root+ "Common"
require $root+ "constants/CstsKaraoke"
require $root+ "helper/Rules"
require $root+ "helper/Expressions"
# ----------------------------------------------------------

puts "++ UpdateRulesService"

class UpdateRulesService
  include Common
  

  # ============================================================
	public
  # ============================================================
  
  def initialize()
    @resetContextRules = [
      rr_resetContext(),
    ]
    @resetRules = [
      rr_used(),
      rr_last(),
      rr_useFreq(),
    ]
    
    @resetRules = [
      rr_used(),
      rr_last(),
      rr_useFreq(),
    ]
    
    @playlistRules = [
      pr_used(),
      pr_last(),
    ]

    @nonPlaylistRules = [
      npr_last(),
    ]
    
    @globalRules = [
      gr_useFreq(),
    ]
    
    @contextRules = [
      cr_totalUsed()
    ]
  end

  # apply update rules defined for the given context
  # In order :
  #   - Apply Context_Rules
  #   - On each Karaoke :
  #       Apply Non_Playlist_Rules OR Playlist_Rules
  #       Apply Globale_rules
  def applyUpdateRules(pContext)
    log("apply Update Rules") {
      @contextRules.each { |bContextRule|
        bContextRule.call(pContext)
      }
      pContext.globalList.each { |bKaraoke|
        applyUpdateKaraoke(pContext, bKaraoke)
      }
    }
  end


  # reset information link to this updateRules
  def resetUpdateRules(pContext)
    @resetContextRules.each { |bRule|
      bRule.call(pContext)
    }
    pContext.globalList.each { |bKaraoke|
      @resetRules.each { |bRule|
        bRule.call(pContext, bKaraoke)
      }
    }
  end

  # ============================================================
	private
  # ============================================================
  
  # apply rules on the given karaoke with the given context
  def applyUpdateKaraoke(pContext, pKaraoke)
    log("Treat : "+pKaraoke.to_s) {
      if pContext.playlist.contains(pKaraoke)
        # apply rules for playlist elements
        @playlistRules.each { |bRule|
          bRule.call(pContext, pKaraoke)
        }
      else
        # apply rules for other elements
        @nonPlaylistRules.each { |bRule|
          bRule.call(pContext, pKaraoke)
        }
      end
      # apply rules for all elements
      @globalRules.each { |bRule|
        bRule.call(pContext, pKaraoke)
      }
    }
  end
  
  # ============================================================
  # Reset Rules
  # ============================================================
  
  # reset the parameter used
  def rr_used()
    e = Expression::EConstant.new(0)
    r = Rule::RAffectColumn.new(CstsKaraoke::K_USED, e)
    r.setName("R_Used")
    return r
  end

  # reset the parameter used
  def rr_last()
    r = Rule::RResetColumn.new(CstsKaraoke::K_LAST)
    r.setName("R_Last")
    return r
  end

  # reset the parameter Freq Use
  def rr_useFreq()
    e = Expression::EConstant.new(0)
    r = Rule::RAffectColumn.new(CstsKaraoke::K_USE_FREQ, e)
    r.setName("R_UseFreq")
    return r
  end


  # ============================================================
  # Playlist Rules
  # ============================================================

  # update the parameter used
  def pr_used()
    r= Rule::RIncrementColumn.new(CstsKaraoke::K_USED)
    r.setName("P_Used")
    return r
  end
  
  # update the parameter last
  def pr_last()
    e = Expression::EConstant.new(0)
    r = Rule::RAffectColumn.new(CstsKaraoke::K_LAST, e)
    r.setName("P_Last")
    return r
  end

  # ============================================================
  # Non Playlist Rules
  # ============================================================
  # update the parameter last
  def npr_last()
    #~ e = Expression::EOpAdd.new().setName('Add')
    #~ e << Expression::EColumnValue.new(CstsKaraoke::K_LAST).setName('column')
    #~ e << Expression::EPlaylistSize.new().setName('increment')
    
    #~ r = Rule::RAffectColumn.new(CstsKaraoke::K_LAST, e)
    #~ r.activeDebug()
    e = Expression::EPlaylistSize.new()
    r = Rule::RIncrementColumn.new(CstsKaraoke::K_LAST, e)
    r.setName("NP_Last")
    return r
  end
  
  # ============================================================
  # Globale Rules
  # ============================================================

  def gr_useFreq()
    # (Used * TotalSize * 100) / totalUsed
    eMul = Expression::EOpMultiply.new().setName('*')
    eMul << Expression::EColumnValue.new(CstsKaraoke::K_USED).setName("Used")
    eMul << Expression::EConstant.new(1000).setName("percent")
    # eMul << Expression::ETotalSize.new().setName("list")
    # eMul << Expression::EConstant.new(100).setName("percent")
    
    eDivide = Expression::EOpDivide.new().setName('/')
    eDivide << eMul
    eDivide << Expression::ETotalUsed.new().setName("TotalUsed")
    
    r = Rule::RAffectColumn.new(CstsKaraoke::K_USE_FREQ, eDivide)
    r.setName("G_UseFreq")
  end


  # ============================================================
  # Context Rules
  # ============================================================

  def rr_resetContext()
    r = Rule::RResetContext.new()
    r.setName("C_Reset")
  end

  # update the total used title property of the context
  def cr_totalUsed()
    r = Rule::RUpdateTotalUsed.new()
    r.setName("C_TotalUsed")
    return r
  end

end

puts "-- UpdateRulesService"
