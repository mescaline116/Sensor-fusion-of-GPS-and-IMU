data = readmatrix('imu.csv');

% Extract columns 
time = data(:,1);
time = time-data(1,1);
ori_x= data(:,10); 
ori_y = data(:,11);
seq=data(:,2);
ori_z= data(:,12);
ori_w= data(:,13);
ang_x= data(:,15);
ang_y= data(:,16);
ang_z= data(:,17);
acc_x= data(:,19);
acc_y= data(:,20);
acc_z= data(:,21);
mag_x= data(:,27);
mag_y= data(:,28);
mag_z= data(:,29);

ypr=quat2eul([ori_x,ori_y,ori_z,ori_w]);
yaw=ypr(:,1);
pitch=ypr(:,2);
roll=ypr(:,3);

% ypr time
figure;
subplot(3,1,1);
plot(time, yaw);
ylabel('Yaw (in rad)');
xlabel('Time (in sec)');

subplot(3,1,2);
plot(time, pitch); 
ylabel('Pitch (in rad)');
xlabel('Time (in sec)'); 

subplot(3,1,3);
plot(time, roll); 
ylabel('Roll (in rad)');
xlabel('Time (in sec)'); 

% ypr frequency
figure;
subplot(3,1,1)
histogram(yaw)
xlabel('Yaw (in rad)');
ylabel('Frequency');
% Compute mean and standard deviation.
mu = mean(yaw)
sigma = std(yaw)
% Indicate those on the plot.
xline(mu, 'Color', 'g', 'LineWidth', 1);
xline(mu - sigma, 'Color', 'r', 'LineWidth', 1, 'LineStyle', '--');
xline(mu + sigma, 'Color', 'r', 'LineWidth', 1, 'LineStyle', '--');

subplot(3,1,2)
histogram(pitch)
xlabel('Pitch (in rad)');
ylabel('Frequency');

subplot(3,1,3)
histogram(roll)
xlabel('Roll (in rad)');
ylabel('Frequency');

% ang vel vs time
figure;
subplot(3,1,1);
plot(time, ang_x);
ylabel('Angular Velocity X (in rads/sec)');
xlabel('Time (in sec)');

subplot(3,1,2);
plot(time, ang_y); 
ylabel('Angular Velocity Y (in rads/sec)');
xlabel('Time (in sec)'); 

subplot(3,1,3);
plot(time, ang_z); 
ylabel('Angular Velocity Z (in rads/sec)');
xlabel('Time (in sec)'); 

% ang vel freq
figure;
subplot(3,1,1);
histfit(ang_x);
xlabel('Angular Velocity X (in rads/sec)');
ylabel('Frequency');

subplot(3,1,2);
histfit(ang_y); 
xlabel('Angular Velocity Y (in rads/sec)');
ylabel('Frequency'); 

subplot(3,1,3);
histfit(ang_z); 
xlabel('Angular Velocity Z (in rads/sec)');
ylabel('Frequency'); 

% lin acc vs time
figure;
subplot(3,1,1);
plot(time, acc_x);
ylabel('Linear Acceleration X (in m/s^2 )');
xlabel('Time (in sec)');

subplot(3,1,2);
plot(time, acc_y); 
ylabel('Linear Acceleration Y (in m/s^2 )');
xlabel('Time (in sec)'); 

subplot(3,1,3);
plot(time, acc_z); 
ylabel('Linear Acceleration Z (in m/s^2 )');
xlabel('Time (in sec)'); 

% lin acc freq
figure;
subplot(3,1,1);
histogram(acc_x);
xlabel('Linear Acceleration X (in m/s^2 )');
ylabel('Frequency');

subplot(3,1,2);
histogram(acc_y); 
xlabel('Linear Acceleration Y (in m/s^2 )');
ylabel('Frequency'); 

subplot(3,1,3);
histogram(acc_z); 
xlabel('Linear Acceleration Z (in m/s^2 )');
ylabel('Frequency');

% mag field vs time
figure;
subplot(3,1,1);
plot(time, mag_x);
ylabel('Magnetic Field X');
xlabel('Time (in sec)');

subplot(3,1,2);
plot(time, mag_y); 
ylabel('Magnetic Field Y');
xlabel('Time (in sec)'); 

subplot(3,1,3);
plot(time, mag_z); 
ylabel('Magnetic Field Z');
xlabel('Time (in sec)'); 

% mag field frequency
figure;
subplot(3,1,1)
histogram(mag_x)
xlabel('Magnetic Field X');
ylabel('Frequency');

subplot(3,1,2)
histogram(mag_y)
xlabel('Magnetic Field Y');
ylabel('Frequency');

subplot(3,1,3)
histogram(mag_z)
xlabel('Magnetic Field Z');
ylabel('Frequency');