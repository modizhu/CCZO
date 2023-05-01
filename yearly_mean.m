% Get yearly mean for the given data
function [yearly_mean, Year] = yearly_mean(data, time)
% data and time must have same length, time indicating the measured time
% must make sure data is processed, filtered the bad data out

yearly_mean = [];

year_start = year(time(1)); year_end = year(time(end));
Year = year_start:year_end;

for i = 1 : length(Year)
    eval(strcat('data_', num2str(Year(i)), '= [];'));
end

for i = 1 : length(time)
    curr_year = year(time(i));
    eval(strcat('data_', num2str(curr_year), '= ', '[data_', num2str(curr_year), ', ', num2str(data(i)),'];'));
end

for i = 1 : length(Year)
    eval(strcat('mean_', num2str(Year(i)), '= ', 'mean(data_', num2str(Year(i)), ", 'omitnan');"));
    eval(strcat('yearly_mean = [yearly_mean,', ' mean_', num2str(Year(i)), '];' ));
end




