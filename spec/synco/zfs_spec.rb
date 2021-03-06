#!/usr/bin/env rspec

# Copyright, 2016, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'logger'
require 'synco/script'
require 'synco/scope'
require 'synco/methods/zfs'

RSpec.describe Synco::Methods::ZFS do
	xit 'should mirror two ZFS partitions' do
		script = Synco::Script.build(master: :source) do |script|
			script.method = Synco::Methods::ZFS.new
			
			script.server(:master) do |server|
				server.host = 'hinoki.local'
				server.root = '/tank/test/source'
			end
			
			script.server(:backup) do |server|
				server.host = 'hinoki.local'
				server.root = '/tank/test/destination'
			end
			
			script.copy("./")
		end
		
		Synco::Runner.new(script).call
		
		expect(Fingerprint).to be_identical(script[:master].root, script[:backup].root)
	end
end
