#  ArkManagerWeb::Errors::Error
module ArkManagerWeb
	module Errors
		class Error < RuntimeError
		end

		class ConfigNotFound < Error
		end

		class ArkManagerExeNotFound < Error
		end

		class ArkServerFolderNotFound < Error
		end

		class MemcachedNotFound < Error
		end

		class InstanceCfgNotFound < Error
		end
	end
end