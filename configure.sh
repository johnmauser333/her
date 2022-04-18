#!/bin/sh

# Download and install V2Ray
mkdir /tmp/v2ray
wget -q https://github.com/v2fly/v2ray-core/releases/latest/download/v2ray-linux-64.zip -O /tmp/v2ray/v2ray.zip
unzip /tmp/v2ray/v2ray.zip -d /tmp/v2ray
install -m 755 /tmp/v2ray/v2ray /usr/local/bin/v2ray
install -m 755 /tmp/v2ray/v2ctl /usr/local/bin/v2ctl

# Remove temporary directory
rm -rf /tmp/v2ray

# V2Ray new configuration
install -d /usr/local/etc/v2ray
cat << EOF > /usr/local/etc/v2ray/config.json
{
// reverse proxy portal
  "reverse": {
    "portals": [
      {
        "tag": "portal",
        "domain": "apacheapache.com.jp"  // the same as bridge
      }
    ]
  },
// v2ray + ws + tls config
  "inbounds": [
  // receive client's connection
  {
    "tag": "clientin",
    "port": $PORT,
    "protocol": "vmess",
    "settings": {
      "clients": [
        {
          "id": "$UUID",
          "alterId": 0
        }
      ]
    },
    "streamSettings": {
      "network": "ws",
      "wsSettings": {
        "path": "/v2ray"
      }
    }
  },
// receive bridge's connection
  {
    "tag": "interconn",
    "port": $PORT,
    "protocol": "vmess",
    "settings": {
      "clients": [
        {
          "id": "$UUID",
          "alterId": 0
        }
      ]
    },
    "streamSettings": {
      "network": "ws",
      "wsSettings": {
        "path": "/path"
      }
    }  
  }
], // end of the inbounds
// outbounds for network proxy
  "outbounds": [{
    "tag": "crossfire",
    "protocol": "freedom",
    "settings": {}
  }],
// routing rules
  "routing": {
    "rules": [
      {
        "type": "field",
        "inboundTag": ["interconn"],
        "outboundTag": "portal"
      },
      {
        "type": "field",
        "inboundTag": ["clientin"],
        "ip": "0.0.0.0",
        "port": "$PORT",
        "outboundTag": "portal"  // for a specific ip and port range to access remote services
      },
      {
        "type": "field",
        "inboundTag": ["clientin"],
        "outboundTag": "crossfire"  // remaining traffic goes here
      }
    ]
  }
}
EOF

# Run V2Ray
/usr/local/bin/v2ray -config /usr/local/etc/v2ray/config.json