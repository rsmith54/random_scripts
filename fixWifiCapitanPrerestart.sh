
echo 'shutting off wifi'
networksetup -setairportpower en1 off


systemConfiguration='/Library/Preferences/SystemConfiguration/'
ls -lthr $systemConfiguration

rm  -f  $systemConfiguration/NetworkInterfaces.plist
rm  -f  $systemConfiguration/com.apple.network.eapolclient.configuration.plist
rm  -f  $systemConfiguration/com.apple.airport.preferences.plist
rm  -f  $systemConfiguration/com.apple.airport.preferences.plist-new
rm  -f  $systemConfiguration/com.apple.wifi.message-tracer.plist
rm  -f  $systemConfiguration/preferences.plist
