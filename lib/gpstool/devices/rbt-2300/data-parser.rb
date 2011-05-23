# This file is part of the "GPSTool" project, and is distributed under the MIT License.
# Copyright (c) 2011 Samuel G. D. Williams. <http://www.oriontransfer.co.nz>
# See <LICENSE.txt> for licensing details.

module GPSTool
	module Devices
		module RBT2300
			def self.floats_for_format(format)
				return 2 + format.to_i
			end

			def self.frame_size(format)
				# HEADER(4 bytes) + (sizeof(float) * count)
				return 4 + (floats_for_format(format) * 4)
			end

			def self.frames_per_packet(format)
				return 240 / frame_size(format)
			end
			
			class DataParser
				def initialize(format = 0)
					@frames = []
					@floats = RBT2300::floats_for_format(format)
				end

				attr :frames

				def append_data(datas)
					sz = 4 + (@floats * 4)

					while datas.size >= sz
						# Pop buf off the front
						buf = datas[0...sz]
						datas = datas[sz..-1]

						#puts "Inspecting data: #{buf.inspect}"

						# Extract Date
						date = buf.unpack("CCCC")
						#puts "Extracted date: #{date.inspect}"
						bufo = buf[4..-1]

						# We need to extract IEEE floats
						buf = bufo.unpack("C*").reverse.pack("C*")
						numbers = buf.unpack("g" * @floats).reverse

						@frames << [date, numbers]
					end
				end
			end

		end
	end
end
