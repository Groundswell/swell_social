module SwellSocial

	class ObjectSubscription < ApplicationRecord
		self.table_name = 'object_subscriptions'

		enum status: { 'active' => 1, 'deleted' => 2 }
		enum availability: { 'just_me' => 1, 'anyone' => 2 }

		belongs_to	:user
		belongs_to	:parent_obj, polymorphic: true 

		def self.muted
			where.not( mute: false, status: 'active' )
		end

		def self.vocal
			where( mute: false, status: 'active' )
		end

		
	end
	
end