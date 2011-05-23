# This file is part of the "GPSTool" project, and is distributed under the MIT License.
# Copyright (c) 2011 Samuel G. D. Williams. <http://www.oriontransfer.co.nz>
# See <LICENSE.txt> for licensing details.

class Numeric
	def to_radians
		self.to_f / 180.0 * Math::PI
	end
end
