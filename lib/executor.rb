#!/usr/bin/env ruby

require 'yaml'
require_relative 'base'
require_relative 'hashugar'

class Executor < Base
	@@CONFIG_FILE = "#{ENV['LKP_SRC']}" || '/c/lkp-src'
	@@LOG_DIR = '/srv/cci/serial/logs'
	
	@config = nil

	def initialize(hostname, response)
		@hostname = hostname
		@config = Hashugar.new(response)
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
		@config.log_file = "#{@@LOG_DIR}/#{hostname}"
	end

	def set_qemu_path
		cmd_path = %x(command -v qemu-kvm).chomp
		@config.qemu_path = cmd_path
	end
	
	def set_arch
		@config.arch = %x(arch).chomp
	end

	def set_host_config
		host_file = "#{@@CONFIG_FILE}/hosts/#{@hostname.split('.')[0]}"		
		@config.merge!(YAML.load(File.read(host_file)))
	end
		
	def load_file(url)
		system "wget --timestamping -a wget.log --progress=bar:force #{url}"
		basename = File.basename(url)
		file_info = %x(ls -l "#{basename}").chomp
		@logger.info("#{basename.ljust(30)}: #{file_info}")
		File.realpath(basename)
	end

	def set_kernel_path
		@config.kernel = load_file(@config.kernel_uri)
		@logger.info("Kernel_path: #{@kernel}")
	end

	def merge_initrd_file(file_list, target_name)
		initrds = file_list.join(" ")
		system "cat #{initrds} > #{target_name}"
	end

	def set_initrd_path
		initrds_uri = @config.initrds_uri
		initrds_path = []
		initrds_uri.each do |url|
			initrds_path << load_file(url)
		end
		merge_initrd_file(initrds_path, 'initrd')
		@config.initrd = File.realpath('initrd')
		@logger.info("initrd_path: #{@initrd}")
	end

	def set_kernel_parameter
		@config.cmdline = @config.kernel_params
		@logger.info("cmdline: #{@cmdline}")
	end
end
