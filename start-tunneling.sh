#!/bin/sh

main() {
  checkRequirements
  setupIptablesPrerouting
  setupIptablesPostrouting

  stayAlive
}

checkRequirements() {
  hasNetAdminCapability
  mappingFileExists
}

hasNetAdminCapability() {
  if ! getpcaps 1 2>&1 | grep cap_net_admin > /dev/null; then
    echo 'This container requires the "--cap-add=NET_ADMIN" flag.'
    exit 1
  fi
}

mappingFileExists() {
  if [ ! -f 'mapping.yml' ]; then
    echo "Did not find required mapping file: '${PWD}/mapping.yml'"
    exit 1
  fi
}

setupIptablesPrerouting() {
  for i in $(tunneling-mapping-parser -s); do
    acceptPort=$(tunneling-mapping-parser -m "${i}" -p acceptPort)
    destinationIp=$(tunneling-mapping-parser -m "${i}" -p targetIp)
    destinationPort=$(tunneling-mapping-parser -m "${i}" -p targetPort)

    printf "Setting up tunneling %s..." "$(tunneling-mapping-parser -m "${i}")"
    iptables -t nat -A PREROUTING -p tcp --dport "${acceptPort}" -j DNAT --to-destination "${destinationIp}":"${destinationPort}"

    echo 'DONE'
  done
}

setupIptablesPostrouting() {
  iptables -t nat -A POSTROUTING -j MASQUERADE

  for iface in $(ip address | grep eth | grep inet | awk '{print $2}'); do
    iptables -t nat -A POSTROUTING -s "$iface" -j MASQUERADE
  done
}

stayAlive() {
  trap shutdown INT TERM

  while true; do
    sleep 600 &
    wait $!
  done
}

shutdown() {
  kill -s TERM $!
  exit 0
}

main
