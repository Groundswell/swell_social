class SwellSocialMigration < ActiveRecord::Migration[5.1]
	# For R5

	def change

		enable_extension 'hstore'

		
		create_table :messages do |t|
			t.references	:user
			t.references	:sender
			t.string		:title
			t.text			:content
			t.integer		:status,		default: 1 # unread, read, archived, trash
			t.timestamps
		end
		add_index :messages, :sender_id
		add_index :messages, [ :user_id, :status ]

		create_table :notifications do |t|
			t.references	:user 
			t.references	:actor
			t.references 	:parent_obj, polymorphic: true  # to help de-dup
			t.references 	:activity_obj, polymorphic: true
			t.string			:title
			t.text				:content
			t.integer			:status,		default: 1 # hidden, unread, read, archived, trash,
			t.integer 		:parent_id, :null => true, :index => true
			t.integer 		:lft, :null => false, :index => true
			t.integer 		:rgt, :null => false, :index => true
			t.integer 		:children_count, :null => false, :default => 0
			t.string 			:action, default: nil
			t.datetime		:publish_at
			t.timestamps
		end
		add_index :notifications, [ :user_id, :created_at, :status ]
		add_index :notifications, [ :user_id, :parent_obj_id, :parent_obj_type ], name: 'idx_notifications_on_parent'
		add_index :notifications, [:action, :children_count, :status, :created_at], name: 'idx_notifications_action_count_status'
		add_index :notifications, [:user_id, :action, :children_count, :status, :created_at], name: 'idx_notifications_user_action_count_status'
		add_index :notifications, [:action, :children_count, :status, :parent_obj_type, :created_at, :parent_obj_id], name: 'idx_notifications_action_count_status_parent_obj'
		add_index :notifications, [:user_id, :action, :children_count, :status, :parent_obj_type, :created_at, :parent_obj_id], name: 'idx_notifications_user_action_count_status_parent_obj'
		add_index :notifications, [:activity_obj_id, :activity_obj_type, :user_id, :parent_obj_id, :parent_obj_type], name: 'idx_notifications_on_activity'


		create_table :object_subscriptions do |t|
			t.references		:user
			t.references		:parent_obj, 			polymorphic: true
			t.references		:category
			t.string			:format,				default: 'site' 	# email
			t.text 				:notification_contexts, array: true, default: []
			t.integer			:status, 				default: 1
			t.integer			:availability, 			default: 1 	# just_me, anyone for add-to-profile
			t.hstore			:properties
			t.timestamps
		end
		add_index :object_subscriptions, :user_id
		add_index :object_subscriptions, [ :parent_obj_id, :parent_obj_type ]
		

		# base for comments
		create_table :user_posts do |t|
			t.references		:user
			t.references		:parent_obj,			polymorphic: true
			t.references		:reply_to 				# for nested_set
			t.integer			:lft
			t.integer			:rgt
			t.string			:type
			t.string 			:slug
			
			t.string			:subject
			t.string			:slug
			t.text				:content

			t.integer			:cached_vote_count,				default: 0, 	limit: 8
			t.float				:cached_vote_score,				default: 0, 	limit: 8
			t.integer			:cached_upvote_count,			default: 0, 	limit: 8
			t.integer			:cached_downvote_count,			default: 0, 	limit: 8
			t.integer			:cached_subscribe_count, 		default: 0

			t.integer			:cached_impression_count, 		default: 0

			t.float				:computed_score,				default: 0
			t.integer			:status, 						default: 1
			t.integer			:availability, 					default: 1 	# anyone, logged_in, just_me
			t.datetime 			:modified_at
			t.hstore			:properties
			t.string 			:tags, array: true, default: '{}'
			t.string 			:mentions, array: true, default: '{}'
			t.timestamps
		end
		add_index :user_posts, :user_id
		add_index :user_posts, [ :parent_obj_id, :parent_obj_type ]
		add_index :user_posts, :reply_to_id
		add_index :user_posts, :slug, unique: true
		add_index :user_posts, :tags, using: 'gin'
		add_index :user_posts, [:created_at, :mentions]
		add_index :user_posts, [:updated_at, :mentions]
		add_index :user_posts, :mentions, using: 'gin'


		create_table :votes do |t|
			t.references 		:parent_obj, polymorphic: true
			t.references 		:user
			t.references 		:site
			t.integer 			:val, 			default: 0  # enum -1 down, 1 up
			t.string 			:context,		default: 'vote'
			t.text 				:content # in case of comment
			t.hstore			:properties
			t.timestamps
		end
		add_index :votes, :user_id
		add_index :votes, [ :parent_obj_id, :parent_obj_type ]
		add_index :votes, [ :parent_obj_id, :parent_obj_type, :context ]
		add_index :votes, [ :user_id, :context ]


	end
end