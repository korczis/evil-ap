# encoding: UTF-8
#
# Copyright (c) 2016 Tomas Korcak <korczis@gmail.com>. All rights reserved.
# This source code is licensed under the MIT-style license found in the
# LICENSE file in the root directory of this source tree.

require 'fileutils'
require 'highline'
require 'yaml'

module Zlown
  class Core
    def self.install(args = [], opts = {})
      cmd = 'apt-get install -y hostapd dnsmasq wireless-tools iw wvdial'
      puts cmd
      system cmd
    end

    def self.init_dirs(args = [], opts = {})
      unless File.directory?(Zlown::Config::APP_DIR)
        puts "Creating directory #{Zlown::Config::APP_DIR}"
        FileUtils.mkdir_p(Zlown::Config::APP_DIR)
      end

      unless File.directory?(Zlown::Config::DATA_DIR)
        puts "Creating directory #{Zlown::Config::DATA_DIR}"
        FileUtils.mkdir_p(Zlown::Config::DATA_DIR)
      end

      unless File.directory?(Zlown::Config::RUN_DIR)
        puts "Creating directory #{Zlown::Config::RUN_DIR}"
        FileUtils.mkdir_p(Zlown::Config::RUN_DIR)
      end
    end

    def self.init_service_template(args = [], opts = {})
      template = File.read(Zlown::Config::SERVICE_TEMPLATE)
      content = template.gsub('#{RUN_CMD}', Zlown::Config::RUN_CMD)

      # To write changes to the file, use:
      File.open(Zlown::Config::SERVICE_FILE, 'w') do |file|
        puts "Writting file #{Zlown::Config::SERVICE_FILE}"
        file.puts content
      end
    end

    def self.init_config_file(args = [], opts = {})
      config = {}
      if File.exist?(Zlown::Config::CONFIG_FILE)
        config = YAML.load(File.open(Zlown::Config::CONFIG_FILE))
      end

      cli = HighLine.new
      config[:upstream] = cli.ask('upstream interface?') { |q| q.default = config[:upstream] || 'eth0' }
      config[:ap] = cli.ask('wifi ap interface?') { |q| q.default = config[:ap] || 'wlan0pa' }

      puts "Writting config to #{Zlown::Config::CONFIG_FILE}"
      File.open(Zlown::Config::CONFIG_FILE, 'w') do |f|
        f.write config.to_yaml
      end
    end

    def self.init_systemctl(args = [], opts = {})
      # TODO: Process dnsmasq.conf and hostapd.conf

      cmd = "systemctl enable #{Zlown::Config::HOSTAPD_SERVICE}"
      puts cmd
      system cmd

      cmd = "systemctl enable #{Zlown::Config::DNSMASQ_SERVICE}"
      puts cmd
      system cmd

      cmd = "systemctl start #{Zlown::Config::HOSTAPD_SERVICE}"
      puts cmd
      system cmd

      cmd = "systemctl start #{Zlown::Config::DNSMASQ_SERVICE}"
      puts cmd
      system cmd
    end

    def self.init_dnsmaq(args = [], opts = {})
      # TODO: Implement
    end

    def self.init_hostapd(args = [], opts = {})
      # See https://www.offensive-security.com/kali-linux/kali-linux-evil-wireless-access-point/
      cmd = "sed -i 's#^DAEMON_CONF=.*#DAEMON_CONF=/etc/hostapd/hostapd.conf#' /etc/init.d/hostapd"
      puts cmd
      system cmd
    end

    def self.init_rc_local(args = [], opts = {})
      # TODO: Implement
    end

    def self.init(args = [], opts = {})
      Core.init_dirs(args, opts)

      Core.init_service_template(args, opts)

      Core.init_config_file(args, opts)

      Core.init_dnsmaq(args, opts)

      Core.init_hostapd(args, opts)

      Core.init_rc_local(args, opts)

      Core.init_systemctl(args, opts)
    end
  end
end
