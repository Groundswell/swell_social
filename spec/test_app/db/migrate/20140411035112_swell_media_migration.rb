class SwellSocialMigration < ActiveRecord::Migration
	def change

		enable_extension 'hstore'

		create_table :categories, force: true do |t|
			t.references		:user 			# created_by
			t.references 		:parent
			t.string			:name
			t.string			:label
			t.string 			:type
			t.integer 			:lft
			t.integer 			:rgt
			t.string			:users_name,					default: :players
			t.text				:description
			t.string			:status,						default: :active
			t.string			:availability,					default: :public
			t.integer 			:seq
			t.string 			:slug
			t.hstore			:properties
			t.timestamps
		end
		add_index :categories, :user_id
		add_index :categories, :parent_id
		add_index :categories, :type
		add_index :categories, :lft
		add_index :categories, :rgt
		add_index :categories, :slug, unique: true

		create_table :media do |t|
			t.references	:user 					# User who added it
			t.references	:managed_by 			# User acct that has origin acct (e.g. youtube) rights
			t.string		:public_id				# public id to spoof sequential id grepping
			t.references 	:category

			t.references	:parent_obj, 	polymorphic: true # for comments
			t.references	:parent 				# for nested_set (podcasts + episodes, conversations, etc.)
			t.integer		:lft
			t.integer		:rgt

			t.string		:type 					# video, product, page, article, etc...
			t.string		:sub_type				# video, tv, dvd

			t.string		:title
			t.string		:subtitle
			t.string		:avatar
			t.string		:avatar_caption
			t.text			:description
			t.text			:content
			t.string		:slug

			t.integer		:reward_threshold,				default: 100  # if product needs this many kudos to be offered as a reward

			t.boolean 		:is_commentable, 				default: true
			t.boolean		:is_sticky,						default: false 		# for forum topics
			t.boolean		:show_title,					default: true
			t.datetime		:modified_at 								# because updated_at is inadequate when caching stats, etc.
			t.text			:keywords, 	array: true, 		default: []

			t.string		:duration
			t.integer		:price

			t.integer 		:cached_impression_count, 		default: 0, 	limit: 8

			t.integer 		:cached_comment_count, 			default: 0, 	limit: 8

			t.integer		:cached_vote_count,				default: 0, 	limit: 8
			t.float			:cached_vote_score,				default: 0
			t.integer		:cached_upvote_count,			default: 0, 	limit: 8
			t.integer		:cached_downvote_count,			default: 0, 	limit: 8

			t.float			:score,							default: 0
			t.float			:previous_score,				default: 0
			t.float 		:decayed_score,					default: 0
			t.datetime		:score_updated_at

			t.string		:status, 						default: :active
			t.string		:availability, 					default: :public 	# hidden, friends, peers,
			t.datetime		:publish_at
			t.hstore		:properties

			t.timestamps
		end

		add_index :media, :user_id
		add_index :media, :managed_by_id
		add_index :media, :public_id
		add_index :media, :category_id
		add_index :media, :slug, unique: true
		add_index :media, [ :slug, :type ]
		add_index :media, [ :status, :availability ]



		# to store thumbnail data....
		create_table :media_thumbnails do |t|
			t.references 	:media
			t.string		:name
			t.string		:url
			t.integer		:height
			t.integer		:width
			t.string		:caption
			t.string		:status, 							default: :active
			t.timestamps
		end
		add_index :media_thumbnails, :media_id


		create_table :tags do |t|
			t.string :name
		end
		add_index :tags, :name, unique: true


		create_table :taggings do |t|
			t.references 		:tag
			t.references 		:taggable, 		polymorphic: true
			t.references 		:tagger, 		polymorphic: true
			t.string 			:context, 		limit: 128
			t.datetime 			:created_at
		end
		add_index :taggings, [ :tag_id, :taggable_id, :taggable_type, :context, :tagger_id, :tagger_type ],
			unique: true, name: 'taggings_idx'

	end
end