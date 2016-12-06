
module SwellSocial

	class CommentPolicy < ApplicationPolicy

		def admin_update?
			user.admin? || user == record.user
		end

	end

end
