#!/usr/bin/env ruby

require 'erb'
require_relative 'base'

class Job < Base

	def initialize(response)
		hash_to_instance_var(response)
	end
	
	def set_mac(mac)
		@mac = mac.gsub('-', ':')
	end
	
	def set_hostname(hostname)
		@hostname = hostname
		@log_file = "/srv/cci/serial/logs/#{hostname}"
	end

	def build(testbox)
		@kernel = testbox.kernel
		@initrd = testbox.initrd
		@cmdline = testbox.cmdline
		@arch = testbox.arch
		hash_to_instance_var(testbox.host_config)
	end
	
	def bind(template)
		return ERB.new(File.read(template)).result binding
	end

end
