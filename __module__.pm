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

		run qq!echo ossec-hids-agent ossec-hids-agent/ip-server string ${server} | debconf-set-selections!;
		run qq!dpkg -i /var/cache/apt/archives/ossec-hids-agent_2.8.3-3jessie_amd64.deb!;
		run qq!/var/ossec/bin/agent-auth -m $server -A `hostname -f`!;

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
