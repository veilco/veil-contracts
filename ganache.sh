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

ganache-cli -b 1 -l 300000000 -p $PORT -a 10 -e 100000 --account 0xa66195e41058b11e278a65c0e811944857c08d78d618e1fffdcc98cf3e9cec5a,100000000000000 0xa66195e41058b11e278a65c0e811944857c08d78d618e1fffdcc99cf3e9cec5a,1000000000000000000000

