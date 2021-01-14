#!/usr/bin/env ruby

require 'json'
require 'set'
require 'nokogiri'
require_relative 'base'

# get templates from local or default
# support 
# case 1:
# 	user define a domain.xml on job
# case 2:
# 	user default templates
# case 3:
# 	TODO:user define cpu disk ...
class Templates < Base
	@@USER_DIR = "#{ENV['LKP_SRC']}/hosts"
	@@TEMPLATE_DIR = "#{ENV['CCI_SRC']}/providers/libvirt/templates"
	@@default_templates = {
		'domain' => "#{@@TEMPLATE_DIR}/domain.xml",
		'name' => "#{@@TEMPLATE_DIR}/name.xml",
		'os' => "#{@@TEMPLATE_DIR}/os.xml",
		'cpu' => "#{@@TEMPLATE_DIR}/cpu.xml",
		'memory' => "#{@@TEMPLATE_DIR}/memory.xml",
		'interface' => "#{@@TEMPLATE_DIR}/interface.xml",
		'disk' => "#{@@TEMPLATE_DIR}/disk.xml",
		'devices' => "#{@@TEMPLATE_DIR}/devices.xml",
		'serial' => "#{@@TEMPLATE_DIR}/serial.xml",
		'clock' => "#{@@TEMPLATE_DIR}/clock.xml",
		'on_active' => "#{@@TEMPLATE_DIR}/on_active.xml",
		'seclabel' => "#{@@TEMPLATE_DIR}/seclabel.xml"
	}
	@doc = nil

	def initialize(job)
		@job = job
	end

	def create_domain
	end
	
	def get_final_template
		if !@job.templates.nil? && @job.templates.key?('domain')
			@logger.debug("user define a domain.xml")
			user_domain
			return
		end
		@logger.debug("use our default template")
		default_domain
	end

	def save
		File.open('domain.xml', 'w') do |f|
			f.puts @doc.to_xml
		end
		File.realpath('domain.xml')
	end
	
	# user have not define domain.xml use default
	private def default_domain
		set_domain @@default_templates['domain']
		set_cpu
		set_clock
		set_on_active
		set_devices
		set_seclabel
		set_serial
		
		# this config must set at the end
		# set_interface must set after set_devices	
		set_common
	end

	# user have been define domaix.xml at LKP_SRC/hosts/
	private def user_domain
		# only support from local
		set_domain "#{@@USER_DIR}/#{@job.templates['domain']}"
		@logger.debug("user's templates at #{@@USER_DIR}/#{@job.templates['domain']}")
		set_common
	end

	private def set_common
		# each job these elements must be use default
		set_name
		set_memory
		set_os
		set_interface
		set_serial
		set_on_active
	end

	private def set_domain(file)
		@doc = Nokogiri::XML(@job.bind(file))
	end

	private def set_name
		@doc.xpath('//domain/name').remove
		@doc.root.add_child @job.bind(@@default_templates['name'])
	end

	private def set_memory
		@doc.xpath('//domain/memory').remove
		@doc.xpath('//domain/currentMemory').remove
		@doc.xpath('//domain/maxMemory').remove
		@doc.root.add_child @job.bind(@@default_templates['memory'])
	end

	private def set_os
		@doc.xpath('//domain/os').remove
		@doc.root.add_child @job.bind(@@default_templates['os'])
	end
	
	private def set_interface
		@doc.xpath('//domain/devices/interface').remove
		@doc.xpath('//domain/devices')[0].add_child @job.bind(@@default_templates['interface'])
	end

	private def set_cpu
		@doc.root.add_child @job.bind(@@default_templates['cpu'])
	end

	private def set_clock
		@doc.root.add_child @job.bind(@@default_templates['clock'])
	end

	private def set_on_active
		@doc.xpath('//domain/on_poweroff').remove
		@doc.xpath('//domain/on_reboot').remove
		@doc.xpath('//domain/on_crash').remove
		@doc.root.add_child @job.bind(@@default_templates['on_active'])
	end

	private def set_devices
		@doc.root.add_child @job.bind(@@default_templates['devices'])
	end

	private def set_serial
		# default serial can redirect vm log to a file
		@doc.xpath('//domain/devices/serial').remove
		@doc.xpath('//domain/devices')[0].add_child @job.bind(@@default_templates['serial'])
	end

	private def set_seclabel
		@doc.root.add_child @job.bind(@@default_templates['seclabel'])
	end
end
