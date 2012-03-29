require 'profiling'

unless ARGV.size == 2
  puts "usage: ruby process.rb <filename.ext> <config>"
  puts "  e.g.,"
  puts "    ruby process.rb video.mov all"
  puts "    ruby process.rb video.mov 8k"
  puts "    ruby process.rb video.mov 10m"
end

filename = ARGV[0]
config   = ARGV[1]

unless filename && File.exists?(filename)
  puts "\n\nfile does not exist."
  exit 1
end

class Processor
  extend  Profiling
  include Profiling

  attr_reader :path, :size

  def initialize(path)
    @path = path
    @size = File.size(path)
  end

  def read_all
    heading(:all)

    profile do |p|
      File.read(path) # NOTE: doing nothing with it
    end
  end

  def read_bytes(num)
    bytes = num.to_i
    bytes = (bytes * 1024)        if num =~ /.*k$/i
    bytes = (bytes * 1024 * 1024) if num =~ /.*m$/i

    heading(:part, bytes)

    profile do |p|
      offset = 0
      length = bytes

      while offset < size
        remain = size - offset
        amount = (remain < length) ? remain : length

        $stdout.print '.' # TODO: move to Profiling
        $stdout.flush

        File.read(path, amount, offset) # NOTE: doing nothing with it
        offset += amount
      end

      $stdout.puts
    end
  end

  def heading(mode, length = nil)
    puts ['   ', ('-' * 76)].join
    puts "   process.rb... reading #{size} bytes (#{[mode, length].compact.join(' ')})"
    puts ['   ', ('-' * 76)].join
  end

  # def self.cls_method
  #   profile do |p|
  #     # p.info("method body")
  #     "return value"
  #   end
  # end
end

if config == 'all'
  Processor.new(filename).read_all
else
  Processor.new(filename).read_bytes(config)
end
# Processor.cls_method
