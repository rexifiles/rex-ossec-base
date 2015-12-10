# rex-ossec-base

## setup()
Will add the collectd package to the designated server(s)



```
task "setup", make {

  Rex::Collectd::Base::setup(server="SERVERIP", key="CLIENT KEY");

};
```

# ossec
You will need to set up the server, and define a network range (unless you're gonna apply this with independant keys).
