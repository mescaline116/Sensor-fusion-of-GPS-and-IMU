#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import rospy
import serial
import sys
import utm
from rospy import Time
from gps_driver.msg import gps_msg

def gpsdriver():
    rospy.init_node('driver_code')
    gps_msg1 = gps_msg()
    gps_msg1.header.seq = 0
    gps_msg1.header.frame_id = "GPS1_Frame" 
    gps_pub= rospy.Publisher('gps', gps_msg, queue_size=10)

    v= rospy.get_param('driver/port')
    serial_port = rospy.get_param('~port',v)
    serial_baud = rospy.get_param('~baudrate',4800)
    port = serial.Serial(serial_port, serial_baud, timeout=3.)  
    
    try:
        while not rospy.is_shutdown():
            line = port.readline()

            strng = str(line)
            things = list(map(str,strng.split(',')))

            # print(things)
            if (things[0] == "b'$GPGGA" or things[0]=="b'\\r$GPGGA") and things[2] == '':
                rospy.logwarn("no gps data")
            elif (things[0] == "b'$GPGGA" or things[0]=="b'\\r$GPGGA") and things[2] !='':
                print("the data is",things)

                utc = float(things[1])
                utc_secs = int(utc)
                utc_nsecs = int((utc - utc_secs) * 1e9)
                gps_msg1.header.stamp = Time(utc_secs, utc_nsecs)

                lat = things[2]
                lati_direc = things[3]
                long = things[4]
                long_direc = things[5]

                gps_msg1.altitude = float(things[9])
                deg = float(lat[:2])
                dec_mins = float(lat[2:])
                dec_deg = deg + dec_mins / 60.0
                degl = float(long[:3])
                dec_minl = float(long[3:])
                dec_degl = degl + dec_minl / 60.0

                if lati_direc == 'S':
                    dec_deg=dec_deg*(-1)
                if long_direc=='W':
                    dec_degl=dec_degl*(-1)
                
                gps_msg1.latitude = dec_deg
                gps_msg1.longitude = dec_degl
                gps_msg1.utm_easting, gps_msg1.utm_northing, gps_msg1.zone, gps_msg1.letter = utm.from_latlon(dec_deg,dec_degl)
                gps_msg1.header.seq+=1
                gps_pub.publish(gps_msg1)  
                
    except serial.serialutil.SerialException:
        rospy.loginfo("Shutting down GPS node...")           

if __name__ == '__main__':
    try:
        gpsdriver()
    except rospy.ROSInterruptException:
        pass

    
   
    
    
    
