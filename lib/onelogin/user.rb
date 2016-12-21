module OneLogin
  class User
    attr_accessor :email,
                  :firstname,
                  :lastname,
                  :id,
                  :status,
                  :status_text,
                  :username,
                  :sshpubkey,
                  :shell,
                  :uidgid,
                  :apachereviewboardname,
                  :githubname,
                  :roles,
                  :fully_populated

    def initialize()
      @fully_populated = false
    end

    def populated?
      @fully_populated
    end

    def populated(onelogin, user = User.new)
      response = nil

      onelogin.logger.debug "trying to fully populate user"
      if @id && @id.is_a?(Numeric) && @id > 0
        onelogin.logger.debug "looking up user by id #{@id}"
        response = REXML::Document.new( onelogin.api_request({ service: "users/#{@id}.xml" }) )
      elsif @username && @username.is_a?(String)
        onelogin.logger.debug "looking up user by username #{@username}"
        response = REXML::Document.new( onelogin.api_request({ service: "users/username/#{@username}" }) )
      else
        raise "id is not numeric - can't populate user"
      end

      User.from_xml(response, user)
      user.fully_populated = true
      return user
    end

    def populate!(onelogin)
      populated(onelogin, self) if ! populated?
    end

    def self.from_xml(user_xml, user = self.new)
      user.status = REXML::XPath.first(user_xml, "//status").text.to_i
      user.status_text = case user.status
      when 0 then :unactivated
      when 1 then :active
      when 2 then :suspended
      when 3 then :locked
      when 4 then :password_expired
      when 5 then :awaiting_password_reset
      else :unknown
      end

      user.id = REXML::XPath.first(user_xml, "//id").text.to_i
      user.username = REXML::XPath.first(user_xml, "//username").text
      user.firstname = REXML::XPath.first(user_xml, "//firstname").text
      user.lastname = REXML::XPath.first(user_xml, "//lastname").text
      user.email = REXML::XPath.first(user_xml, "//email").text
      user.sshpubkey = REXML::XPath.first(user_xml, "//custom_attribute_sshpubkey").text
      user.shell = REXML::XPath.first(user_xml, "//custom_attribute_shell").text
      user.uidgid = REXML::XPath.first(user_xml, "//custom_attribute_uidgid").text
      user.uidgid = user.uidgid.to_i if ! user.uidgid.nil?
      user.apachereviewboardname = REXML::XPath.first(user_xml, "//custom_attribute_apachereviewboardname").text
      user.githubname = REXML::XPath.first(user_xml, "//custom_attribute_githubname").text

      user.roles = Array.new
      XPath.each(user_xml, "//user/roles/role" ) do |role_xml|
        role_xml = REXML::Document.new(role_xml.to_s)
        user.roles.push Role.from_xml(role_xml)
      end

      user
    end
  end
end