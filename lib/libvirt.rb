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
		@upload.upload_qemu_log
	end

	def wait
		loop do
			sleep 10
			@upload.upload_vm_log
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
