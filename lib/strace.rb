require 'open4'

##
# Simple wrapper of strace(1) for targetted tracing.

module Strace

  ##
  # The version of strace_me you're using

  VERSION = '1.0'

  ##
  # Runs strace(1) during the code in the block and returns an IO containing
  # the strace output and the exception raised by the block (if any).
  #
  # Simple example (it doesn't matter if you have a /COPYRIGHT):
  #
  #   trace, err = Strace.me do
  #     open '/COPYRIGHT' do |io|
  #       io.read 1024
  #     end
  #   end
  #
  #   puts "error: #{err.message} (#{err.class})\n\n" if err
  #   puts "trace:\n\n#{trace.read}"
  #
  # Tracing an existing library call:
  #
  #   alias old_connect connect
  #
  #   def connect host, user, password
  #     connection = nil
  #
  #     trace, err = Strace.me do
  #       connection = old_connect host, user, password
  #     end
  #
  #     $stderr.puts "connect trace:\n\n#{trace.read}"
  #
  #     raise err if err
  #     connection
  #   end

  def self.me
    pid, i, o, e = Open4.open4 'strace', '-p', $$.to_s

    i.close
    e.gets # consumes "attached" message, but we know strace is ready

    begin
      yield
    ensure
      Process.kill 'INT', pid
      Process.waitpid pid

      return [e, $!]
    end
  end

end

