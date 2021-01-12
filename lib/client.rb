#!/usr/bin/env ruby

require 'set'
require 'yaml'
require 'json'
require_relative 'base'
require_relative "#{ENV['CCI_SRC']}/container/defconfig"


# configuration information of the test device
class Client < Base
	LKP_SRC = "#{ENV['LKP_SRC']}" || '/c/lkp-src'
	
	def initialize(hostname, queues)
		@hostname = hostname
		@queues = queues
	end

	def connect	
		get_mac_from_hostname(@hostname)
		config_scheduler
		set_host_info
		host_exists
	end
	
	def close
		del_host_info
	end
	
	def request_job
		url = "http://#{@sched_host}:#{@sched_port}/boot.libvirt/mac/#{@mac}"
		@logger.info("url: #{url}")
		res = %x(curl #{url})
		if res.empty?
			@logger.error('can not connect scheduler')
			raise 'can not connect scheduler'
		end
		JSON.parse(res)
	end

	private def config_scheduler
		names = Set.new %w[
			SCHED_HOST
			SCHED_PORT
		]
		defaults = relevant_defaults(names)
		@sched_host = defaults['SCHED_HOST'] || '172.17.0.1'
		@sched_port = defaults['SCHED_PORT'] || 3000
		# outputting information to log files
		@logger.info("SCHED_HOST: #{@sched_host}")
		@logger.info("SCHED_PORT: #{@sched_port}")
	end

	private def get_mac_from_hostname(hostname)
		cmd = %Q(echo #{hostname} | md5sum | sed "s/^\\(..\\)\\(..\\)\\(..\\)\\(..\\)\\(..\\).*$/0a-\\1-\\2-\\3-\\4-\\5/")
		@mac = %x(#{cmd}).chomp
		@logger.info("mac: #{@mac}")
	end

	private def set_host_info
		system "curl -X PUT 'http://#{@sched_host}:#{@sched_port}/set_host_mac?hostname=#{@hostname}&mac=#{@mac}'"
		system "curl -X PUT 'http://#{@sched_host}:#{@sched_port}/set_host2queues?host=#{@hostname}&queues=#{@queues}'"
	end

	private def del_host_info
		system "curl -X PUT 'http://#{@sched_host}:#{@sched_port}/del_host_mac?mac=#{@mac}'"
		system "curl -X PUT 'http://#{@sched_host}:#{@sched_port}/del_host2queues?host=#{@hostname}'"
	end
	
	private def host_exists
		@host = @hostname.split('.')[0]
		host_file = "#{LKP_SRC}/hosts/#{@host}"
		unless FileTest.exists?(host_file)
			@logger.error("#{@host} file not exist")
			raise "#{@host} file not exist"
		end
	end
end
