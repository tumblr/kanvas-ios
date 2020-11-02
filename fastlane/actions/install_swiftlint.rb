module Fastlane
  module Actions
    module SharedValues
      INSTALL_SWIFTLINT_PATH = :INSTALL_SWIFTLINT_PATH
    end

    class InstallSwiftlintAction < Action
      def self.run(params)

        swiftlint_path = "./vendor/swiftlint"
        swiftlint_bin = "#{swiftlint_path}/bin/swiftlint"

        version = params[:version] || ENV["FL_INSTALL_SWIFTLINT_VERSION"]

        # fastlane will take care of reading in the parameter and fetching the environment variable:
        UI.message "Installing SwiftLint #{version} into #{swiftlint_path}"

        Dir.mktmpdir do |tmpdir|
          # Try first using a binary release
          zipfile = "#{tmpdir}/swiftlint-#{version}.zip"
          sh "curl --fail --location -o #{zipfile} https://github.com/realm/SwiftLint/releases/download/#{version}/portable_swiftlint.zip || true"
          if File.exists?(zipfile)
            extracted_dir = "#{tmpdir}/swiftlint-#{version}"
            sh "unzip #{zipfile} -d #{extracted_dir}"
            FileUtils.mkdir_p("#{swiftlint_path}/bin")
            FileUtils.cp("#{extracted_dir}/swiftlint", "#{swiftlint_path}/bin/swiftlint")
          else
            sh "git clone --quiet https://github.com/realm/SwiftLint.git #{tmpdir}"
            Dir.chdir(tmpdir) do
              sh "git checkout --quiet #{version}"
              sh "git submodule --quiet update --init --recursive"
              FileUtils.remove_entry_secure(swiftlint_path) if Dir.exist?(swiftlint_path)
              FileUtils.mkdir_p(swiftlint_path)
              sh "make prefix_install PREFIX='#{swiftlint_path}'"
            end
          end
        end

        Actions.lane_context[SharedValues::INSTALL_SWIFTLINT_PATH] = swiftlint_bin
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Installs SwiftLint by downloading the portable_swiftlint release or compiling from source."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :version,
                                       env_name: "FL_INSTALL_SWIFTLINT_VERSION",
                                       description: "Version number for InstallSwiftlintAction", 
                                       verify_block: proc do |value|
                                          UI.user_error!("No version number for InstallSwiftlintAction given, pass using `version: 'version number'`") unless (value and not value.empty?)
                                       end)
        ]
      end

      def self.output
        [
          ['INSTALL_SWIFTLINT_PATH', 'The path to SwiftLint executable.']
        ]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.authors
        # So no one will ever forget your contribution to fastlane :) You are awesome btw!
        ["bjtitus"]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end
    end
  end
end
