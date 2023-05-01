function [monthly_mean, max_value, min_value] = get_monthly_mean_max_min(data, time, resolution)

% get monthly data, including monthly mean and max and min value of each
% month
% provide the data observed
% time is the observation duration, longer than 1 month at least
% resolution needs to be less than 1 month to plot monthly data plots, 
% how many resolutions equal to one day

N = length(data);
L = resolution;
% duration = months(datestr(time(1)), datestr(time(end)));
duration = (year(time(end)) - year(time(1)))*12 + month(time(end)) - month(time(1)) + 1;
N_month = duration;       % how many days in the chosen period
monthly_mean = nan(1, N_month);
max_value = nan(1, N_month);
min_value = nan(1, N_month);
sub_monthly = [];
j = 1;
for i = 1 : N
    if  ((i~=1)&&(day(time(i)) == 1) && (hour(time(i)) == 0) && (minute(time(i)) == 0) && (second(time(i)) == 0)) | (i == N)  % then start a new month
        if (isnan(mean(sub_monthly)))     % if all the data in sub_daily is nan
            monthly_mean(j) = nan;
            max_value(j) = nan;
            min_value(j) = nan;
        else
            monthly_mean(j) = mean(sub_monthly);
            max_value(j) = max(sub_monthly);
            min_value(j) = min(sub_monthly);
        end
        sub_monthly = [];
        j = j + 1;
    end
    if isnan(data(i))       % ignore the nan data
        continue
    end
    sub_monthly = [sub_monthly data(i)];
end


    
