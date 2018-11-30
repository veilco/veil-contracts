PORT=8545

while [ "$1" != "" ]; do
  PARAM=`echo $1 | awk -F= '{print $1}'`
  VALUE=`echo $1 | awk -F= '{print $2}'`
  case $PARAM in
    -p | --port)
      PORT=$VALUE
      ;;
    *)
    echo "ERROR: unknown parameter \"$PARAM\""
    usage
    exit 1
    ;;
  esac
  shift
done

ganache-cli -b 1 -l 300000000 -p $PORT -e 100000 --mnemonic "almost nasty switch remind embark holiday seminar decline space unable all evil"
