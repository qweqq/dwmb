module Dwmb
    module Config
        Static = File.expand_path(File.join(File.dirname(__FILE__), '../static'))
        Snapshot_folder = File.join(Static, "snapshots")
        Database = "sqlite://#{File.dirname(__FILE__)}/database.db"
        Key = "6x9=42"
        Mail_options = {
            :address              => 'smtp.gmail.com',
            :port                 => '587',
            :enable_starttls_auto => true,
            :user_name            => 'dwmb.mailer@gmail.com',
            :password             => 'dwmbpassword',
            :authentication       => :plain, # :plain, :login, :cram_md5, no auth by default
            :domain               => "localhost.localdomain" # the HELO domain provided by the client to the server
        }
    end
end
