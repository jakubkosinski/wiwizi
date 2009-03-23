#!/usr/bin/env ruby
# WIWIZI 2008/2009
# Zadanie 1
# Autorzy: Jakub Kosinski (168225)
#          Jakub Kwasniewski (168274)

require 'rubygems'
require 'lib/wiwizi'

DATA_DIR_MASK = "./data/**/*"
INDEX_TYPE    = :basic

def measure
  start = Time.now
  yield
  STDERR.print "done in ", Time.now - start, "s\n"
  STDERR.flush
end

measure do
  @index = Index.new(INDEX_TYPE)
  STDERR.print "Indexing..."
  STDERR.flush
  docs = Dir.glob(DATA_DIR_MASK).reject{|file| File.directory? file}
  docs.each {|doc| @index.index_document(doc)}
end

if ARGV.first == "-i"
  measure do
    buff = File.readlines(ARGV[1])
    times = buff.first.to_i
    buff.slice(1..-1).each do |phrase|
      times.times { Search.search(phrase.strip, @index.index, INDEX_TYPE) }
      puts
    end
  end
end
