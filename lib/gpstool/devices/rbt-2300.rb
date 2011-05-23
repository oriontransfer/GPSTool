# This file is part of the "GPSTool" project, and is distributed under the MIT License.
# Copyright (c) 2011 Samuel G. D. Williams. <http://www.oriontransfer.co.nz>
# See <LICENSE.txt> for licensing details.

require 'gpstool/device'
require 'gpstool/devices/rbt-2300/data-buckets'
require 'gpstool/devices/rbt-2300/data-parser'

require 'date'

module GPSTool
	module Devices
		module RBT2300
			class Message < ::GPSTool::Message
				@@messages = {
					"LOG101" => [:date, :mode, :frames, :pointer],
					"LOG102" => [:data],
					"LOG108" => [:mode, nil, nil, :overwrite, nil, :rate, nil, :files, nil]
				}
				
				def self.read_body(io, name, options)
					if (name == "LOG102")
						buffer = '$' + name
						buffer += io.readbytes(1)
						
						header_data = io.readbytes(3)
						buffer += header_data
						
						if header_data[0,2] == "0*"
							# This is sometimes a response when
							# an invalid segment is requested
							buffer += io.gets
							
							self.validate(buffer)
							
							return self.new([name, nil])
						else
							header = header_data.unpack("CCC")
						
							# Frame count is in bytes
							data_size = header[2]
							data = io.readbytes(data_size)
						
							buffer += data
							buffer += io.gets
						
							# Check that the data was correct
							self.validate(buffer)
						
							return self.new([name, header_data + data])
						end
					else
						return super(io, name, options)
					end
				end
			end
			
			MAX_PACKET_SIZE = 0xF0

			def self.parse_date(log)
				log[:date].match(/([0-9]{4})([0-9]{2})([0-9]{2})/)
				date = Date.civil($1.to_i, $2.to_i, $3.to_i)

				return date
			end

			def self.update_config(update_time, mode)
				update_time = update_time.to_i

				if update_time < 1 or update_time > 60
					raise ArgumentError.new("Update time must be between 1-60 inclusive.")
				end

				mode = mode.to_i

				if mode < 0 || mode > 3
					raise ArgumentError.new("Mode must be one of 0, 1, 2.")
				end

				a = 0
				b = update_time.to_i
				c = mode
				d = 0

				return Message.parse("PROY104,#{a},#{b},#{c},#{d}")
			end

			def self.read_log_data(data)
				header = data[0..3].unpack("CCC")
				data = data[3..-1]

				return header, data
			end

			def self.estimate_packet_count(frame_sz, count)
				((frame_sz * count).to_f / MAX_PACKET_SIZE).ceil.to_i
			end
		end
	end
end
