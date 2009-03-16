require 'set'

class Indexer  
  attr_accessor :index
  
  def initialize
    @index = {}
  end
  
  def index_document(file_name)
    File.readlines(file_name).each do |line|
      line.split(" ").each do |token|
        token = token.downcase.strip
        token.gsub!(/[^\x00-\x7F]+/, '') # Remove anything non-ASCII entirely (e.g. diacritics).
        token.gsub!(/[^\w_ \-]+/i, '') # Remove unwanted chars.
        token.gsub!(/[ \-]+/i, '-') # No more than one of the separator in a row.
        token.gsub!(/^\-|\-$/i, '') # Remove leading/trailing separator.
        next if token == ""
        @index[token] ||= Set.new
        @index[token] << file_name unless @index[token].include?(file_name)
      end
    end
  end
  
  def find(phrase)
    start = Time.now
    sets = []
    phrase.split(" ").uniq.each do |word|
      sets << (@index[word] || Set.new)
    end
    result = sets.first
    result = sets.inject(result) {|r,s| r.intersection(s)}
    STDERR.print "Phrase '#{phrase}': ", Time.now - start, "s\n"
    result.each {|r| puts r}
    puts
  end
  
  def find_from_file(file)
    start = Time.now
    buff = File.readlines(file)
    times = buff.first.to_i
    buff.slice(1..-1).each do |phrase|
      times.times { find(phrase.strip) }
      puts
    end
    STDERR.print "Total: ", Time.now - start, "s\n"
  end
  
  def save_index(file)
    File.open(file, "wb") do |f|
      f << Marshal.dump(@index)
    end
  end
  
  def load_index_from_file(file)
    @index = Marshal.load(File.read(file))
  end
end

indexer = Indexer.new
start = Time.now
if File.exists? "/home/ghandal/index.dat"
  indexer.load_index_from_file("index.dat")
else
  STDERR.print "Indexing..."
  STDERR.flush
  docs    = Dir.glob("/home/ghandal/code/20news-28828/**/*").reject{|d| File.directory? d}
  docs.each {|doc| indexer.index_document(doc)}
  STDERR.print "done in ", Time.now-start, "s\n"
  STDERR.flush
  indexer.save_index("index.dat")
end
if ARGV.first == "-i"
  indexer.find_from_file(ARGV[1])
end
