
require 'awesome_nested_set'
require 'swell_social/models/concerns/active_record_base_extensions'
require 'swell_social/models/concerns/user_event_extensions'

module SwellSocial
	class Engine < ::Rails::Engine
		isolate_namespace SwellSocial

		#ActiveRecord::Base.send :include, SwellSocial::Concerns::ActiveRecordBaseExtensions

		initializer "swell_social.load_helpers" do |app|
			#SwellMedia::UserEvent.send :include, SwellSocial::Concerns::UserEventExtensions
		end

		config.generators do |g|
			g.test_framework :rspec
			g.fixture_replacement :factory_girl, :dir => 'spec/factories'
		end
		
	end
end
