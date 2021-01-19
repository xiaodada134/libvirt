#!/usr/bin/env ruby

require 'erb'
require_relative 'hashugar'
require_relative 'base'

class Context < Base
	attr_reader :info

	def initialize(response)
		@info = response
	end

	def merge!(hash)
		@info.merge!(hash)
	end

	def expand_erb(template, context_hash={})
		@info.merge!(context_hash) 
		context = Hashugar.new(@info).instance_eval { binding }
		ERB.new(template, nil, '%').result(context) 
	end
end

