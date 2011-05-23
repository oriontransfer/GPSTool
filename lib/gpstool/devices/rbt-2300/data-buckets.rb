# This file is part of the "GPSTool" project, and is distributed under the MIT License.
# Copyright (c) 2011 Samuel G. D. Williams. <http://www.oriontransfer.co.nz>
# See <LICENSE.txt> for licensing details.

module GPSTool
	module Devices
		module RBT2300
			
			class DataBuckets
				def initialize(expected_frames, frame_size)
					@expected_frames = expected_frames
					@frame_size = frame_size

					@data = "\0" * (@expected_frames * @frame_size)
					@buckets = [nil] * @expected_frames

					@progress = 0
				end

				attr :data
				attr :buckets
				attr :progress

				def append_data(frame_offset, data)
					frames_read = data.size / @frame_size
					@progress += frames_read

					@buckets[frame_offset] = frames_read

					mem_offset = frame_offset * @frame_size
					@data[mem_offset,data.size] = data

					return frames_read
				end

				def first_missing_bucket
					k = 0

					while k < @buckets.size
						c = @buckets[k]

						if c == nil
							return k
						elsif c > 0
							k += c
						else
							# $stderr.puts "Error finding missing bucket: #{@buckets.inspect}, #{k}, #{c}"
							k += 1
						end
					end

					if k == @buckets.size
						return nil
					else
						return k
					end
				end

				def missing_buckets(start)
					return nil if start == nil

					k = start

					while k < @buckets.size and @buckets[k] == nil
						k += 1
					end

					return k - start
				end
			end
			
		end
	end
end
