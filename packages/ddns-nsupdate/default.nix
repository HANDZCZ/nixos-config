{
  writeShellApplication,
  iproute2,
  gawk,
  dig,
  ...
}:

writeShellApplication rec {
  name = "ddns-nsupdate";
  runtimeInputs = [
    iproute2
    gawk
    dig
  ];
  text = ''
    FQDN="" SERVER="" KEY="" TTL=60 IFACE="" ZONE="" ALL=0

    while getopts "f:s:k:t:i:z:ah" o; do
      case $o in
        f) FQDN=$OPTARG ;;
        s) SERVER=$OPTARG ;;
        k) KEY=$OPTARG ;;
        t) TTL=$OPTARG ;;
        i) IFACE=$OPTARG ;;
        z) ZONE=$OPTARG ;;
        a) ALL=1 ;;
        *) echo "Usage: ${name} -f FQDN -s SERVER -k KEY [-t TTL] [-i IFACE | -a]" >&2; exit 1
      esac
    done

    [[ $FQDN == *. ]] || FQDN="$FQDN."

    # Collect IPs
    if [[ $ALL -eq 1 ]]; then
      mapfile -t IP4S < <(ip -4 -o addr show scope global | awk '{split($4,a,"/");print a[1]}')
      mapfile -t IP6S < <(ip -6 -o addr show scope global | awk '{split($4,a,"/");print a[1]}')
    else
      [[ -z $IFACE ]] && IFACE=$(ip route | awk '/default/{print $5;exit}')
      mapfile -t IP4S < <(ip -4 -o addr show dev "$IFACE" scope global | awk '{split($4,a,"/");print a[1]}')
      mapfile -t IP6S < <(ip -6 -o addr show dev "$IFACE" scope global | awk '{split($4,a,"/");print a[1]}')
    fi

    # Build & send
    {
      echo "server $SERVER"
      [[ -n $ZONE ]] && echo "zone $ZONE."
      [[ ''${#IP4S[@]} ]] && { echo "update delete $FQDN A"; for i in "''${IP4S[@]}"; do echo "update add $FQDN $TTL A $i"; done; }
      [[ ''${#IP6S[@]} ]] && { echo "update delete $FQDN AAAA"; for i in "''${IP6S[@]}"; do echo "update add $FQDN $TTL AAAA $i"; done; }
      echo "send"
    } | nsupdate -k "$KEY"
  '';
}
