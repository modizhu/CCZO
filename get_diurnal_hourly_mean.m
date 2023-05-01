function [diurnal_hourly_mean] = get_diurnal_hourly_mean(data, time, time_difference, resolution)

% get diurnal hourly mean data
% provide the data observed
% time is the observation duration, must be consistent with data
% diurnal_hourly_mean is the aim result, with 1*24 matrix, diurnal hourly
% mean
% time_difference is the difference between the measured time to EST time,
% 0 represents EST, for example, British time, corresponding
% time_difference input is -5
% resolution represents how detailed output you want (how many points each hour), for example, half hour use resolution = 2

N = length(data);
N_hour = 24 * resolution;       % how many days in the chosen period
diurnal_hourly_mean = zeros(1, N_hour);
count = zeros(1, N_hour);
for i = 1 : N
    if ~isnan(data(i))
        hr = hour(time(i));
        mm = minute(time(i));
        mm = floor(mm/(60/resolution));
        j = hr * resolution;
        if hr == 0
            j = 24 * resolution;
        end
        j = mod(j + time_difference * resolution + 24*resolution,24 * resolution);
        j = j + 1 + mm;
        diurnal_hourly_mean(j) = diurnal_hourly_mean(j) + data(i);
        count(j) = count(j) + 1;
    end
end

diurnal_hourly_mean = diurnal_hourly_mean./count;

    
