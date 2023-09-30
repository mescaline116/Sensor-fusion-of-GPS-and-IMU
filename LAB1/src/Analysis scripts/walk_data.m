% Load data from CSV 
data = readmatrix('walking__data.csv');

% Extract columns 
time = data(:,1);
time = time-data(1,1);
lat = data(:,5); 
lon = data(:,6);
utm_northing = data(:,9);
utm_northing = utm_northing - min(utm_northing);
utm_easting = data(:,8);
utm_easting = utm_easting - min(utm_easting);

% Plot raw data
figure;
subplot(2,1,1);
plot(time, lat);
ylabel('Latitude');
xlabel('Time');

subplot(2,1,2);
plot(time, lon); 
ylabel('Longitude');
xlabel('Time'); 

% east north utm ing
figure;
plot(utm_easting, utm_northing);
xlabel('utm_easting');
ylabel('utm_northing');

figure;
plot(lon, lat);
xlabel('longitude');
ylabel('latitude');

%scatter plot
figure;
scatter(utm_easting,utm_northing);
xlabel('utm_easting');
ylabel('utm_northing');
% multipath error
histogram(lat)