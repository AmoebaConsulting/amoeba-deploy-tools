module AmoebaDeployTools
  class Ssl < Command
    # Needed for knife solo stuff
    include AmoebaDeployTools::Concerns::SSH

    desc 'import', 'Import an SSL certificate and add to encrypted data bag (encryption key `default` used unless specified)'
    option :privateKey, desc: 'Name of the private key to use. Will create if missing', default: 'default'
    option :key, desc: 'SSL private key file name / path', required: true
    option :cert, desc: 'SSL public certificate file name / path', required: true
    option :ca, desc: 'SSL intermediary CA certificate name / path'
    def import(cert_name=nil)
      logger.debug "Starting SSL import!"
      validate_chef_id!(cert_name)

      json_data = { id: cert_name }

      [:key, :cert, :ca].each do |c|
        # read certificates before we get in the kitchen
        if File.exist? options[c]
          json_data[c] = File.read(options[c])
        else
          logger.error "Cannot find certificate file to import (ignoring): #{options[c]}"
          options[c] = nil
        end
      end

      inside_kitchen do
        key_file = File.join('private_keys', "#{options[:privateKey]}.key")

        # Ensure key exists
        unless File.exist? key_file
          logger.warn "Private key missing: #{options[:privateKey]}, running `amoeba key create #{options[:privateKey]}`"
          AmoebaDeployTools::Key.new.create(options[:privateKey])
        end

        # Import to certs databag
        with_tmpfile( json_data.to_json, name: [cert_name, '.json'] ) do |file_name|
          knife_solo "data bag create certs #{cert_name}",
                     'json-file' => file_name,
                     'secret-file' => key_file
        end
      end
    end

  end
end