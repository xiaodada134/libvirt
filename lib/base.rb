#!/usr/bin/env ruby


class Base
	@@CONFIG_FILE = "#{ENV['LKP_SRC']}" || '/c/lkp-src'
	@@LOG_DIR = '/srv/cci/serial/logs'
	@@LKP_SRC = "#{ENV['LKP_SRC']}" || '/c/lkp-src'
	@@USER_DIR = "#{ENV['LKP_SRC']}/hosts"
	@@TEMPLATE_DIR = "#{ENV['CCI_SRC']}/providers/libvirt/templates"
	@@OPTION_FILE = "#{@@TEMPLATE_DIR}/option.yaml"


	attr_reader :logger, :upload

	def set_logger(logger)
		@logger = logger
		self
	end

	def set_upload(upload)
		@upload = upload
		self
	end
end
