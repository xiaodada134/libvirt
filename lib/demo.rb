#!/usr/bin/env ruby
require_relative 'hashugar'

#a = Hashugar.new({'a'=> 1, 'b' => 2})
#b = Hashugar.new({'b'=> 22, 'c' => 2})
#
#b.log=123
#
#puts a.to_hash
#puts a.merge!(b.to_hash)
#puts a.log

class A

	def initialize(list)
		@list = list
	end

	def action
		@list.each do |one|
			self.instance_eval one
		end
	end

	def say
		puts "--------- say"
	end

	def hello
		puts '----------- hello'
	end
end
a = A.new(['say', 'hello'])
a.action
