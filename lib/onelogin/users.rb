module OneLogin
  class Users
    include Enumerable

    attr_reader :collection

    def initialize(users = Array.new)
      @collection = users
    end

    def self.all(onelogin)
      users = Array.new
      onelogin.logger.info "fetching users"
      response = REXML::Document.new( onelogin.api_request({ service: 'users.xml' }) )

      XPath.each(response, "//users/user" ) do |user_xml|
        user_xml = REXML::Document.new(user_xml.to_s)
        users << User.from_xml(user_xml)
      end

      Users.new(users)
    end
   
    def with_role(role)
      self.select { |u| u.roles.any? { |r| r.name == role } }
    end

    def each(&block)
      @collection.each(&block)
    end

    def length
      @collection.length
    end

    def populate!(onelogin)
      each do |user|
        if ! user.populated?
          onelogin.logger.debug "populating user #{user.username}"
          user.populate!(onelogin)
        else
          onelogin.logger.debug "user #{user.username} is already populated"
        end
      end
    end
  end
end