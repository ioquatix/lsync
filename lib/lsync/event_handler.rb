# Copyright (c) 2007, 2011 Samuel G. D. Williams. <http://www.oriontransfer.co.nz>
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

module LSync
	
	# Basic event handling and delegation.
	module EventHandler
		# Register an event handler which may be triggered when an event is fired.
		def on(event, &block)
			@events ||= {}

			@events[event] ||= []
			@events[event] << block
		end

		# Fire an event which calls all registered event handlers in the order they were defined.
		# The first argument is used to #instance_eval any handlers.
		def fire(event, *args)
			handled = false
			
			scope = args.shift
			
			if @events && @events[event]
				@events[event].each do |handler|
					handled = true

					if scope
						scope.instance_exec *args, &handler
					else
						handler.call
					end
				end
			end
			
			return handled
		end
		
		# Try executing a given block of code and fire appropriate events.
		#
		# The sequence of events (registered via #on) are as follows:
		# [+:prepare+]  Fired before the block is executed. May call #abort! to cancel execution.
		# [+:success+]  Fired after the block of code has executed without raising an exception.
		# [+:failure+]  Fired if an exception is thrown during normal execution.
		# [+:done+]     Fired at the end of execution regardless of failure.
		#
		# If #abort! has been called in the past, this function returns immediately.
		def try(*arguments)
			return if @aborted
			
			begin
				catch(abort_name) do
					fire(:prepare, *arguments)
					
					yield
					
					fire(:success, *arguments)
				end
			rescue Exception => error
				# Propagage the exception unless it was handled in some specific way.
				raise unless fire(:failure, *arguments, error)
			ensure
				fire(:done, *arguments)
			end
		end
		
		# Abort the current event handler. Aborting an event handler persistently implies that in 
		# the future it will still be aborted; thus calling #try will have no effect.
		def abort!(persistent = false)
			@aborted = true if persistent
			
			throw abort_name
		end
		
		private
		
		# The name used for throwing abortions.
		def abort_name
			("abort_" + self.class.name).downcase.to_sym
		end
	end
	
end
