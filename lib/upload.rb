#!/usr/bin/env ruby

require_relative 'base'

class Upload
	@@qemu_log_dir = '/var/log/libvirt/qemu'

	def initialize(context, logger)
		@logger = logger
		@job_id = context.info['job_id']
		@boot_log_file = context.info['log_file']
		@result_root = context.info['result_root']
		@host   = context.info['LKP_SERVER']
		@port   = 3080
		get_result_url
	end
	
	private def get_result_url
		@result_url = "http://#{@host}:#{@port}#{@result_root}"
	end
	
	# /var/log/libvirt/qemu/xxx.log
	def upload_qemu_log
		system "curl -sSf -T #{@@qemu_log_dir}/#{@job_id}.log #{@result_url}/ --cookie 'JOBID= #{@job_id}'"
	end

	# vm start log
	def upload_vm_log
		system "curl -sSf -T #{@boot_log_file} #{@result_url}/ --cookie 'JOBID= #{@job_id}'"
	end

	# client log
	def upload_client_log
		system "curl -sSf -T #{@logger.name} #{@result_url}/ --cookie 'JOBID= #{@job_id}'"
	end

	def upload_file(file)
		system "curl -sSf -T #{file} #{@result_url}/ --cookie 'JOBID= #{@job_id}'"
	end
end
