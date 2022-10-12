## Accessing Dictionary Keys in a Variable

<a href="https://ibb.co/pyKgFYW"><img src="https://i.ibb.co/Zmg3DqH/IMG-1963.jpg" alt="IMG-1963" border="0" /></a>

With Ansible you can retrieve or discover certain variables containing information about your remote systems or about Ansible itself. Variables related to remote systems are called facts. With facts, you can use the behavior or state of one system as configuration on other systems. For example, you can use the IP address of one system as a configuration value on another system. Variables related to Ansible are called magic variables.



If a variable contains a dictionary, you can access the keys of the dictionary by using either a dot (.) or a subscript ([]). 

```json
{{ login.stdout }}
```
We could have used subscript notation instead:

```json
{{ login['stdout'] }}
```

This rule applies to multiple dereferences, so all of the following are equivalent:

```json
ansible_eth1['ipv4']['address']
ansible_eth1['ipv4'].address
ansible_eth1.ipv4['address']
ansible_eth1.ipv4.address
```

I generally prefer dot notation, unless the key is a string that contains a character that’s not allowed as a variable name, such as a dot, space, or hyphen.

Ansible uses Jinja2 to implement variable dereferencing, so for more details on this
topic, see the [Jinja2 documentation](https://jinja.palletsprojects.com/en/latest/) on variables. 


### Navagating into the Memory Facts

To see all the facts, as we already know we can use the `setup` module, to filter the result we must use `filter=ansible.....`. Se explore a bit what we can see filtering by host memory, `filter=ansible_mem*` 


```yaml
[vagrant@node-centos-1 ansible]$ ansible -i inventory web -m setup -a "filter=ansible_mem*"

192.168.56.12 | SUCCESS => {
    "ansible_facts": {
        "ansible_memory_mb": {
            "nocache": {
                "free": 1709,
                "used": 268
            },
            "real": {
                "free": 1057,
                "total": 1977,
                "used": 920
            },
            "swap": {
                "cached": 0,
                "free": 2047,
                "total": 2047,
                "used": 0
            }
        },
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "changed": false
}
```

Creating a task to go into this and have an adjusted output:

```yaml
    - name: Debug facts
      debug:
        msg:
          - "IPV4: {{ ansible_eth1.ipv4.address }}"
          - "OS: {{ ansible_os_family }}"
          - "FREE MEMORY: {{ ansible_memfree_mb }}"
          - "MEMORY USED: {{ ansible_memory_mb.real.used }}"
          - "MEMORY SWAP FREE AND TOTAL: {{ ansible_memory_mb.swap.free }} | {{ ansible_memory_mb.swap.total }}"

```  

The result is how I show below:

```yaml
TASK [Debug facts] ***********************************************************************************************************************************************************************************
ok: [192.168.56.12] => {
    "msg": [
        "IPV4: 192.168.56.12",
        "OS: RedHat",
        "MEMORY: 1551",
        "MEMORY used: 182 "
    ]
}
```

Then we can read each value individualy or read them with the `with_dic`, and filter the value as we want, look:

```yaml
    - name: with_dict
      debug:
        msg: "{{ item.key }}"
      with_dict: "{{ ansible_memory_mb }}"
```

Then the result looks like this: 

```yaml
TASK [with_dict] *************************************************************************************************************************************************************************************
ok: [192.168.56.12] => (item={'key': 'real', 'value': {'total': 1977, 'used': 338, 'free': 1639}}) => {
    "msg": "real"
}
ok: [192.168.56.12] => (item={'key': 'nocache', 'value': {'free': 1799, 'used': 178}}) => {
    "msg": "nocache"
}
ok: [192.168.56.12] => (item={'key': 'swap', 'value': {'total': 2047, 'free': 2047, 'used': 0, 'cached': 0}}) => {
    "msg": "swap"
}
```

Now lets filter to see only the real values:

```yaml
    - name: with_dict
      debug:
        msg: "{{ item.key }}={{ item.value }}"
      when: item.key == 'real'
      with_dict: "{{ ansible_memory_mb }}"
```

Then we see that the result is how we expected: 
```yaml

TASK [with_dict] *************************************************************************************************************************************************************************************
ok: [192.168.56.12] => (item={'key': 'real', 'value': {'total': 1977, 'used': 340, 'free': 1637}}) => {
    "msg": "real={'total': 1977, 'used': 340, 'free': 1637}"
}
skipping: [192.168.56.12] => (item={'key': 'nocache', 'value': {'free': 1798, 'used': 179}}) 
skipping: [192.168.56.12] => (item={'key': 'swap', 'value': {'total': 2047, 'free': 2047, 'used': 0, 'cached': 0}}) 

PLAY RECAP *******************************************************************************************************************************************************************************************
```

Now let's catch only one value, the total value of memory:

```yaml
    - name: with_dict
      debug:
        msg: "{{ item.key }}={{ item.value.total }}"
      when: item.key == 'real'
      with_dict: "{{ ansible_memory_mb }}"
```

The result again a bit more detailed, how expected:
```
TASK [with_dict] *************************************************************************************************************************************************************************************
ok: [192.168.56.12] => (item={'key': 'real', 'value': {'total': 1977, 'used': 344, 'free': 1633}}) => {
    "msg": "real=1977"
}
skipping: [192.168.56.12] => (item={'key': 'nocache', 'value': {'free': 1795, 'used': 182}}) 
skipping: [192.168.56.12] => (item={'key': 'swap', 'value': {'total': 2047, 'free': 2047, 'used': 0, 'cached': 0}}) 
```

### Navagating into the Network Facts

The output here will be a bit longer, due to this I'll suppress it, but you can click in `click to expand` to see the full output. 

We have important information about the network, including all the objects related to the interface, ip, netmask, broadcas address etc... 

Let's collect some info about our network interface. 


<details>
  <summary>Click to expand!</summary>
  
```yaml
[vagrant@node-centos-1 ansible]$ ansible -i inventory web  -m setup -a "filter=ansible_eth*"

192.168.56.12 | SUCCESS => {
    "ansible_facts": {
        "ansible_eth0": {
            "active": true,
            "device": "eth0",
            "features": {
                "esp_hw_offload": "off [fixed]",
                "esp_tx_csum_hw_offload": "off [fixed]",
                "fcoe_mtu": "off [fixed]",
                "generic_receive_offload": "on",
                "generic_segmentation_offload": "on",
                "highdma": "off [fixed]",
                "hw_tc_offload": "off [fixed]",
                "l2_fwd_offload": "off [fixed]",
                "large_receive_offload": "off [fixed]",
                "loopback": "off [fixed]",
                "netns_local": "off [fixed]",
                "ntuple_filters": "off [fixed]",
                "receive_hashing": "off [fixed]",
                "rx_all": "off",
                "rx_checksumming": "off",
                "rx_fcs": "off",
                "rx_gro_hw": "off [fixed]",
                "rx_gro_list": "off",
                "rx_udp_tunnel_port_offload": "off [fixed]",
                "rx_vlan_filter": "on [fixed]",
                "rx_vlan_offload": "on",
                "rx_vlan_stag_filter": "off [fixed]",
                "rx_vlan_stag_hw_parse": "off [fixed]",
                "scatter_gather": "on",
                "tcp_segmentation_offload": "on",
                "tls_hw_record": "off [fixed]",
                "tls_hw_rx_offload": "off [fixed]",
                "tls_hw_tx_offload": "off [fixed]",
                "tx_checksum_fcoe_crc": "off [fixed]",
                "tx_checksum_ip_generic": "on",
                "tx_checksum_ipv4": "off [fixed]",
                "tx_checksum_ipv6": "off [fixed]",
                "tx_checksum_sctp": "off [fixed]",
                "tx_checksumming": "on",
                "tx_esp_segmentation": "off [fixed]",
                "tx_fcoe_segmentation": "off [fixed]",
                "tx_gre_csum_segmentation": "off [fixed]",
                "tx_gre_segmentation": "off [fixed]",
                "tx_gso_list": "off [fixed]",
                "tx_gso_partial": "off [fixed]",
                "tx_gso_robust": "off [fixed]",
                "tx_ipxip4_segmentation": "off [fixed]",
                "tx_ipxip6_segmentation": "off [fixed]",
                "tx_lockless": "off [fixed]",
                "tx_nocache_copy": "off",
                "tx_scatter_gather": "on",
                "tx_scatter_gather_fraglist": "off [fixed]",
                "tx_sctp_segmentation": "off [fixed]",
                "tx_tcp6_segmentation": "off [fixed]",
                "tx_tcp_ecn_segmentation": "off [fixed]",
                "tx_tcp_mangleid_segmentation": "off",
                "tx_tcp_segmentation": "on",
                "tx_tunnel_remcsum_segmentation": "off [fixed]",
                "tx_udp_segmentation": "off [fixed]",
                "tx_udp_tnl_csum_segmentation": "off [fixed]",
                "tx_udp_tnl_segmentation": "off [fixed]",
                "tx_vlan_offload": "on [fixed]",
                "tx_vlan_stag_hw_insert": "off [fixed]",
                "vlan_challenged": "off [fixed]"
            },
            "hw_timestamp_filters": [],
            "ipv4": {
                "address": "10.0.2.15",
                "broadcast": "10.0.2.255",
                "netmask": "255.255.255.0",
                "network": "10.0.2.0"
            },
            "ipv6": [
                {
                    "address": "fe80::5054:ff:fe03:15fa",
                    "prefix": "64",
                    "scope": "link"
                }
            ],
            "macaddress": "52:54:00:03:15:fa",
            "module": "e1000",
            "mtu": 1500,
            "pciid": "0000:00:03.0",
            "promisc": false,
            "speed": 1000,
            "timestamping": [],
            "type": "ether"
        },
        "ansible_eth1": {
            "active": true,
            "device": "eth1",
            "features": {
                "esp_hw_offload": "off [fixed]",
                "esp_tx_csum_hw_offload": "off [fixed]",
                "fcoe_mtu": "off [fixed]",
                "generic_receive_offload": "on",
                "generic_segmentation_offload": "on",
                "highdma": "off [fixed]",
                "hw_tc_offload": "off [fixed]",
                "l2_fwd_offload": "off [fixed]",
                "large_receive_offload": "off [fixed]",
                "loopback": "off [fixed]",
                "netns_local": "off [fixed]",
                "ntuple_filters": "off [fixed]",
                "receive_hashing": "off [fixed]",
                "rx_all": "off",
                "rx_checksumming": "off",
                "rx_fcs": "off",
                "rx_gro_hw": "off [fixed]",
                "rx_gro_list": "off",
                "rx_udp_tunnel_port_offload": "off [fixed]",
                "rx_vlan_filter": "on [fixed]",
                "rx_vlan_offload": "on",
                "rx_vlan_stag_filter": "off [fixed]",
                "rx_vlan_stag_hw_parse": "off [fixed]",
                "scatter_gather": "on",
                "tcp_segmentation_offload": "on",
                "tls_hw_record": "off [fixed]",
                "tls_hw_rx_offload": "off [fixed]",
                "tls_hw_tx_offload": "off [fixed]",
                "tx_checksum_fcoe_crc": "off [fixed]",
                "tx_checksum_ip_generic": "on",
                "tx_checksum_ipv4": "off [fixed]",
                "tx_checksum_ipv6": "off [fixed]",
                "tx_checksum_sctp": "off [fixed]",
                "tx_checksumming": "on",
                "tx_esp_segmentation": "off [fixed]",
                "tx_fcoe_segmentation": "off [fixed]",
                "tx_gre_csum_segmentation": "off [fixed]",
                "tx_gre_segmentation": "off [fixed]",
                "tx_gso_list": "off [fixed]",
                "tx_gso_partial": "off [fixed]",
                "tx_gso_robust": "off [fixed]",
                "tx_ipxip4_segmentation": "off [fixed]",
                "tx_ipxip6_segmentation": "off [fixed]",
                "tx_lockless": "off [fixed]",
                "tx_nocache_copy": "off",
                "tx_scatter_gather": "on",
                "tx_scatter_gather_fraglist": "off [fixed]",
                "tx_sctp_segmentation": "off [fixed]",
                "tx_tcp6_segmentation": "off [fixed]",
                "tx_tcp_ecn_segmentation": "off [fixed]",
                "tx_tcp_mangleid_segmentation": "off",
                "tx_tcp_segmentation": "on",
                "tx_tunnel_remcsum_segmentation": "off [fixed]",
                "tx_udp_segmentation": "off [fixed]",
                "tx_udp_tnl_csum_segmentation": "off [fixed]",
                "tx_udp_tnl_segmentation": "off [fixed]",
                "tx_vlan_offload": "on [fixed]",
                "tx_vlan_stag_hw_insert": "off [fixed]",
                "vlan_challenged": "off [fixed]"
            },
            "hw_timestamp_filters": [],
            "ipv4": {
                "address": "192.168.56.12",
                "broadcast": "192.168.56.255",
                "netmask": "255.255.255.0",
                "network": "192.168.56.0"
            },
            "ipv6": [
                {
                    "address": "fe80::a00:27ff:feca:86a9",
                    "prefix": "64",
                    "scope": "link"
                }
            ],
            "macaddress": "08:00:27:ca:86:a9",
            "module": "e1000",
            "mtu": 1500,
            "pciid": "0000:00:08.0",
            "promisc": false,
            "speed": 1000,
            "timestamping": [],
            "type": "ether"
        },
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "changed": false
}
```

</details>



We can use thoses values to compare with some value we have from other source, if the value dosen't match we can show a message or run a task to do something, like setup some interface or other... 

Let's collect the IP address of some interface, can be `ansible_eth1`, ipv4 and ipv6.

```yaml
    - name: with_dict
      debug:
        msg: "{{ item.key }}"
      with_dict: "{{ ansible_eth1 }}"
```


```yaml
TASK [with_dict] *************************************************************************************************************************************************************************************
ok: [192.168.56.12] => (item={'key': 'device', 'value': 'eth1'}) => {
    "msg": "device"
}
ok: [192.168.56.12] => (item={'key': 'macaddress', 'value': '08:00:27:ca:86:a9'}) => {
    "msg": "macaddress"
}
ok: [192.168.56.12] => (item={'key': 'mtu', 'value': 1500}) => {
    "msg": "mtu"
}
ok: [192.168.56.12] => (item={'key': 'active', 'value': True}) => {
    "msg": "active"
}
ok: [192.168.56.12] => (item={'key': 'module', 'value': 'e1000'}) => {
    "msg": "module"
}
ok: [192.168.56.12] => (item={'key': 'type', 'value': 'ether'}) => {
    "msg": "type"
}
ok: [192.168.56.12] => (item={'key': 'pciid', 'value': '0000:00:08.0'}) => {
    "msg": "pciid"
}
ok: [192.168.56.12] => (item={'key': 'speed', 'value': 1000}) => {
    "msg": "speed"
}
ok: [192.168.56.12] => (item={'key': 'promisc', 'value': False}) => {
    "msg": "promisc"
}
ok: [192.168.56.12] => (item={'key': 'ipv4', 'value': {'address': '192.168.56.12', 'broadcast': '192.168.56.255', 'netmask': '255.255.255.0', 'network': '192.168.56.0'}}) => {
    "msg": "ipv4"
}
ok: [192.168.56.12] => (item={'key': 'ipv6', 'value': [{'address': 'fe80::a00:27ff:feca:86a9', 'prefix': '64', 'scope': 'link'}]}) => {
    "msg": "ipv6"
}
ok: [192.168.56.12] => (item={'key': 'features', 'value': {'rx_checksumming': 'off', 'tx_checksumming': 'on', 'tx_checksum_ipv4': 'off [fixed]', 'tx_checksum_ip_generic': 'on', 'tx_checksum_ipv6': 'off [fixed]', 'tx_checksum_fcoe_crc': 'off [fixed]', 'tx_checksum_sctp': 'off [fixed]', 'scatter_gather': 'on', 'tx_scatter_gather': 'on', 'tx_scatter_gather_fraglist': 'off [fixed]', 'tcp_segmentation_offload': 'on', 'tx_tcp_segmentation': 'on', 'tx_tcp_ecn_segmentation': 'off [fixed]', 'tx_tcp_mangleid_segmentation': 'off', 'tx_tcp6_segmentation': 'off [fixed]', 'generic_segmentation_offload': 'on', 'generic_receive_offload': 'on', 'large_receive_offload': 'off [fixed]', 'rx_vlan_offload': 'on', 'tx_vlan_offload': 'on [fixed]', 'ntuple_filters': 'off [fixed]', 'receive_hashing': 'off [fixed]', 'highdma': 'off [fixed]', 'rx_vlan_filter': 'on [fixed]', 'vlan_challenged': 'off [fixed]', 'tx_lockless': 'off [fixed]', 'netns_local': 'off [fixed]', 'tx_gso_robust': 'off [fixed]', 'tx_fcoe_segmentation': 'off [fixed]', 'tx_gre_segmentation': 'off [fixed]', 'tx_gre_csum_segmentation': 'off [fixed]', 'tx_ipxip4_segmentation': 'off [fixed]', 'tx_ipxip6_segmentation': 'off [fixed]', 'tx_udp_tnl_segmentation': 'off [fixed]', 'tx_udp_tnl_csum_segmentation': 'off [fixed]', 'tx_gso_partial': 'off [fixed]', 'tx_tunnel_remcsum_segmentation': 'off [fixed]', 'tx_sctp_segmentation': 'off [fixed]', 'tx_esp_segmentation': 'off [fixed]', 'tx_udp_segmentation': 'off [fixed]', 'tx_gso_list': 'off [fixed]', 'rx_gro_list': 'off', 'tls_hw_rx_offload': 'off [fixed]', 'fcoe_mtu': 'off [fixed]', 'tx_nocache_copy': 'off', 'loopback': 'off [fixed]', 'rx_fcs': 'off', 'rx_all': 'off', 'tx_vlan_stag_hw_insert': 'off [fixed]', 'rx_vlan_stag_hw_parse': 'off [fixed]', 'rx_vlan_stag_filter': 'off [fixed]', 'l2_fwd_offload': 'off [fixed]', 'hw_tc_offload': 'off [fixed]', 'esp_hw_offload': 'off [fixed]', 'esp_tx_csum_hw_offload': 'off [fixed]', 'rx_udp_tunnel_port_offload': 'off [fixed]', 'tls_hw_tx_offload': 'off [fixed]', 'rx_gro_hw': 'off [fixed]', 'tls_hw_record': 'off [fixed]'}}) => {
    "msg": "features"
}
ok: [192.168.56.12] => (item={'key': 'timestamping', 'value': []}) => {
    "msg": "timestamping"
}
ok: [192.168.56.12] => (item={'key': 'hw_timestamp_filters', 'value': []}) => {
    "msg": "hw_timestamp_filters"
}

```


```yaml
    - name: Debug ipv4
      debug:
        msg: "{{ ansible_eth1.ipv4.address }}"

    - name: with_dict
      debug:
        msg: "{{ item.key }}={{ item.value.address }}"
      when: item.key == 'ipv4'
      with_dict: "{{ ansible_eth1 }}"
```

The result should be: 

```yaml
TASK [Debug ipv4] ************************************************************************************************************************************************************************************
ok: [192.168.56.12] => {
    "msg": "192.168.56.12"
}

ok: [192.168.56.12] => (item={'key': 'ipv4', 'value': {'address': '192.168.56.12', 'broadcast': '192.168.56.255', 'netmask': '255.255.255.0', 'network': '192.168.56.0'}}) => {
    "msg": "ipv4=192.168.56.12"
}
```

### Navagating into the Disk and Mounts Facts

We can navegate into the disk facts easly using the same structure of commands. 

Here I want to collect the size of the sda1 partition, look that I'm using to different ways to have the same resutl :D: 

```yaml
    - name: Debug disk
      debug:
        msg: "{{ ansible_devices.sda.partitions.sda1.size }}"

    - name: with_dict
      debug:
        msg: "{{ item.value.partitions.sda1.size }}"
      with_dict: "{{ ansible_devices }}"
```


```yaml
[vagrant@node-centos-1 ansible]$ ansible -i inventory web  -m setup -a "filter=ansible_devices*"

192.168.56.12 | SUCCESS => {
    "ansible_facts": {
        "ansible_devices": {
            "sda": {
                "holders": [],
                "host": "IDE interface: Intel Corporation 82371AB/EB/MB PIIX4 IDE (rev 01)",
                "links": {
                    "ids": [
                        "ata-VBOX_HARDDISK_VB08f209a4-f1f280c5",
                        "scsi-0ATA_VBOX_HARDDISK_VB08f209a4-f1f280c5",
                        "scsi-1ATA_VBOX_HARDDISK_VB08f209a4-f1f280c5",
                        "scsi-SATA_VBOX_HARDDISK_VB08f209a4-f1f280c5"
                    ],
                    "labels": [],
                    "masters": [],
                    "uuids": []
                },
                "model": "VBOX HARDDISK",
                "partitions": {
                    "sda1": {
                        "holders": [],
                        "links": {
                            "ids": [
                                "ata-VBOX_HARDDISK_VB08f209a4-f1f280c5-part1",
                                "scsi-0ATA_VBOX_HARDDISK_VB08f209a4-f1f280c5-part1",
                                "scsi-1ATA_VBOX_HARDDISK_VB08f209a4-f1f280c5-part1",
                                "scsi-SATA_VBOX_HARDDISK_VB08f209a4-f1f280c5-part1"
                            ],
                            "labels": [],
                            "masters": [],
                            "uuids": [
                                "ea09066e-02dd-46ad-bac9-700172bc3bca"
                            ]
                        },
                        "sectors": "20969472",
                        "sectorsize": 512,
                        "size": "10.00 GB",
                        "start": "2048",
                        "uuid": "ea09066e-02dd-46ad-bac9-700172bc3bca"
                    }
                },
                "removable": "0",
                "rotational": "1",
                "sas_address": null,
                "sas_device_handle": null,
                "scheduler_mode": "mq-deadline",
                "sectors": "20971520",
                "sectorsize": "512",
                "size": "10.00 GB",
                "support_discard": "0",
                "vendor": "ATA",
                "virtual": 1
            }
        },
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "changed": false
}
```


Mounts: 


```yaml
[vagrant@node-centos-1 ansible]$ ansible -i inventory web  -m setup -a "filter=ansible_mounts*"
192.168.56.12 | SUCCESS => {
    "ansible_facts": {
        "ansible_mounts": [
            {
                "block_available": 1650465,
                "block_size": 4096,
                "block_total": 2618624,
                "block_used": 968159,
                "device": "/dev/sda1",
                "fstype": "xfs",
                "inode_available": 5198951,
                "inode_total": 5242368,
                "inode_used": 43417,
                "mount": "/",
                "options": "rw,seclabel,relatime,attr2,inode64,logbufs=8,logbsize=32k,noquota",
                "size_available": 6760304640,
                "size_total": 10725883904,
                "uuid": "ea09066e-02dd-46ad-bac9-700172bc3bca"
            }
        ],
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "changed": false
}
```


##### Documentation
- [Jinja2](https://jinja.palletsprojects.com/en/latest/)
- [Ansible Facts](https://docs.ansible.com/ansible/latest/user_guide/playbooks_vars_facts.html)

        