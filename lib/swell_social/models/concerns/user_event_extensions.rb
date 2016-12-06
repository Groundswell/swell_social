module SwellSocial
	module Concerns

		module UserEventExtensions
			extend ActiveSupport::Concern

			included do
				after_create :trigger_notifications
			end


			####################################################
			# Class Methods

			module ClassMethods


			end


			def trigger_notifications

				begin

					if parent_obj.present? && parent_obj.respond_to?( :send_notification )

						parent_obj.send_notification self.content, event: self.name.to_sym, actor: self.user, user_event: self #, regarding_obj: self.parent_obj

					end

				rescue => e
					logger.error 'UserEvent#trigger_notifications', e
				end

			end

		end

	end
end