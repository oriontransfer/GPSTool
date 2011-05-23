# This file is part of the "GPSTool" project, and is distributed under the MIT License.
# Copyright (c) 2011 Samuel G. D. Williams. <http://www.oriontransfer.co.nz>
# See <LICENSE.txt> for licensing details.

module GPSTool
	module Filters
		module Distance
			def self.filter_points(points, options)
				filtered_points = []
				i = 0
				
				while i < points.size
					current = points[i]
					
					filtered_points << current
					
					j = i + 1
					
					while j < points.size
						step = points[j]
						distance = current.distanceTo(step)
						
						break if distance < options[:distance]
						
						j += 1
					end
					
					i = j
				end
				
				return filtered_points
			end
		end
	end
end
