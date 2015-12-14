package Rex::Ossec::Base; 
use Rex -base;
use Rex::Ext::ParamLookup;

# Usage: rex setup server=192.1.2.3
# Usage: rex remove

# Changed this deployment to use agent-auth


desc 'Set up ossec agent';
task 'setup', sub { 

	my $server = param_lookup "server";

	unless ($server) {
		say "No server defined. Define server=10.10.10.10";
		exit 1;
	};

	

	unless ( is_installed("ossec-hids-agent") ) {

		# repository "add" => "ossec",
			# url      => "http://ossec.wazuh.com/repos/apt/debian",
			# key_url  => "http://ossec.wazuh.com/repos/apt/conf/ossec-key.gpg.key",
			# distro    => "jessie",
			# repository => "main",
			# source    => 0;

		# delete_lines_matching "/etc/apt/sources.list.d/ossec.list" => "deb-src";

		# update_package_db; <--- removed, cos it's not there currently. 

		pkg "ossec-hids-agent",
			ensure    => "installed",
			on_change => sub { say "package was installed/updated"; };

		run qq!dpkg -i /var/cache/apt/archives/ossec-hids-agent_2.8.3-3jessie_amd64.deb!;
		run qq!/var/ossec/bin/agent-auth -m ${server} -A $(hostname -f)!;

		service ossec => "restart";
 	};

	service ossec => ensure => "started";
};

desc 'Remove ossec agent';
task 'clean', sub {

	if ( is_installed("ossec-hids-agent") ) {
		service ossec => "stopped";
		remove package => "ossec-hids-agent";
		repository remove => "ossec";
	};


}
