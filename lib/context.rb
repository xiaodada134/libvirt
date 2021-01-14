#!/usr/bin/env ruby

require 'erb'
require_relative 'base'
require_relative '/c/lkp-tests/lib/hashugar'

class Context < Base
	attr_reader :config

	def initialize(response)
		@config = Hashugar.new(response)
	end

	def merge!(hashugar)
		@config.merge!(hashugar)
	end

	def expand_erb(template, contest_hash={})
		@config.merge!(context_hash) 
		context = @config.instance_eval { binding }
		ERB.new(template, nil, '%').result(context) 
	end
end
