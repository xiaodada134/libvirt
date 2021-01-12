#!/usr/bin/env ruby

require 'libvirt'
require_relative 'base'

class LibvirtConnect < Base
	def initialize
		@conn = Libvirt::open("qemu:///system")
	end

	def create(xml)
		begin
			@dom = @conn.define_domain_xml(File.read(xml))
		rescue Exception => e
			@logger.error(e.message)
			raise 'libvirt define error'
		end
		@dom.create
		@logger.info(@dom.info)
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
