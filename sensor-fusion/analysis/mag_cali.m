data = readmatrix('circleimu.csv');
datagps=readmatrix('circlegps.csv');
bag1 = rosbag("circle.bag");
bsel_imu1 = select(bag1,'Topic','/imu');
msg_imu1 = readMessages(bsel_imu1,'DataFormat','struct');
time_sec = cellfun(@(m) double(m.Header.Stamp.Sec),msg_imu1);
time_nsec = cellfun(@(m) double(m.Header.Stamp.Nsec),msg_imu1);
time = time_sec+(time_nsec/10e9);
time = time - time(1);
% time = data(:,1);
% time = time/time(1);
% time = time*10e9;
% time = time - time(1);
ori_x= data(:,10); 
ori_y = data(:,11);
seq=data(:,2);
ori_z= data(:,12);
ori_w= data(:,13);
ang_x= data(:,15);
ang_y= data(:,16);
ang_z= data(:,17);
acc_x= data(:,33);
acc_y= data(:,34);
acc_z= data(:,35);
mag_x= data(:,48);
mag_y= data(:,49);
mag_z= data(:,50);

%CALIBRATION
figure(1);
scatter(mag_x,mag_y,20,'blue','filled');
xlabel('mag x');
ylabel('mag y');
title('circle without calibration');
hold on
ell=fit_ellipse(mag_x,mag_y,1)
cc=[0.99,-0.1443,0;-0.1443,0.75,0;0,0,1];
%hard iron
% xoff=(max(mag_x)+min(mag_x))/2;
% yoff=(max(mag_y)+min(mag_y))/2;
% mag_x=mag_x-xoff;
% mag_y=mag_y-yoff;
% %soft iron

% for i=1:length(mag_x)
%     magcal=[(ell.b)/(ell.a), 0, 0;0, 1, 0; 0, 0, 1]*[cos(ell.phi),-sin(ell.phi), -(ell.X0_in);sin(ell.phi),cos(ell.phi),-(ell.Y0_in);0 0 1 ]*[mag_x(i); mag_y(i); mag_z(i)];
%     %magcal=cc*[mag_x(i); mag_y(i); mag_z(i)];
%     mag_x(i)=magcal(1);
%     mag_y(i)=magcal(2);
%     mag_z(i)=magcal(3);
% end
for i=1:length(mag_x)
    vn100=[0.95,-0.1443,0;-0.1443,0.75,0;0,0,1];
    theta=pi*1.5/4;
    % hi=[mag_x(i)+0.065;mag_y(i)-0.2;mag_z(i)-0];
    rot=[cos(theta),-sin(theta),0;sin(theta),cos(theta),0;0,0,1];
    magcal=rot*vn100*[mag_x(i)+0.065; mag_y(i)-0.2; mag_z(i)];
    mag_x(i)=magcal(1);
    mag_y(i)=magcal(2);
    mag_z(i)=magcal(3);
end
figure;
scatter(mag_x,mag_y,20,'blue','filled');
xlabel('mag x');
ylabel('mag y');
title('hard iron and soft iron calibration');
axis equal