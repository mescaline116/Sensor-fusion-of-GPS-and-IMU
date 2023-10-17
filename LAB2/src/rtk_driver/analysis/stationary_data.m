data = readmatrix('stationary_data.csv');

% Extract columns 
time = (data(:,3)/10e8);
time = time-time(1);
lat = data(:,5); 
lon = data(:,6);
seq=data(:,2);
quality=data(:,8);
utm_northing = data(:,10);
utm_northing = utm_northing - min(utm_northing);
utm_easting = data(:,9);
utm_easting = utm_easting - min(utm_easting);

% Plot raw data
figure;
subplot(2,1,1);
plot(time, lat);
ylabel('Latitude ');
xlabel('Time (in secs)');

subplot(2,1,2);
plot(time, lon); 
ylabel('Longitude');
xlabel('Time (in secs)'); 

% east north utm ing
figure;
plot(utm_easting, utm_northing);
xlabel('utm_easting (in m)');
ylabel('utm_northing (in m)');

figure;
plot(lon, lat);
xlabel('longitude');
ylabel('latitude');

%scatter plot
figure;
scatter(utm_easting,utm_northing);
xlabel('utm_easting (in m)');
ylabel('utm_northing (in m)');
% multipath error
%scatter(lon,lat);
%z=std(lon)
%plot(time,lon);

figure;
histogram(utm_easting);

%m=median(utm_easting,"all")
%error=(utm_easting-m)/10^(-3);
%figure;
%histogram(error);
%xlabel('deviation (in mm)');
%ylabel('data points');



m=median(utm_easting,"all")
error=(utm_easting-m)*1000;
figure;
histogram(error)
xlabel('deviation (in mm)');
ylabel('data points');

%northing histo
w=median(utm_northing,"all")
err=(utm_northing-w)*1000;
figure;
histogram(err)
xlabel('deviation (in mm)');
ylabel('data points');

%2d hist
figure;
hist3([error,err])
xlabel('utm easting deviation (in mm)');
ylabel('utm northing deviation (in mm)');
zlabel('frequency');




s=std(utm_easting)



figure;
plot(time, quality)
xlabel('time (in secs)');
ylabel('fix quality');