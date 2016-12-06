module SwellSocial
	class Message < ActiveRecord::Base
		self.table_name = 'messages'

		belongs_to :user, class_name: SwellMedia.registered_user_class
		belongs_to :sender, class_name: SwellMedia.registered_user_class

		enum status: { 'unnoticed' => 1, 'unread' => 2, 'read' => 3, 'archived' => 4, 'trash' => 5 }

		def self.active
			where( status: [1,2,3] )
		end

		def unread?
			super() || unnoticed?
		end

		def active?
			unnoticed? || unread? || read?
		end
		
	end
end