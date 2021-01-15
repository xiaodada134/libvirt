#!/usr/bin/env ruby


class Base
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
