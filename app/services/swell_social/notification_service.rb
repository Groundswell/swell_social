
module SwellSocial

	class NotificationService

		def self.notify( recipients, content, args = {} )
			# @todo insert more efficiently
			# @todo start a job to process event notifications... they don't need to be synchronous
			# @todo run a cron which batches events together into a notification (Mac Knife and 3 other products have dropped in price)

			title 			= args[:title]
			user_event 	= args[:user_event]
			status 			= args[:status] || 'unread'
			actor 			= args[:actor]


			recipients.each do | recipient |

					user = recipient
					user = recipient.user if recipient.is_a? ObjectSubscription

					Notification.create user: user, actor: actor, content: content, title: title, status: status, user_event: user_event
					# @coulddo push notifications
					# @todo count updates

			end

		end

	end

end