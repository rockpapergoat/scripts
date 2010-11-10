#!/usr/bin/env bash
# 101102, nate@tsp
# install cert to /etc, remove when done
if [[ -f /etc/CA.pem ]]; then
	/usr/bin/security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain /etc/CA.pem
else
	echo "can't proceed; no cert in temp"
fi
	
