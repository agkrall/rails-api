class CreateSession
  attr_reader :user
  attr_reader :id_token

  def initialize(username, password)
    @username = username
    @password = password
  end

  def run
    if @user = User.find_by_username_and_password(@username, @password)
      @id_token = JWT.encode({ id: @user.id, username: @user.username }, Rails.configuration.jwt_key)
    else
      false
    end
  end
end
