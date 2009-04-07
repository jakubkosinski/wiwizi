require 'set'
require 'fast_stemmer'
require 'index'

class Search
  attr_accessor :type

  def initialize(index, type = :basic)
    @index = index
    @type  = type
  end

  def basic_search(phrase)
    @sets = []
    @phrase_words = phrase.gsub(/[^\w\s]/,"").split
    @phrase_words.each do |word|
      @sets << @index.index[word.downcase]
    end
    generate_results
  end

  def stem_search(phrase)
    @sets = []
    @phrase_words = phrase.gsub(/[^\w\s]/,"").split.collect{|i| i.stem}.delete_if {|i| Index::COMMON_WORDS.include? i.downcase}
    @phrase_words.each do |word|
      @sets << @index.index[word.downcase]
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
    @results = @sets.inject{|r,s| r.intersection s}
    if @type == :basic
      @results.to_a
    else
      @results.to_a.sort{|x,y| @phrase_words.inject(0){|sum, i| sum += @index.frequencies[i][x]} <=> @phrase_words.inject(0){|sum, i| sum += @index.frequencies[i][y]} }.reverse
    end
  end
end
