#!/usr/bin/env ruby

require 'logger'

class Mylog < Logger
	def initialize(filename)
		if FileTest.exist?(filename)
			File.delete(filename)
		end
		@name = filename
		super(filename)
		self.datetime_format = '%Y-%m-%d %H:%M:%s'
		self.formatter = proc do |severity, datetime, progname, msg|
			"#{datetime}-#{severity}: #{msg}\n"
		end
	end

	def name
		@name
	end
end
