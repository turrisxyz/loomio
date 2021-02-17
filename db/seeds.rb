BlacklistedPassword.delete_all
passwords = File.readlines(Rails.root.join("db", "password_blacklist.txt")).map(&:chomp)
BlacklistedPassword.import(passwords.map {|p| BlacklistedPassword.new(string: p) })

PollTemplate.delete_all
PollTemplateService.seed_database!
