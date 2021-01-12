#!/usr/bin/env ruby

require_relative 'base'

class Upload < Base
	def initialize(job, logger)
		@job = job
		@host = job.LKP_SERVER 
		@logger = logger
		# @port = job.RESULT_WEBDAV_POR
		@port = 3080
		get_result_url
	end

	private def get_result_url
		@result_url = "http://#{@host}:#{@port}#{@job.result_root}"
		@logger.debug("result_url: #{@result_url}")
	end
	
	def upload_qemu_log(file)
		system "cp #{file} libvirt.log"
		system "curl -sSf -T libvirt.log #{@result_url}/ --cookie 'JOBID= #{@job.job_id}'"
	end

	def upload_file_curl(file)
		system "curl -sSf -T #{file} #{@result_url}/ --cookie 'JOBID= #{@job.job_id}'"
	end
end
