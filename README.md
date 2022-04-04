# node_exporter

Start and configure a node_exporter instance.
The module use the [node_exporter official docker image](https://github.com/prometheus/node_exporter).

This is a rootfull module. A node should run only one node_exporter instance.

## Install

Instantiate the module, example:
```
add-module ghcr.io/nethserver/node_exporter:latest 1
```

The output of the command will return the instance name.
Output example:
```
{"module_id": "node_exporter1", "image_name": "node_exporter", "image_url": "ghcr.io/nethserver/node_exporter:latest"}
```

## Configure

The node_exporter will be automatically configured after the install.
To protect the access, the endpoint is a random URL.
The endpoint could be retrieved using:
```
source /var/lib/nethserver/node_exporter1/state/environment
echo ${NODE_EXPORTER_PATH}
```

To check if the exporter is up&running use:
```
source /var/lib/nethserver/node_exporter1/state/environment
curl -lv http://localhost/${NODE_EXPORTER_PATH}
```


## Uninstall

To uninstall the instance:
```
remove-module --no-preserve node_exporter1
```
