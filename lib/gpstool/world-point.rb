# This file is part of the "GPSTool" project, and is distributed under the MIT License.
# Copyright (c) 2011 Samuel G. D. Williams. <http://www.oriontransfer.co.nz>
# See <LICENSE.txt> for licensing details.

require 'gpstool/extensions/numeric'

module GPSTool
	class WorldPoint
		EARTH_RADIUS = 6371
	
		def initialize(datetime, latitude, longitude, altitude = EARTH_RADIUS)
			@datetime = datetime
			@latitude = latitude
			@longitude = longitude
			@altitude = altitude
		end
	
		attr :latitude
		attr :longitude
		attr :altitude
		attr :datetime
	
		def distanceTo(other)
			dLat = (other.latitude - self.latitude).to_radians
			dLon = (other.longitude - self.longitude).to_radians
		
			a = Math.sin(dLat/2) * Math.sin(dLat/2) +
				Math.cos(self.latitude.to_radians) * Math.cos(other.latitude.to_radians) * 
				Math.sin(dLon/2) * Math.sin(dLon/2)
		
			c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
		
			d = EARTH_RADIUS * c
		end
	
		def averageSpeedTo(other)
			# In Km
			distance = self.distanceTo(other)
		
			# In hours
			duration = (other.datetime - @datetime) * 24
		
			# In Km/hr
			return distance / duration
		end
	end
end
