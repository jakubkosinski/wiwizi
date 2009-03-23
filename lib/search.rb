require 'set'
require 'stemmer'
require 'index'

class Search
  def self.basic_search(phrase, index)
    @@sets = []
    phrase.gsub(/[^\w\s]/,"").split.each do |word|
      @@sets << index[word.downcase]
    end
    puts "Search results for phrase '#{phrase}':"
    self.generate_results
  end

  def self.stem_search(phrase, index)
    @@sets = []
    phrase.gsub(/[^\w\s]/,"").split.each do |word|
      @@sets << index[word.downcase.stem]
    end
    self.generate_results
  end

  def self.search(phrase, index, type)
    case type
    when :stem
      self.stem_search(phrase, index)
    else
      self.basic_search(phrase, index)
    end
  end

  protected
  def self.generate_results
    @@results = @@sets.inject{|r,s| r.intersection s}
    puts @@results.to_a.join("\n")
    @@results
  end
end
