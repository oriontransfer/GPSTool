# This file is part of the "GPSTool" project, and is distributed under the MIT License.
# Copyright (c) 2011 Samuel G. D. Williams. <http://www.oriontransfer.co.nz>
# See <LICENSE.txt> for licensing details.

module GPSTool
	class Device
		def self.open(path, options = {})
			return self.new(File.open(path, "rb+"), options)
		end
		
		def initialize(io, options = {})
			@io = io
			@errors = 0
			
			@options = options
		end
		
		attr :io
		attr :errors
		
		def close
			@io.close
		end
		
		def clear_io
			# Consume any pre-existing data
			pipes = nil
			while (pipes = IO.select([@io], [], [], 0.1))
				puts pipes.inspect
				
				buf = @io.read_nonblock(1024)
				$stderr.puts "(clear) -> " + buf.dump
			end
		end
		
		def send_message(message)
			unless Message === message
				message = Message.parse(message)
			end
			
			$stderr.puts "(write) <- " + message.to_s.dump
			@io.write(message.to_s + "\r\n")
		end
		
		def read_message(&block)
			message_class = @options[:message_class] || Message
			
			while true
				begin
					message = message_class.read(@io, @options)
					
					return unless yield message
				rescue
					@errors += 1
					
					raise
				end
			end
		end
	end
end
