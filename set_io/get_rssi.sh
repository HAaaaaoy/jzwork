#!/bin/sh
value_rssi=$(ssh root@192.168.1.103 "iwpriv vap0 cfg get_rssi | grep - | awk print {2} {3}")
echo $value_rssi