#!/usr/bin/env ruby

require 'yaml'
require_relative 'base'

class Testbox < Base
	@@CONFIG_FILE = "#{ENV['LKP_SRC']}" || '/c/lkp-src'
	# attr_accessor :kernel, :initrd, :cmdline, :log_file, :host_config, :arch

	def initialize(hostname, response)
		@response = response
		@hostname = hostname
	end

	def load
		set_kernel_path
		set_initrd_path
		set_kernel_parameter
		set_arch
		parse_host_config
	end

	private def set_arch
		@arch = %x(arch).chomp
	end

	private def parse_host_config
		host_file = "#{@@CONFIG_FILE}/hosts/#{@hostname.split('.')[0]}"
		@host_config = YAML.load(File.read(host_file))
	end
		
	private def load_file(url)
		system "wget --timestamping -a wget.log --progress=bar:force #{url}"
		basename = File.basename(url)
		file_info = %x(ls -l "#{basename}").chomp
		@logger.info("FILE-#{basename.ljust(30)}: #{file_info}")
		File.realpath(basename)
	end

	private def set_kernel_path
		kernel_uri = @response['kernel_uri']
		@kernel = load_file(kernel_uri)
		@logger.info("kernel_path: #{@kernel}")
	end

	private def merge_initrd_file(file_list, target_name)
		initrds = file_list.join(" ")
		system "cat #{initrds} > #{target_name}"
	end

	private def set_initrd_path
		initrds_uri = @response['initrds_uri']
		initrds_path = []
		initrds_uri.each do |url|
			initrds_path << load_file(url)
		end
		merge_initrd_file(initrds_path, 'initrd')
		@initrd = File.realpath('initrd')

		@logger.info("initrd_path: #{@initrd}")
	end

	private def set_kernel_parameter
		@cmdline = @response['kernel_params']
		@logger.info("cmdline: #{@cmdline}")
	end
end
