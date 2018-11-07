HostConfigSampleData = <<-JSON
{
  "Binds": [
    "/tmp:/tmp"
  ],
  "Links": [
    "redis3:redis"
  ],
  "Memory": 0,
  "MemorySwap": 0,
  "MemoryReservation": 0,
  "KernelMemory": 0,
  "NanoCPUs": 500000,
  "CpuPercent": 80,
  "CpuShares": 512,
  "CpuPeriod": 100000,
  "CpuRealtimePeriod": 1000000,
  "CpuRealtimeRuntime": 10000,
  "CpuQuota": 50000,
  "CpusetCpus": "0,1",
  "CpusetMems": "0,1",
  "MaximumIOps": 0,
  "MaximumIOBps": 0,
  "BlkioWeight": 300,
  "BlkioWeightDevice": [
    {}
  ],
  "BlkioDeviceReadBps": [
    {"Path": "device_path", "Rate": 9001}
  ],
  "BlkioDeviceReadIOps": [
    {"Path": "device_path", "Rate": 9001}
  ],
  "BlkioDeviceWriteBps": [
    {"Path": "device_path", "Rate": 9001}
  ],
  "BlkioDeviceWriteIOps": [
    {"Path": "device_path", "Rate": 9001}
  ],
  "MemorySwappiness": 60,
  "OomKillDisable": false,
  "OomScoreAdj": 500,
  "PidMode": "",
  "PidsLimit": -1,
  "PortBindings": {
    "22/tcp": [
      {
        "HostPort": "11022"
      }
    ]
  },
  "PublishAllPorts": false,
  "Privileged": false,
  "ReadonlyRootfs": false,
  "Dns": [
    "8.8.8.8"
  ],
  "DnsOptions": [
    ""
  ],
  "DnsSearch": [
    ""
  ],
  "VolumesFrom": [
    "parent",
    "other:ro"
  ],
  "CapAdd": [
    "NET_ADMIN"
  ],
  "CapDrop": [
    "MKNOD"
  ],
  "GroupAdd": [
    "newgroup"
  ],
  "RestartPolicy": {
    "Name": "",
    "MaximumRetryCount": 0
  },
  "AutoRemove": true,
  "NetworkMode": "bridge",
  "Devices": [],
  "Ulimits": [
    {"Name": "nofile", "Soft": 1024, "Hard": 2048}
  ],
  "LogConfig": {
    "Type": "json-file",
    "Config": {}
  },
  "SecurityOpt": [],
  "StorageOpt": {},
  "CgroupParent": "",
  "VolumeDriver": "",
  "ShmSize": 67108864
}
JSON

CreateContainerSampleData = <<-JSON
{
  "Hostname": "",
  "Domainname": "",
  "User": "",
  "AttachStdin": false,
  "AttachStdout": true,
  "AttachStderr": true,
  "Tty": false,
  "OpenStdin": false,
  "StdinOnce": false,
  "Env": [
    "FOO=bar",
    "BAZ=quux"
  ],
  "Cmd": [
    "date"
  ],
  "Entrypoint": "",
  "Image": "some:image",
  "Labels": {
    "com.example.vendor": "Acme",
    "com.example.license": "GPL",
    "com.example.version": "1.0"
  },
  "Volumes": {
    "/volumes/data": {}
  },
  "WorkingDir": "",
  "NetworkDisabled": false,
  "MacAddress": "12:34:56:78:9a:bc",
  "ExposedPorts": {
    "22/tcp": {}
  },
  "StopSignal": "SIGTERM",
  "StopTimeout": 10,
  "HostConfig": {
    "Binds": [
      "/tmp:/tmp"
    ],
    "Links": [
      "redis3:redis"
    ],
    "Memory": 0,
    "MemorySwap": 0,
    "MemoryReservation": 0,
    "KernelMemory": 0,
    "NanoCPUs": 500000,
    "CpuPercent": 80,
    "CpuShares": 512,
    "CpuPeriod": 100000,
    "CpuRealtimePeriod": 1000000,
    "CpuRealtimeRuntime": 10000,
    "CpuQuota": 50000,
    "CpusetCpus": "0,1",
    "CpusetMems": "0,1",
    "MaximumIOps": 0,
    "MaximumIOBps": 0,
    "BlkioWeight": 300,
    "BlkioWeightDevice": [
      {}
    ],
    "BlkioDeviceReadBps": [
      {}
    ],
    "BlkioDeviceReadIOps": [
      {}
    ],
    "BlkioDeviceWriteBps": [
      {}
    ],
    "BlkioDeviceWriteIOps": [
      {}
    ],
    "MemorySwappiness": 60,
    "OomKillDisable": false,
    "OomScoreAdj": 500,
    "PidMode": "",
    "PidsLimit": -1,
    "PortBindings": {
      "22/tcp": [
        {
          "HostPort": "11022"
        }
      ]
    },
    "PublishAllPorts": false,
    "Privileged": false,
    "ReadonlyRootfs": false,
    "Dns": [
      "8.8.8.8"
    ],
    "DnsOptions": [
      ""
    ],
    "DnsSearch": [
      ""
    ],
    "VolumesFrom": [
      "parent",
      "other:ro"
    ],
    "CapAdd": [
      "NET_ADMIN"
    ],
    "CapDrop": [
      "MKNOD"
    ],
    "GroupAdd": [
      "newgroup"
    ],
    "RestartPolicy": {
      "Name": "",
      "MaximumRetryCount": 0
    },
    "AutoRemove": true,
    "NetworkMode": "bridge",
    "Devices": [],
    "Ulimits": [
      {}
    ],
    "LogConfig": {
      "Type": "json-file",
      "Config": {}
    },
    "SecurityOpt": [],
    "StorageOpt": {},
    "CgroupParent": "",
    "VolumeDriver": "",
    "ShmSize": 67108864
  },
  "NetworkingConfig": {
    "EndpointsConfig": {
      "isolated_nw": {
        "IPAMConfig": {
          "IPv4Address": "172.20.30.33",
          "IPv6Address": "2001:db8:abcd::3033",
          "LinkLocalIPs": [
            "169.254.34.68",
            "fe80::3468"
          ]
        },
        "Links": [
          "container_1",
          "container_2"
        ],
        "Aliases": [
          "server_x",
          "server_y"
        ]
      }
    }
  }
}
JSON

ListResponseSample = <<-JSON
{

    "Id": "8dfafdbc3a40",
    "Names":

[

    "/boring_feynman"

],
"Image": "ubuntu:latest",
"ImageID": "d74508fb6632491cea586a1fd7d748dfc5274cd6fdfedee309ecdcbc2bf5cb82",
"Command": "echo 1",
"Created": 1367854155,
"State": "Exited",
"Status": "Exit 0",
"Ports":

[

    {
        "PrivatePort": 2222,
        "PublicPort": 3333,
        "Type": "tcp"
    }

],
"Labels":

{

    "com.example.vendor": "Acme",
    "com.example.license": "GPL",
    "com.example.version": "1.0"

},
"SizeRw": 12288,
"SizeRootFs": 0,
"HostConfig":

{

    "NetworkMode": "default"

},
"NetworkSettings":

{

    "Networks":

{

    "bridge":

        {
            "NetworkID": "7ea29fc1412292a2d7bba362f9253545fecdfa8ce9a6e37dd10ba8bee7129812",
            "EndpointID": "2cdc4edb1ded3631c81f57966563e5c8525b81121bb3706a9a9a3ae102711f3f",
            "Gateway": "172.17.0.1",
            "IPAddress": "172.17.0.2",
            "IPPrefixLen": 16,
            "IPv6Gateway": "",
            "GlobalIPv6Address": "",
            "GlobalIPv6PrefixLen": 0,
            "MacAddress": "02:42:ac:11:00:02"
        }
    }

},
"Mounts":

[

        {
            "Name": "fac362...80535",
            "Source": "/data",
            "Destination": "/data",
            "Driver": "local",
            "Mode": "ro,Z",
            "RW": false,
            "Propagation": ""
        }
    ]

}
JSON
