# This file is part of the "GPSTool" project, and is distributed under the MIT License.
# Copyright (c) 2011 Samuel G. D. Williams. <http://www.oriontransfer.co.nz>
# See <LICENSE.txt> for licensing details.

class IO
	def readbytes(length)
		buffer = ""
		
		while buffer.size < length
			begin
				buffer += read(length - buffer.size)
				$stderr.puts "(*readbytes) -> #{buffer.dump}"
			rescue Errno::EAGAIN
				IO.select([self], [], [])
				retry
			end
		end
		
		return buffer
	end
end
