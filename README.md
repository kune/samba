# Samba Version 4.14.6 with Time Machine capabilities
Based on centos:8

### Build

#### Build image: 
```bash
docker build . -t kune/samba:4.14.6-centos8
```

### Run

#### Sample environment: 
- /srv/samba/smb.conf: Samba Configuration
- /srv/samba/passwd: Passwd user file
- /srv/samba/private: Directory for samba databases
- /srv/backup/timemachine: Location for time machine backups
- /srv/other: Non-time machine share location

#### Samba Configuration: 
```
[Global]
    server role = standalone server
    client signing = auto
    vfs objects = catia fruit streams_xattr
    fruit:advertise_fullsync = true
    fruit:aapl = yes
    fruit:locking = none
    fruit:metadata = stream
    fruit:resource = file
    fruit:model = MacPro6,1
    fruit:copyfile = yes
    max log size = 1000
    use sendfile = yes
[Time Machine]
    comment = Time Machine
    path = /srv/backup/timemachine/%u
    browseable = no
    writeable = yes
    create mask = 0600
    directory mask = 0700
    spotlight = no
    fruit:time machine = yes
    fruit:time machine max size = 2T
    durable handles = yes
    kernel oplocks = no
    kernel share modes = no
    posix locking = no
    ea support = yes
    inherit acls = yes
    aio write behind = yes
[Other]
    path = /srv/other
    browseable = yes
    writeable = yes
    valid users = %U
```

Run container:
```bash
docker run \
  --restart=unless-stopped \
  -v /srv/Backups/backup:/srv/backup/timemachine \
  -v /srv/other:/srv/other \
  -v /srv/samba/smb.conf:/etc/samba/smb.conf \
  -v /srv/samba/private:/var/lib/samba/private \
  -v /srv/samba/passwd:/etc/passwd \
  -p137:137 -p138:138 -p139:139 -p445:445 -p5353:5353 \
  --name samba \
  -d \
  kune/samba
```

### Avahi
To make the shares discoverable for Macs and available for backups the avahi-daeon needs to be installed and configured: 

/etc/avahi/services/samba.service
```
<?xml version="1.0" standalone='no'?>
<!DOCTYPE service-group SYSTEM "avahi-service.dtd">
<service-group>
	<name replace-wildcards="yes">%h</name>
	<service>
		<type>_smb._tcp</type>
		<port>445</port>
	</service>
	<service>
		<type>_device-info._tcp</type>
		<port>0</port>
		<txt-record>model=MacPro6,1</txt-record>
	</service>
	<service>
		<type>_adisk._tcp</type>
		<txt-record>sys=waMa=0,adVF=0x100</txt-record>
		<txt-record>dk0=adVN=Time Machine,adVF=0x82</txt-record>
	</service>
</service-group>
``` 

### Miscellaneous

#### Articles: 
- https://www.reddit.com/r/homelab/comments/83vkaz/howto_make_time_machine_backups_on_a_samba/
- https://www.samba.org/samba/docs/current/man-html/smb.conf.5.html
- https://kirb.me/2018/03/24/using-samba-as-a-time-machine-network-server.html

#### Known restrictions:
- Currently no Spotlight support

#### Dependencies
- The bootstrap.sh file originates from https://wiki.samba.org/index.php/Package_Dependencies_Required_to_Build_Samba#Verified_Package_Dependencies
