require 'tempfile'
require 'pathname'
require 'tmpdir'

def with_tmpfile(content=nil)
  tmpf = Tempfile.new 'spec'
  tmpf.write content
  tmpf.close

  results = yield tmpf.path, tmpf

  tmpf.unlink
  results
end

def in_tmpdir
  Dir.mktmpdir do |tmpd|
    Dir.chdir tmpd do
      yield
    end
  end
end

def dedent(s)
  indent = s.split("\n").reject {|l| l =~ /^\s*$/}.map {|l| l.index /\S/ }.min
  s.sub(/^\n/, '').gsub(/ +$/, '').gsub(/^ {#{indent}}/, '')
end

def indent(s, indent=4)
  s.gsub(/^/, ' ' * indent)
end

def say_bold(text)
  say "<%= BOLD %>#{text}<%= CLEAR %>"
end

class Exception
  def bt
    backtrace.map do |l|
      cwd = Dir.pwd
      l.start_with?(cwd) ? l.sub(cwd, '.') : l
    end
  end
end
