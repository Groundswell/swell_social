module SwellSocial

	class Notification < ActiveRecord::Base
		self.table_name = 'notifications'

		before_save :set_default_publish_at

		enum status: { 'hidden' => 0, 'unnoticed' => 1, 'unread' => 2, 'read' => 3, 'archived' => 4, 'trash' => 5 }

		belongs_to		:user, class_name: SwellMedia.registered_user_class
		belongs_to		:actor, class_name: SwellMedia.registered_user_class
		belongs_to		:parent_obj, polymorphic: true
		belongs_to		:activity_obj, polymorphic: true
		belongs_to		:parent, foreign_key: :parent_id, class_name: Notification.name

		has_many :children, foreign_key: :parent_id, class_name: Notification.name

		has_many :actors, through: :children

		def self.active
			where( status: [1,2,3] )
		end

		def self.not_read
			where( status: [1,2] )
		end

		def published?
			self.publish_at < Time.now && %w(unnoticed unread read).include?( self.status.to_s )
		end

		def self.published
			where('publish_at < ?', Time.now).where( status: [ Notification.statuses['unnoticed'], Notification.statuses['unread'], Notification.statuses['read'] ] )
		end

		def actor_str( args = {} )

			args[:max_actors] ||= 3

			actor_shortlist = []
			total_actors = 0

			if children_count > 0
				actor_shortlist = User.joins("INNER JOIN (#{self.children.group(:actor_id).select(:actor_id, 'MIN(created_at) created_at').reorder('').to_sql}) user_post_children ON user_post_children.actor_id = users.id").order('user_post_children.created_at ASC')
				actor_shortlist = actor_shortlist.limit(args[:max_actors])

				total_actors = actor_shortlist.count
			elsif self.actor_id.present? && self.actor.present?
				actor_shortlist = [self.actor]
				total_actors = 1
			end

			actor_shortlist_join_count = [(actor_shortlist.count-2),0].max

			message_actors = actor_shortlist[0..actor_shortlist_join_count].collect{|user| "<a href='#{user.url}'>#{user}</a>" }.join(', ')

			if total_actors > actor_shortlist.count
				message_actors = "#{message_actors} and #{total_actors - actor_shortlist.count} others"
			elsif actor_shortlist.count > 1
				message_actors = "#{message_actors} and <a href='#{actor_shortlist.last.url}'>#{actor_shortlist.last}</a>"
			end

			message_actors

		end

		def sanitized_actor_message
			ActionView::Base.full_sanitizer.sanitize( self.actor_str )
		end

		def sanitized_title
			ActionView::Base.full_sanitizer.sanitize( self.title )
		end

		def to_s
			"#{self.actor_str} #{self.title}"
		end

		def active?
			unnoticed? || unread? || read?
		end

		protected
		def set_default_publish_at
			self.publish_at ||= Time.now
		end

	end

end