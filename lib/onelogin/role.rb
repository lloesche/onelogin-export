module OneLogin
  class Role
    attr_accessor :id,
                  :name

    def self.from_xml(role_xml, role = self.new)
      role.id = REXML::XPath.first(role_xml, "//id").text.to_i
      role.name = REXML::XPath.first(role_xml, "//name").text

      role
    end
  end
end
