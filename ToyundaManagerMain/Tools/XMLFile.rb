
# represente un fichier xml pouvant être écrit ou lu
# le xml ne contient que des balise, pas d'attribut

require $root+"Tools/FileHelper"
require $root+"Tools/Logger"

module Tools

  class XMLFile
    include Logger
    
    INDENT = "\t"
    
    def initialize()
      @write = @read = false
    end
    
    def openw(pFileName)
      FileHelper.checkFileWrite(pFileName)
      @file = File.open(pFileName, 'w')
      @indent = 0
      @write = true
      if block_given?
        yield self
        @file.close()
      end
    end

    def openr(pFileName)
      FileHelper.checkFileRead(pFileName)
      @file = File.open(pFileName, 'r')
      @read = true
      if block_given?
        yield self
        @file.close()
      end
    end

    def close()
      begin
        @file.close() if @write or @read
        @write = @read = false
      rescue
      end
    end
    
    # =====================================
    # write
    # =====================================
    
    # écrit une ligne dans le fichier (avec retour à la ligne)
    def write(pLine)
      return unless @write
      @file.write(getIndent()+pLine+"\n")
    end
    
    # ecrit un tag à partir de son nom et des attributs donnés
    # pTagName : le nom du tag
    # pAttributMap : map des attributs, associe nom => valeur
    def tag(pTagName, pAttributMap = nil)
      return unless @write
      attributString = Attribut.serializeMap(pAttributMap)
      if block_given?
        write("<#{pTagName}#{attributString}>")
        indent()
        yield
        unindent()
        write("</#{pTagName}>")
      else
        write("<#{pTagName}#{attributString}/>")
      end
    end
    
    protected
    def indent()
      @indent += 1
    end
    
    def unindent()
      @indent -= 1
    end
    
    def getIndent()
      return INDENT * @indent
    end
    
    # =====================================
    # read
    # =====================================
    public
    # lit la ligne suivante
    def readline()
      return nil unless @read
      return nil if @file.eof?
      return @file.readline 
    end

    # lit le fichier jusque l'ouverture du prochain tag
    def readTag(pCurrentTag = nil)
      tagOpen = true
      pCurrentTag = Tag.new("root") if pCurrentTag.nil?
      while tagOpen and line = readline()
        result = line.match(/<(\/?)(\w+)(.*?)(\/?)>/)
        #~ ((\s+((\w+)="(.*?)"))*)
        if result
          if result[1].empty?
            if result[4].empty?
              log "<x> : #{result[2]} | #{result[3]}"
              tag = parseTag(result[2], result[3])
              pCurrentTag.children << tag
              readTag(tag)
            else
              log "<x/> : #{result[2]} | #{result[3]}"
              tag = parseTag(result[2], result[3])
              pCurrentTag.children << tag
            end
          else
            if result[4].empty?
              log "</x> : #{result[2]}"
              tagOpen = false
            else
              raise "parse error : "+line
            end
          end
        else
          log "xx : #{line}"
          pCurrentTag.content = line
        end
      end
      return pCurrentTag
    end

    private
    def parseTag(pName, pAttributs)
      tag = Tag.new(pName)
      return tag
    end

    # =====================================
    # Sub Class
    # =====================================
    public
    class Tag
      include Logger
      attr_reader :name, :attributs, :children
      attr_accessor :content
      def initialize(pName)
        @name = pName
        @attributs = Array.new
        @children = Array.new
        @content = nil
      end
      
      def write(pXml)
        if @children.empty? and @content.nil?
          if @attributs.empty?
            pXml.write("<#{@name}/>")
          else
            pXml.write("<#{@name} #{@attributes.join(' ')}/>")
          end          
        else
          if @attributs.empty?
            pXml.write("<#{@name}>")
          else
            pXml.write("<#{@name} #{@attributes.join(' ')}>")
          end
          pXml.write(@content) if @content
          pXml.indent()
          @children.each { |bTag|
            bTag.write(pXml)
          }
          pXml.unindent()
          pXml.write("</#{@name}>")
        end
      end
      
      def print()
        if @children.empty? and @content.nil?
          log("#{@name} : #{@attributs.join(' ')}")
        else
          log("#{@name} : #{@attributs.join(' ')}") {
            log "#{@content}" if @content
            @children.each { |bChild|
              bChild.print()
            }
          }
        end
      end
      
    end
    
    class Attribut
      attr_reader :name, :value
      def initialize(pName, pValue)
        @name = pName
        @value = pValue
      end
      
      def to_s()
        return Attribut.serialize(@name, @value)
      end
      
      # serialise l'attribut donné
      def self.serialize(pName, pValue)
        return "#{pName}=\"#{pValue}\""
      end
      
      def self.serializeMap(pMapAttribut)
        serialized = ""
        return serialized if pMapAttribut.nil? or pMapAttribut.empty?
        pMapAttribut.each { |bKey, bValue|
          serialized += (" " + Attribut.serialize(bKey, bValue))
        }
        return serialized
      end
    end
  end
  
end

