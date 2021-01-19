#!/usr/bin/env ruby

require 'yaml'
require_relative 'base'
require_relative 'hashugar'

class Executor < Base
	attr_reader :info	

	def initialize(hostname, response)
		@hostname = hostname
		@response = Hashugar.new(response)
		@info = {}
	end

	def load
		set_log_file
		set_qemu_path
		set_arch
		set_host_config
		set_kernel_path
		set_initrd_path
		set_kernel_parameter
	end

	private
	def set_log_file
		@info['log_file'] = "#{@@LOG_DIR}/#{@hostname}"
	end

	def set_qemu_path
		cmd_path = %x(command -v qemu-kvm).chomp
		@info['qemu_path'] = cmd_path
	end
	
	def set_arch
		@info['arch'] = %x(arch).chomp
	end

	def set_host_config
		host_file = "#{@@CONFIG_FILE}/hosts/#{@hostname.split('.')[0]}"		
		@info.merge!(YAML.load(File.read(host_file)))
	end
		
	def load_file(url)
		system "wget --timestamping -a wget.log --progress=bar:force #{url}"
		basename = File.basename(url)
		file_info = %x(ls -l "#{basename}").chomp
		@logger.info("#{basename.ljust(30)}: #{file_info}")
		File.realpath(basename)
	end

	def set_kernel_path
		@info['kernel'] = load_file(@response.kernel_uri)
		@logger.info("Kernel_path: #{@info['kernel']}")
	end

	def merge_initrd_file(file_list, target_name)
		initrds = file_list.join(" ")
		system "cat #{initrds} > #{target_name}"
	end

	def set_initrd_path
		initrds_uri = @response.initrds_uri
		initrds_path = []
		initrds_uri.each do |url|
			initrds_path << load_file(url)
		end
		merge_initrd_file(initrds_path, 'initrd')
		@info['initrd'] = File.realpath('initrd')
		@logger.info("initrd_path: #{@info['initrd']}")
	end

	def set_kernel_parameter
		@info['cmdline'] = @response.kernel_params
		@logger.info("cmdline: #{@info['cmdline']}")
	end
end
