# This file is part of the "GPSTool" project, and is distributed under the MIT License.
# Copyright (c) 2011 Samuel G. D. Williams. <http://www.oriontransfer.co.nz>
# See <LICENSE.txt> for licensing details.

require 'gpstool/extensions/io'

module GPSTool
	class InvalidChecksumError < StandardError
		def initialize(data, sum)
			@data = data
			@sum = sum
		end
		
		attr :data
		attr :sum
		
		def to_s
			"Invalid Checksum: #{data.dump}*#{sum}, should be #{Message.checksum_hex(data)}"
		end
	end
	
	class Message
		@@messages = {}
		
		def self.checksum(data)
			sum = 0
			
			data.size.times do |i|
				sum = sum ^ data[i]
			end
			
			return sum
		end
		
		def self.checksum_hex(body)
			sprintf("%X", checksum(body).to_i).rjust(2, "0")
		end
		
		# This function performs validation and normalisation on the input data.
		def self.validate(data)
			data.strip!
			
			data = data[1..-1] if data[0,1] == "$"
			sum = nil
			
			if data[-3,1] == "*"
				sum = data[-2,2]
				data = data[0..-4]
				
				if checksum_hex(data) != sum
					raise InvalidChecksumError.new(data, sum)
				end
			end
			
			return data
		end
		
		def self.parse(data)
			data = self.validate(data)
			
			return self.new(data)
		end
		
		def self.read_body(io, name, options)
			return self.parse('$' + name + io.gets)
		end
		
		def self.read(io, options = {})
			# Try to synchronise to the start message boundary
			while io.readbytes(1) != '$'
			end

			name = ''
			while true
				c = io.readbytes(1)
				
				if c == ',' || c == '*'
					io.ungetc(c[0])
					return self.read_body(io, name, options)
				end

				name += c
			end
		end
		
		def initialize(body)
			if Array === body
				@name = body.shift
				@parts = body
			else
				@name, @parts = body.split(",", 2)
			
				if @parts
					if structure == nil
						@parts = @parts.split(",")
					elsif structure.size > 1
						@parts = @parts.split(",", structure.size)
					else
						@parts = [@parts]
					end
				else
					@parts = []
				end
			end
		end
		
		attr :parts
		attr :name
		
		def structure
			messages = self.class.class_eval('@@messages')
			messages[@name]
		end

		def to_hash
			result = {}
			structure.each_with_index do |n,i|
				result[n] = @parts[i] if n
			end
		end

		def [](key)
			if structure
				offset = structure.index(key)
				return @parts[offset]
			end

			return nil
		end
		
		def to_s
			body = nil
			
			if @parts.length > 0
				body = "#{@name},#{@parts.join(',')}"
			else
				body = @name
			end
			
			sum = self.class.checksum_hex(body)
			
			return "$#{body}*#{sum}"
		end
	end
end
