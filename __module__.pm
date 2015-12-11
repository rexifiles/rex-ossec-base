package Rex::Ossec::Base; 
use Rex -base;
use Rex::Ext::ParamLookup;

# Usage: rex setup server=192.1.2.3 key=MDAxITBSI4IRFLVJDIhhcmxvcy5tZSAxOTIuMTY4LjEwLjIssdsd32ddcckyMjhmNWNjZjAzMWIzMzFmMjUzZDcyMzY2MTY3NDEyNWU2NzlmNmI2N2VmNTBhY2E4MDAxZDIxMw==
# Usage: rex remove

# The key should be taken from the client.keys file upon deployment. (not the exported key via the manager)


desc 'Set up ossec agent';
task 'setup', sub { 

	my $server = param_lookup "server";
	my $key    = param_lookup "key";

	unless ($key) {
	 	say "No key defined. Define key=KEYKEYKEYKEYKEYKEYKEYKEYKEY";
		exit 1;
	};

	unless ($server) {
		say "No server defined. Define server=10.10.10.10";
		exit 1;
	};

	unless ( is_installed("ossec-hids-agent") ) {

		repository "add" => "ossec",
			url      => "http://ossec.wazuh.com/repos/apt/debian",
			key_url  => "http://ossec.wazuh.com/repos/apt/conf/ossec-key.gpg.key",
			distro    => "jessie",
			repository => "main",
			source    => 1;

		delete_lines_matching "/etc/apt/sources.list.d/ossec.list" => "deb-src";

		update_package_db;

		run qq!echo ossec-hids-agent ossec-hids-agent/ip-server string ${server} | debconf-set-selections!;

		# set_pkgconf("ossec-hids-agent", [
			# { question => 'ossec-hids-agent/server-ip', type => 'string', value => "${server}" },
 		# ]);
		
		pkg "ossec-hids-agent",
			ensure    => "latest",
			on_change => sub { say "package was installed/updated"; };

		run qq!/var/ossec/bin/manage_agents -i ${key}!;

		# file "/var/ossec/etc/client.keys",
			# content      => template("files/var/ossec/etc/clientkeys.tpl", conf => { key => "$key" });
		service ossec => "restart";
		
 	};

	service ossec => ensure => "started";
};

desc 'Remove ossec agent';
task 'remove', sub {

	pkg "ossec-hids-agent",
		ensure => "absent";

}
