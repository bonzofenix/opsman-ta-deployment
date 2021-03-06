#!/bin/bash


scripts_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $scripts_dir/common.sh

function update_certificates() {
  local six_month_certs="$(om curl -s --path /api/v0/deployed/certificates?expires_within=6m | jq '.certificates | .[]' -r )"

  log "\nNON ROTATABLE CERTIFICATES:"

  log "expiring <6m:"
  echo $six_month_certs | jq 'select(.variable_path=="/opsmgr/bosh_dns/tls_ca") | .property_reference' -r

  log "\nNON CONFIGURABLE CERTIFICATES:"

  log "expiring <6m:"
  echo $six_month_certs | jq 'select(.configurable==false) | select(.location|test("opsman|credhub")) |  .variable_path' -r

  log "\nCONFIGURABLE CERTIFICATE:"

  log "expiring <6m:"
  echo $six_month_certs | jq 'select(.configurable==true) | " \(.product_guid): \n\t KEY:\t\t\(.property_reference) \n\t EXPIRES_AT:\t\(.valid_until)"' -r

}

update_certificates

