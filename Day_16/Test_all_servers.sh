for server in stapp01 stapp02 stapp03; do
    echo "Testing $server:5001"
    curl -s http://$server:5001
    echo
done