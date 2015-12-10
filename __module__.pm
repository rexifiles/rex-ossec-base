package Rex::Ossec::Base; 
use Rex -base;
use Rex::Ext::ParamLookup;

# Usage: rex setup server=192.1.2.3 key=MDAxIHJ0bTIud2ViLnhhcmxvcy5tZSAxOTIuMTY4LjEwLjIgZTAzZjJkNTkyMjhmNWNjZjAzMWIzMzFmMjUzZDcyMzY2MTY3NDEyNWU2NzlmNmI2N2VmNTBhY2E4MDAxZDIxMw==
# Usage: rex remove

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
			distro    => "wheezy",
			repository => "main",
			source    => 1;

		delete_lines_matching "/etc/apt/sources.list.d/ossec.list" => "deb-src";

		update_package_db;

		pkg "ossec-hids-agent",
			ensure    => "latest",
			on_change => sub { say "package was installed/updated"; };

		run qq!debconf ossec-hids-agent/server-ip string ${server}!;

		# set_pkgconf("ossec-hids-agent", [
			# { question => 'ossec-hids-agent/server-ip', type => 'string', value => "${server}" },
 		# ]);
		
		file "/var/ossec/etc/client.keys",
			content      => template("files/var/ossec/etc/clientkeys.tpl", conf => { key => "$key" }),
			no_overwrite => TRUE;

		service ossec => "restart";
		
 	};

	service ossec => ensure => "started";
};

desc 'Remove ossec agent';
task 'remove', sub {

	pkg "ossec-hids-agent",
		ensure => "absent";

}
