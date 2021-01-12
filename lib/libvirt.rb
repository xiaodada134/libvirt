#!/usr/bin/env ruby

require 'libvirt'
require_relative 'base'

class LibvirtConnect < Base
	def initialize
		@conn = Libvirt::open("qemu:///system")
	end

	def create(xml)
		@dom = @conn.define_domain_xml(File.read(xml))
		@dom.create
	end

	def wait
		loop do
			sleep 10
			unless @dom.active?
				@logger.info("The job is completed")
				break
			end
		end
	end

	def close
		@conn.close
	end
end
