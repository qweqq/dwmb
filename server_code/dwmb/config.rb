module Dwmb
    module Config
        Static = File.expand_path(File.join(File.dirname(__FILE__), '../static'))
        Database = "sqlite://#{File.dirname(__FILE__)}/database.db"
        Key = "6x9=42"
    end
end
