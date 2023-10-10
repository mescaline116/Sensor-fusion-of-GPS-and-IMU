Edited on Oct 10 2023- I have made the python script executable in CMakeLists.txt

## Steps to run

1) Git clone the package
2) cd EECE5554/LAB1
3) catkin_make
4) source devel/setup.bash

## For collecting GPS data into /gps topic

5) roslaunch gps_driver driver.launch port:="/dev/ttyUSB0"
6) To create a ROS bag file, run - rosbag record /gps
