#!/usr/bin/env ruby
# WIWIZI 2008/2009
# Zadanie 1
# Autorzy: Jakub Kosinski (168225)
#          Jakub Kwasniewski (168274)

require 'rubygems'
require 'lib/wiwizi'
require 'optparse'
require 'progressbar'

@options = {:type => :basic, :dir => "data"}

def measure
  start = Time.now
  yield
  STDOUT.print "done in ", Time.now - start, "s\n"
  STDOUT.flush
end

def prepare_index
  return Index.load_index(@options[:index]) if @options[:index]
  index = Index.new(@options[:type])
  docs = Dir.glob(File.join(@options[:dir],"**","*")).reject{|file| File.directory? file}
  pbar = ProgressBar.new("indexing", docs.size)
  docs.each {|doc| index.index_document(doc); pbar.inc }
  pbar.finish
  if @options[:save]
    STDOUT.print "saving index..."
    STDOUT.flush
    measure { index.save_index(@options[:save]) }
  end
  index
end

OptionParser.new do |opts|
  opts.banner = "Boolan model search engine. (c) Jakub Kosinski, Jakub Kwasniewski"
  opts.separator ""
  opts.separator "Options:"

  opts.on("-d","--data DIR", "path to data directory. Default is 'data'") do |dir|
    @options[:dir] = dir
  end
  opts.on("-t","--type TYPE", [:basic, :stemmer], "index type, possible options: basic, stemmer. Default is basic") do |type|
    @options[:type] = type
  end
  opts.on("-f","--file FILE", "read index from given file") do |file|
    @options[:index] = file
  end
  opts.on("-b","--batch FILE", "read phrases from file (file format as described in task)") do |file|
    buff = File.readlines(file)
    @options[:times] = buff.first.to_i
    @options[:phrases] = buff.slice(1..-1)
  end
  opts.on("-s","--save FILE", "saves index to file") do |file|
    @options[:save] = file
  end

  opts.on_tail("-h","--help","shows this message") do
    puts opts
    exit
  end
end.parse(ARGV)

index  = prepare_index
search = Search.new(index)

# batch mode
if @options[:times] && @options[:phrases]
  measure do
    @options[:phrases].each do |phrase|
      @options[:times].times do
        measure { puts "Search results for phrase '#{phrase.strip}':\n#{search.search(phrase.strip).join("\n")}" }
      end
      puts
    end
  end
# interactive mode
else
  puts "Entering interactive mode. Type in .q(uit) to exit"
  loop do
    print '> '
    phrase = STDIN.readline.strip
    break if ['.q','.quit'].include? phrase
    measure{ puts search.search(phrase) }
  end
end
