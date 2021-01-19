#!/usr/bin/env ruby

require 'set'
require 'yaml'
require 'json'
require_relative 'base'
require_relative "#{ENV['CCI_SRC']}/container/defconfig"


# configuration information of the test device
class Consumer < Base
	attr_reader :info
	
	def initialize(hostname, queues)
		@info = {}	
		@info['hostname'] = hostname
		@info['queues'] = queues
	end

	def close
		del_host_info
	end
	
	def request_job
		get_mac_from_hostname(@info['hostname'])
		config_scheduler
		set_host_info
		host_exists
		url = "http://#{@sched_host}:#{@sched_port}/boot.libvirt/mac/#{@info['mac']}"
		@logger.info("Request URL: #{url}")
		res = %x(curl #{url})
		if res.empty?
			@logger.error('Can not connect scheduler')
			raise 'Can not connect scheduler'
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
		@logger.info("SCHED_HOST: #{@sched_host}")
		@logger.info("SCHED_PORT: #{@sched_port}")
	end

	private def get_mac_from_hostname(hostname)
		cmd = %Q(echo #{hostname} | md5sum | sed "s/^\\(..\\)\\(..\\)\\(..\\)\\(..\\)\\(..\\).*$/0a-\\1-\\2-\\3-\\4-\\5/")
		@info['mac'] = %x(#{cmd}).chomp
		@logger.info("Mac address: #{@info['mac']}")
	end

	private def set_host_info
		system "curl -X PUT 'http://#{@sched_host}:#{@sched_port}/set_host_mac?hostname=#{@info['hostname']}&mac=#{@info['mac']}'"
		system "curl -X PUT 'http://#{@sched_host}:#{@sched_port}/set_host2queues?host=#{@info['hostname']}&queues=#{@info['queues']}'"
	end

	private def del_host_info
		system "curl -X PUT 'http://#{@sched_host}:#{@sched_port}/del_host_mac?mac=#{@info['mac']}'"
		system "curl -X PUT 'http://#{@sched_host}:#{@sched_port}/del_host2queues?host=#{@info['hostname']}'"
	end
	
	private def host_exists
		@info['host'] = @info['hostname'].split('.')[0]
		host_file = "#{@@LKP_SRC}/hosts/#{@info['host']}"
		unless FileTest.exists?(host_file)
			@logger.error("#{@info['host']} file not exist")
			raise "#{@info['host']} file not exist"
		end
	end
end
