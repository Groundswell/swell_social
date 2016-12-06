
module SwellSocial
	class ProductPolicy < ApplicationPolicy

		def admin_update?
			user.admin?
		end

	end
end
