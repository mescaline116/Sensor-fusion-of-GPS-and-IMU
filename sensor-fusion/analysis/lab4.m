close all
clear
clc
data = readmatrix('circleimu.csv');
datap = readmatrix('pathimu.csv');
datagps=readmatrix('pathgps.csv');

bag1 = rosbag("circle.bag");
bsel_imu1 = select(bag1,'Topic','/imu');
msg_imu1 = readMessages(bsel_imu1,'DataFormat','struct');

bag2 = rosbag("path.bag");
bsel_imu2 = select(bag2,'Topic','/imu');
msg_imu2 = readMessages(bsel_imu2,'DataFormat','struct');

bag3 = rosbag("path.bag");
bsel_imu3 = select(bag3,'Topic','/gps');
msg_imu3 = readMessages(bsel_imu3,'DataFormat','struct');

%PARAMETERS FOR CIRLE
time_sec = cellfun(@(m) double(m.Header.Stamp.Sec),msg_imu1);
time_nsec = cellfun(@(m) double(m.Header.Stamp.Nsec),msg_imu1);
time = time_sec+(time_nsec/10e9);
time = time - time(1);
% time = data(:,1);
% time = time/time(1);
% time = time*10e9;
% time = time - time(1);
ori_x= data(:,8); 
ori_y = data(:,9);
seq=data(:,2);
ori_z= data(:,10);
ori_w= data(:,11);
ang_x= data(:,21);
ang_y= data(:,22);
ang_z= data(:,23);
acc_x= data(:,33);
acc_y= data(:,34);
acc_z= data(:,35);
mag_x= data(:,48);
mag_y= data(:,49);
mag_z= data(:,50);

%PARAMETERS FOR PATH
time_sec2 = cellfun(@(m) double(m.Header.Stamp.Sec),msg_imu2);
time_nsec2 = cellfun(@(m) double(m.Header.Stamp.Nsec),msg_imu2);
timep = time_sec2+(time_nsec2/10e9);
timep = timep - timep(1);
% timep = datap(:,1);
% timep = timep/timep(1);
% timep = timep*10e9;
% timep = timep - timep(1);
ori_xp= datap(:,8); 
ori_yp = datap(:,9);
seqp=datap(:,2);
ori_zp= datap(:,10);
ori_wp= datap(:,11);
ang_xp= datap(:,21);
ang_yp= datap(:,22);
ang_zp= datap(:,23);
acc_xp= datap(:,33);
acc_yp= datap(:,34);
acc_zp= datap(:,35);
mag_xp= datap(:,48);
mag_yp= datap(:,49);
mag_zp= datap(:,50);
raw_yaw=datap(:,61);

%PARAMETERS FOR GPS PATH
time_sec3 = cellfun(@(m) double(m.Header.Stamp.Sec),msg_imu3);
time_nsec3 = cellfun(@(m) double(m.Header.Stamp.Nsec),msg_imu3);
timegps = time_sec3+(time_nsec3/10e9);
timegps = timegps - timegps(1);
% timegps= datagps(:,1);
%timegps = timegps/timegps(1);
%timegps = timegps*10e9;
% timegps=timegps-datagps(1);
lat = datagps(:,5); 
lon = datagps(:,6);
utm_northing = datagps(:,9);
utm_northing = utm_northing - min(utm_northing);
utm_easting = datagps(:,8);
utm_easting = utm_easting - min(utm_easting);

%CALIBRATION
figure(1);
scatter(mag_x,mag_y,20,'blue','filled');
hold on
ell=fit_ellipse(mag_x,mag_y,1);

%hard iron
% xoff=(max(mag_xp)+min(mag_xp))/2;
% yoff=(max(mag_yp)+min(mag_yp))/2;
% mag_xp=mag_xp-xoff;
% mag_yp=mag_yp-yoff;

%soft iron
% for i=1:length(mag_xp)
%     magcal=[1, 0, 0;0, (ell.a)/(ell.b), 0; 0, 0, 1]*[cos(ell.phi),-sin(ell.phi), -(ell.X0_in);sin(ell.phi),cos(ell.phi),-(ell.Y0_in);0 0 1 ]*[mag_xp(i); mag_yp(i); mag_zp(i)];
%     mag_xp(i)=magcal(1);
%     mag_yp(i)=magcal(2);
%     mag_zp(i)=magcal(3);
% end

for i=1:length(mag_xp)
    vn100=[0.95,-0.1443,0;-0.1443,0.75,0;0,0,1];
    theta=pi*1.5/4;
    rot=[cos(theta),-sin(theta),0;sin(theta),cos(theta),0;0,0,1];
    magcal=rot*vn100*[mag_xp(i)+0.065; mag_yp(i)-0.2; mag_zp(i)];
    mag_xp(i)=magcal(1);
    mag_yp(i)=magcal(2);
    mag_zp(i)=magcal(3);
end
 %figure;
 %scatter(mag_x,mag_y,20,'blue','filled');
% axis equal

%RAW YAW
figure;
raw_yaw=deg2rad(raw_yaw);
raw_yaw=unwrap(raw_yaw);
plot(timep,raw_yaw);
xlabel('time (in sces)');
ylabel('yaw (in radians)');
title('Raw Yaw');

%MAGNETOMETER YAW
mag_yaw=atan2(mag_xp,mag_yp);
mag_yaw=unwrap(mag_yaw);
mag_yaw=lowpass(mag_yaw,0.001,40);
figure;
plot(timep,mag_yaw);
xlabel('time (in sces)');
ylabel('yaw (in radians)');
title('Magnetometer Yaw');

%GYRO YAW
gy_yaw=cumtrapz(timep,ang_zp);
%gy_yaw=-gy_yaw;
gy_yaw=unwrap(gy_yaw);
%gy_yaw=highpass(gy_yaw,0.1,40);
figure;
plot(timep,gy_yaw);
xlabel('time (in sces)');
ylabel('yaw (in radians)');
title('Gyroscope Yaw');

%COMPLIMENTARY FILTER
alpha=0.25;
comp_yaw=alpha*mag_yaw+(1-alpha)*gy_yaw;
figure;
plot(timep,comp_yaw);
% figure;
% plot(utm_easting,utm_northing);
figure;
plot(timep,mag_yaw);
hold on
plot(timep,gy_yaw);
hold on
plot(timep,comp_yaw);
hold on
plot(timep,raw_yaw);
legend('mag yaw','gyro yaw','comp yaw','raw yaw');
xlabel('time (in sces)');
ylabel('yaw (in radians)');
title('yaw plot');

figure;
plot(timep,mag_yaw);
hold on
plot(timep,gy_yaw);
legend('mag yaw','gyro yaw');
xlabel('time (in sces)');
ylabel('yaw (in radians)');
title('mag vs gyro yaw plot');

%% FORWARD VELOCITY

%IMU VELOCITY
vel_imu=cumtrapz(timep,acc_xp);
figure;
plot(timep,vel_imu);

%acc plot
figure;
plot(timep,acc_xp);
xlabel('time (in sces)');
ylabel('Linear Acceleration in x(in m/s^2 )');
title('acc with bias');

%GPS VELOCITY
for i=2:length(timegps)
    vel_gps_x=(utm_easting(i)-utm_easting(i-1))/(timegps(i)-timegps(i-1));
    vel_gps_y=(utm_northing(i)-utm_northing(i-1))/(timegps(i)-timegps(i-1));
    vel_gps(i-1)=sqrt(((vel_gps_x)^2)+((vel_gps_y)^2));
end
vel_gps(length(timegps))=0;
figure;
plot(timegps,vel_gps);
hold on
plot(timep,vel_imu);
xlabel('time (in sces)');
ylabel('velocity (in m/s)');
title('Estimated IMU and GPS velocities without removing bias');
legend('GPS vel','IMU vel');
%IMU W/O BIAS

range_list=[0,45,96,220,267,293,307,332,375,474,500,580];
for i=1:length(range_list)-1
    fp=range_list(i)+1;
    ep=range_list(i+1);
    net_zero_acc=acc_xp(round(fp*length(timep)/582):round(ep*length(timep)/582));
    %net_zero_acc=acc_xp(fp:ep);
    acc_xp(round(fp*length(timep)/582):round(ep*length(timep)/582)) =net_zero_acc-mean(net_zero_acc);
    %acc_xp(fp:ep) =net_zero_acc-mean(net_zero_acc);
end

%acc_xp=acc_xp+0.55;
figure;
plot(timep,acc_xp);
adjusted_vel=cumtrapz(timep,acc_xp);
adjusted_vel=adjusted_vel-4;
adjusted_vel(adjusted_vel<0)=0;
figure;
plot(timep,adjusted_vel);

%imu vel and adjusted vel imu
figure;
plot(timep,adjusted_vel);
hold on
plot(timegps,vel_gps);
xlabel('time (in sces)');
ylabel('velocity (in m/s)');
title('Estimated IMU and GPS velocities after removing bias');
legend('IMU vel','GPS vel');
%% DEAD RECKONING

%DISPLACEMENT
disp_imu=cumtrapz(timep,adjusted_vel);
disp_gps=cumtrapz(timegps,vel_gps);
figure;
plot(timep,disp_imu);
hold on
plot(timegps,disp_gps);
xlabel('time (in sces)');
ylabel('displacement (in m)');
title('Displacement');
legend('IMU displacement','GPS displacement');
% figure;
% plot(timegps,utm_easting);

X=cumtrapz(timep,acc_xp);
omgX=X.*ang_zp;
yobs=acc_yp;
yobs=lowpass(yobs,0.001,40);
figure;
plot(timep,yobs);
hold on
plot(timep,omgX);
xlabel('time (in secs)');
ylabel('acc (in m/s^2 )');
title('omegaX vs Y obs plot');
legend('Yobs','OmegaX');

%ROTATING FWD VEL
ve=adjusted_vel.*cos(gy_yaw);
vn=adjusted_vel.*sin(gy_yaw);
xe=cumtrapz(timep,ve);
xn=cumtrapz(timep,vn);
figure;
angle1 = -100;
angle1 = deg2rad(angle1);
east_new=(cos(angle1)*(xe)-sin(angle1)*(xn));
north_new=(sin(angle1)*(xe)+cos(angle1)*(xn));
offset1=395;
offset2 = utm_northing(1)-north_new(1);
east_new = east_new+offset1;
north_new = north_new+offset2;
plot(utm_easting,utm_northing);
hold on
scaling = 1.5;
plot(east_new/scaling,-north_new/scaling);
xlabel(' x displacement (in m)');
ylabel(' y displacement (in m)');
title('Trajectories');
legend('GPS Trajectory','IMU Trajectory');
