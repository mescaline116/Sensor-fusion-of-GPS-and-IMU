#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import rospy
import serial
from imu_driver.msg import imu_msg
import utm
import sys
from rospy import Time
import numpy as np

# Reading the port form terminal command
# port =  sys.argv[1]

def Eul2Quaternion(yaw,pitch,roll):
    qx = np.sin(roll/2) * np.cos(pitch/2) * np.cos(yaw/2) - np.cos(roll/2) * np.sin(pitch/2) * np.sin(yaw/2)
    qy = np.cos(roll/2) * np.sin(pitch/2) * np.cos(yaw/2) + np.sin(roll/2) * np.cos(pitch/2) * np.sin(yaw/2)
    qz = np.cos(roll/2) * np.cos(pitch/2) * np.sin(yaw/2) - np.sin(roll/2) * np.sin(pitch/2) * np.cos(yaw/2)
    qw = np.cos(roll/2) * np.cos(pitch/2) * np.cos(yaw/2) + np.sin(roll/2) * np.sin(pitch/2) * np.sin(yaw/2)
       
    return [qx, qy, qz, qw]


    

if __name__ == '__main__':
    #SENSOR_NAME = "imu"
    rospy.init_node('imu_node')
    #serial_port = rospy.get_param(port, '/dev/ttyUSB0')
    serial_baud = rospy.get_param('~baudrate',115200)
    sampling_rate = rospy.get_param('~sampling_rate',5.0)
    
    v= rospy.get_param('driver/port')
    serial_port = rospy.get_param('~port',v)
    port = serial.Serial(serial_port, serial_baud, timeout=3)
    
    rospy.logdebug("Using IMU sensor on port "+serial_port+" at "+str(serial_baud))
    
    imu_pub = rospy.Publisher('/imu', imu_msg, queue_size=5)
    
    rospy.logdebug("Initialization complete")
    rospy.loginfo("Publishing  data")
    imu_msg1 = imu_msg()
    imu_msg1.Header.seq = 0
    imu_msg1.Header.frame_id = "IMU1_Frame" 
    # imu_msg.child_frame_id = SENSOR_NAME
    #sleep_time = 1/sampling_rate - 0.025
   
    try:
        while not rospy.is_shutdown():
            line = port.readline()
            
            #items = list(map(str,line.split(",")))
            stringformat = str(line)
            items = list(map(str,stringformat.split(',')))
            print("the items are",items)
            if (items[0] == "b'\\r$VNYMR" or items[0] =="b'$VNYMR"):
                #rospy.logwarn("Not Recieveing IMU data")
            #elif (items[0] == "b'\\r$VNYMR" or items[0] =="b'$VNYMR") and items[2] !='':
                print("the items are",items)
                yaw  = float(items[1])
                pitch = float(items[2])
                roll = float(items[3])
                magx = float(items[4])
                magy = float(items[5])
                magz = float(items[6])
                accelx = float(items[7])
                accely = float(items[8])
                accelz = float(items[9])
                gyrox = float(items[10])
                gyroy = float(items[11])
                gyroz = float(items[12].split('*')[0])            
                
                qx, qy, qz, qw = Eul2Quaternion(yaw, pitch, roll)
                
                imu_msg1.IMU.orientation.x, imu_msg1.IMU.orientation.y, imu_msg1.IMU.orientation.z, imu_msg1.IMU.orientation.w  = qx, qy, qz, qw
                imu_msg1.IMU.angular_velocity.x, imu_msg1.IMU.angular_velocity.y, imu_msg1.IMU.angular_velocity.z = gyrox, gyroy, gyroz
                imu_msg1.IMU.linear_acceleration.x, imu_msg1.IMU.linear_acceleration.y, imu_msg1.IMU.linear_acceleration.z  = accelx, accely, accelz
                
                imu_msg1.MagField.magnetic_field.x, imu_msg1.MagField.magnetic_field.y, imu_msg1.MagField.magnetic_field.z = magx, magy, magz
                
                        
                imu_msg1.Header.stamp = rospy.Time.now()   
                imu_msg1.Header.seq+=1
                imu_pub.publish(imu_msg1)
                #rospy.sleep(sleep_time)
            
    except rospy.ROSInterruptException:
        port.close()
    
    except serial.serialutil.SerialException:
        rospy.loginfo("Shutting down GPS node...")
        
