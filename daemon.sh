#!/bin/bash
# Cloudflare as Dynamic DNS
# From: https://letswp.io/cloudflare-as-dynamic-dns-raspberry-pi/
# Based on: https://gist.github.com/benkulbertis/fff10759c2391b6618dd/
# Original non-RPi article: https://phillymesh.net/2016/02/23/setting-up-dynamic-dns-for-your-registered-domain-through-cloudflare/

# Fixed and documented version by Christian Gambardella (https://gambo.io)
# Cleaned up and daemonized by Sebastiano Barezzi <barezzisebastiano@gmail.com>

source ./keys.sh

log() {
    if [ "$@" ]; then
        echo -e "[$(date)] - $@"
    fi
}

get_ip() {
    curl -s http://ipv4.icanhazip.com
}

cloudflare_curl() {
    local http_request="${1}"
    shift
    local url="${1}"
    shift

    curl -s -X "${http_request}" "https://api.cloudflare.com/client/v4/${url}" \
        -H "Authorization: Bearer ${auth_token}" \
        -H "Content-Type: application/json" \
        "${@}"
}

zone_identifier=$(cloudflare_curl GET "zones?name=${zone_name}" | grep -Po '"id": *\K"[^"]*"' | head -1 | tr -d \")
record_identifier=$(cloudflare_curl GET "zones/${zone_identifier}/dns_records?name=${record_name}" | grep -Po '(?<="id":")[^"]*')

log "record: $record_identifier"
log "zone: $zone_identifier"

while true; do
    log "Checking"
    ip="$(get_ip)"

    if [ "${ip}" == "${old_ip}" ]; then
        log "IP hasn't changed (old: ${old_ip} new: ${ip})"
    else
        update=$(cloudflare_curl PUT "zones/${zone_identifier}/dns_records/${record_identifier}" \
                 --data "{\"id\":\"${zone_identifier}\",\"type\":\"A\",\"name\":\"${record_name}\",\"content\":\"${ip}\"}")

        if [[ ${update} == *"\"success\":false"* ]]; then
            log "API UPDATE FAILED. DUMPING RESULTS:\n${update}"
        else
            log "IP changed to: ${ip}"
        fi

    fi

    old_ip="${ip}"

    # Wait 30 minutes
    sleep 1800
done
