wifiDevice='en1'
wifi='Wi-Fi'
dnsPorts='8.8.8.8 8.8.4.4'
locationName='testLocation'
networkName='guest'

echo 'wifiDevice'   
echo 'wifi'	    
echo 'dnsPorts'	    
echo 'locationName' 
echo 'networkName'

echo ''

echo $wifiDevice   
echo $wifi	    
echo $dnsPorts	    
echo $locationName 
echo $networkName

echo ''

networksetup -setairportpower $wifiDevice on

networksetup -createlocation   $locationName populate
networksetup -switchtolocation $locationName

networksetup -setdhcp $wifi Empty

networksetup -setdnsservers $wifi $dnsPorts

networksetup -setMTU $wifiDevice 1453

networksetup -setairportpower $wifiDevice on
networksetup -setairportpower $wifiDevice on

networksetup -listpreferredwirelessnetworks $wifiDevice
networksetup -removeallpreferredwirelessnetworks $wifiDevice

#networksetup -addpreferredwirelessnetworkatindex $wifiDevice $networkname OPEN ""
echo 'Now try joining your network.  If you fail contact network admin'
