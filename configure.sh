#!/bin/sh

# Download and install V2Ray
mkdir /tmp/xray
wget -q https://github.com/XTLS/Xray-core/releases/download/v1.5.9/Xray-linux-64.zip -O /tmp/xray/xray.zip
unzip /tmp/xray/xray.zip -d /tmp/xray
install -m 755 /tmp/xray/xray /usr/local/bin/xray

# Remove temporary directory
rm -rf /tmp/xray

# V2Ray new configuration
install -d /usr/local/etc/xray
cat << EOF > /usr/local/etc/xray/config.json
{
    "inbounds": [
        {
            "tag": "in_tomcat",
            "port": $PORT,
            "protocol": "dokodemo-door",
            "settings": {
                "address": "127.0.0.1",
                "port": 6889,
                "network": "tcp,udp"
            }
        },
        {
            "tag": "in_interconn",
            "port": $PORT,
            "protocol": "vmess",
            "settings": {
                "clients": [
                    {
                        "id": "$UUID",
                        "alterId": 0,
                        "security": "chacha20-poly1305"
                    }
                ]
            },
            "streamSettings": {
              "network": "ws"
            }
        },
        {
            "tag": "client_in",
            "port": $PORT,
            "protocol": "vmess",
            "settings": {
                "clients": [
                    {
                        "id": "$UUID",
                        "alterId": 0,
                        "security": "chacha20-poly1305"
                    }
                ]
            },
            "streamSettings": {
              "network": "ws",
              "wsSettings": {
              "path": "/v2ray"
              }
            }
        }
    ],
"outbounds": [{"tag": "crossfire", "protocol": "freedom", "settings": {}}],
    "reverse": {
        "portals": [
            {
                "tag": "portal",
                "domain": "yoshimitsu737-freenom.ml"
            }
        ]
    },
    "routing": {
        "rules": [
            {
                "type": "field",
                "inboundTag": [
                    "in_tomcat"
                ],
                "outboundTag": "portal"
            },
            {
                "type": "field",
                "inboundTag": [
                    "in_interconn"
                ],
                "outboundTag": "portal"
            },
            {
                "type": "field",
                "inboundTag": [
                    "client_in"
                ],
                "outboundTag": "crossfire"
            }
        ]
    }
}
EOF

# Run V2Ray
/usr/local/bin/xray -config /usr/local/etc/xray/config.json
