module SwellSocial
	module Concerns

		module ActiveRecordBaseExtensions
			extend ActiveSupport::Concern

			included do
				#scope :disabled, -> { where(disabled: true) }
				#after_create {
				#	if self.class.notify_attributes[:create].present?
				#
				#		content = self.class.notify_attributes[:create][:content]
				#		content = self.try( content ) if content.is_a? Symbol
				#
				#		title = self.class.notify_attributes[:create][:title]
				#		title = self.try( title ) if title.is_a? Symbol
				#
				#		actor = self.try( self.class.notify_attributes[:create][:actor] ) if self.class.notify_attributes[:create][:title].present?
				#
				#		self.send_notification( content, { title: title, actor: actor } )
				#
				#	end
				#}
			end


			####################################################
			# Class Methods

			module ClassMethods

				@notify_attributes = {}
				@notify_method = nil
				@notify_as_method = nil

				def notify_attributes
					@notify_attributes
				end

				def notify_method
					@notify_method
				end

				def notify_as_method
					@notify_as_method
				end

				def notify( method, args = {} )
					@notify_attributes = args
					@notify_method = method
				end

				def notify_as( method, args = {} )
					@notify_as_method = method
					@notify_attributes = args
				end

			end

			def send_notification( content, args = {} )

				event = args.delete(:event)

				notify_attributes = self.notify_attributes

				qualified_event = ( notify_attributes[:on].nil? || event.nil? || notify_attributes[:on] == event || notify_attributes[:on].include?( event ) )

				recipients = notify_attributes[:recipients]

				if qualified_event

					if self.class.notify_as_method.present?

						notify_as = self.try( self.class.notify_as_method )

						notify_as.send_notification( content, args ) if qualified_event

						true

					elsif self.class.notify_method.present?

						NotificationService.notify( recipients, content, args ) if recipients.present? && qualified_event

						true

					else

						false

					end

				else

					false

				end

			end



			def notify_attributes
				if self.class.notify_method

					recipients = self.try( self.class.notify_method )

					if recipients.nil?
						recipients = nil
					elsif recipients.is_a? ActiveRecord::Base
						recipients = [ recipients ]
					end

					self.class.notify_attributes.merge( recipients: recipients )

				else
					nil
				end
			end

		end

	end
end