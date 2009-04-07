#!/usr/bin/env ruby
# WIWIZI 2008/2009
# Zadanie 1
# Autorzy: Jakub Kosinski (168225)
#          Jakub Kwasniewski (168274)

require 'rubygems'
require 'lib/wiwizi'

DATA_DIR_MASK = "./data/**/*"
INDEX_TYPE    = :stemmer

def measure
  start = Time.now
  yield
  STDERR.print "done in ", Time.now - start, "s\n"
  STDERR.flush
end

if $0 == __FILE__
  begin
    @index = Index.load_index()
  rescue
    measure do
      @index = Index.new(INDEX_TYPE)
      STDERR.print "Indexing..."
      STDERR.flush
      docs = Dir.glob(DATA_DIR_MASK).reject{|file| File.directory? file}
      docs.each {|doc| @index.index_document(doc)}
    end
  end
  
  if ARGV.first == "-i"
    @search = Search.new(@index, INDEX_TYPE)
    measure do
      buff = File.readlines(ARGV[1])
      times = buff.first.to_i
      buff.slice(1..-1).each do |phrase|
        times.times { puts "Search results for phrase '#{phrase.strip}':\n#{@search.search(phrase.strip).join("\n")}" }
        puts
      end
    end
  else
    @index.save_to_file()
  end
end
