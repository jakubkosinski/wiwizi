require 'set'
require 'fast_stemmer'

class Index
  attr_accessor :index, :positions, :frequencies
  attr_reader :type

  def initialize(type = :basic, options = {})
    @type = type
    @index = options[:index] || {}
    @positions = options[:positions] || {}
    @frequencies = options[:frequencies] || {}
  end

  def index_document(file_name)
    words = []
    if RUBY_VERSION =~ /^1.9/
      file = File.open(file_name, "r:iso8859-2")
      words = file.read
    else
      words = File.read(file_name)
    end
    words = words.gsub(/[^\w\s]/,"").split
    words.each_with_index do |word, index|
      case @type
      when :stemmer
        add_with_stemmer(word, file_name, index, words.length.to_f)
      else
        add_without_stemmer(word, file_name, index)
      end
    end
  end

  def save_index(file)
    File.open(file, "wb"){|f| f << Marshal.dump(self)}
  end

  def self.load_index(file)
    Marshal.load(File.read(file))
  end

  protected
  def add_with_stemmer(word, file_name, index, length)
    if RUBY_VERSION =~ /^1.9/
      stem = word.downcase.stem_porter
    else
      stem = word.downcase.stem
    end
    (@index[stem] ||= Set.new) << file_name                   # add file name to stem set
    if (@positions[stem] ||= Hash.new(-1))[file_name] == -1
      @positions[stem][file_name] = (1.0 - index/length)   # add position of stem in file
    end
    #(@frequencies[stem] ||= Hash.new(0))[file_name] += 1      # increment frequency of stem in file
    (@frequencies[stem] ||= Hash.new(0.0))[file_name] += (1.0/length)      # increment frequency of stem in file
  end

  def add_without_stemmer(word, file_name, index)
    word = word.downcase
    @index[word] ||= Set.new
    @index[word] << file_name
  end
end
