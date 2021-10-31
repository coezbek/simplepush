require_relative '../lib/simplepush'

def load_config
  if !File.exists?('config.yml')

    config = {}

    puts "Enter your key"
    config[:key] = gets[/.+/] # Strip newline and return nil if ""

    puts "Enter your password or leave empty to send unencrypted"
    config[:pass] = gets[/.+/]

    if config[:pass]
      puts "Enter the salt"
      config[:salt] = gets[/.+/]
    end

    puts "Configuration stored (as plaintext) in config.yml"
    File.write('config.yml', config.to_yaml)
  end

  YAML.load_file('config.yml')
end