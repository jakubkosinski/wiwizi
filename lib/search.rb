require 'set'
require 'fast_stemmer'
require 'index'

class Search
  attr_accessor :type

  def initialize(index, rank = false)
    @index = index
    @type  = index.type
    @rank  = rank
  end

  def basic_search(phrase)
    @sets = []
    @phrase_words = phrase.gsub(/[^\w\s]/,"").split
    @phrase_words.each do |word|
      @sets << (@index.index[word.downcase] || Set.new)
    end
    generate_results
  end

  def stem_search(phrase)
    @sets = []
    @phrase_words = phrase.gsub(/[^\w\s]/,"").split.collect do |i|
      if RUBY_VERSION =~ /^1.9/
        i.downcase.stem_porter
      else
        i.downcase.stem
      end
    end
    @phrase_words.each do |word|
      @sets << (@index.index[word] || Set.new)
    end
    generate_results
  end

  def search(phrase)
    case @type
    when :stemmer
      stem_search(phrase)
    else
      basic_search(phrase)
    end
  end

  protected
  def generate_results
    @results = @sets.inject{|r,s| r & s}
    if @rank == false
      @results.to_a
    else
      rank(@results.to_a)
    end
  end

  def rank(results)
    results.sort { |x,y|
      @phrase_words.inject(0.0){|sum, i| sum += (3*@index.frequencies[i][x] + @index.positions[i][x])} <=>
      @phrase_words.inject(0.0){|sum, i| sum += (3*@index.frequencies[i][y] + @index.positions[i][y])}
    }.reverse
  end
end
