require 'set'
require 'stemmer'
require 'index'

class Search
  def self.basic_search(phrase, index)
    @@sets = []
    phrase.gsub(/[^\w\s]/,"").split.each do |word|
      @@sets << index[word.stem]
    end
    puts "Search results for phrase '#{phrase}':"
    generate_results
  end

  def self.stem_search(phrase, index)
    @@sets = []
    phrase.gsub(/[^\w\s]/,"").split.each do |word|
      @@sets << index[word.stem]
    end
    generate_results
  end

  def self.search(phrase, index, type)
    case type
    when :stem
      self.class.stem_search(phrase, index)
    else
      self.class.basic_search(phrase, index)
    end
  end

  protected
  def generate_results
    @@results = @@sets.inject{|r,s| r.intersection s}
    puts @@results.to_a.join("\n")
    @@results
  end
end
