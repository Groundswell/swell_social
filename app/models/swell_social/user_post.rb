
module SwellSocial

	class UserPost < ActiveRecord::Base
		self.table_name = 'user_posts'
		include SwellMedia::Concerns::TagArrayConcern

		before_save	:set_cached_counts, :update_content_hash

		enum status: { 'to_moderate' => -1, 'draft' => 0, 'active' => 1, 'removed' => 2, 'trash' => 3 }
		enum availability: { 'just_me' => 1, 'anyone' => 2 }

		validate 				:check_duplicates
		validates_presence_of 	:content, if: :validate_presence_of_content?

		attr_accessor	:allow_blank_content


		belongs_to :user, class_name: SwellMedia.registered_user_class
		belongs_to :actor, class_name: SwellMedia.registered_user_class
		belongs_to :parent_obj, polymorphic: true

		has_many 		:replies, class_name: UserPost.name, foreign_key: 'reply_to_id', inverse_of: :reply_to
		belongs_to 	:reply_to, class_name: UserPost.name, inverse_of: :replies

		acts_as_taggable_array_on :tags

		include FriendlyId
		friendly_id :slugger, use: :slugged

		def char_count
			return 0 if self.content.blank?
			self.sanitized_content.size
		end

		def compute_content_hash
			Digest::SHA1.hexdigest(self.content || '')
		end

		def self.not_reply
			where( reply_to_id: nil )
		end

		def self.reply
			where.not( reply_to_id: nil )
		end

		def reply?
			not( reply_to_id.nil? )
		end

		def root_user_post
			if reply?
				reply_to.root_user_post || reply_to
			else
				nil
			end
		end

		def sanitized_content
			ActionView::Base.full_sanitizer.sanitize( self.content )
		end

		def word_count
			return 0 if self.content.blank?
			self.sanitized_content.scan(/[\w-]+/).size
		end

		def self.within_last( period=1.minute )
			period_ago = Time.zone.now - period
			where( "created_at >= ?", period_ago )
		end

		def self.has_content
			where("((content = '') IS FALSE)")
		end

		def self.no_content
			where.not("((content = '') IS FALSE)")
		end

		def self.order_has_content_desc
			order( "((content = '') IS FALSE) DESC" )
		end

		def self.order_has_content_asc
			order( "((content = '') IS FALSE) ASC" )
		end

		def to_s
			"#{self.user}'s comment on #{self.parent_obj.to_s}"
		end

		def url( args={} )
			self.parent_obj.url( args ) + "##{self.class.name.to_s.demodulize}_#{self.id}"
		end


		protected

			def validate_presence_of_content?
				not( self.allow_blank_content ) && self.content_changed?
			end

		private

			def update_content_hash
				self.content_hash = compute_content_hash if self.respond_to?( :content_hash )
			end

			def set_cached_counts
				if self.respond_to?( :cached_word_count )
					self.cached_word_count = self.word_count
				end

				if self.respond_to?( :cached_char_count )
					self.cached_char_count = self.char_count
				end
			end

			def check_duplicates
				if self.persisted? || self.content.blank?
					check_query = UserPost.none
				else

					if self.respond_to?( :content_hash )

						check_query = UserPost.where( parent_obj_id: self.parent_obj_id, parent_obj_type: self.parent_obj.class.name, user_id: self.user_id, content_hash: self.compute_content_hash ).within_last( 1.minute )

					else

						check_query = UserPost.where( parent_obj_id: self.parent_obj_id, parent_obj_type: self.parent_obj.class.name, user_id: self.user_id, content: self.content ).within_last( 1.minute )

					end

				end

				if check_query.present?
					self.errors.add :content, "Duplicate"
					return false
				end
			end

			def slugger
				self.subject.blank? ? self.id : self.subject
			end

	end

end