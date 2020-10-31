module LoginSupport
	def sign_in_as(user)
		visit login_path
		fill_in 'email', with: user.email
		fill_in 'password', with: 'password'
		click_button 'Login'
	end
end

RSpec.configure do |config|
	config.include LoginSupport
end
