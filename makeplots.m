% Make Plots of OBS Values

%% Forest (Above)
clear
clc
close all
startup

load forest_data.mat
total_day = total_data.Day;
start_day = total_day(1); end_day = total_day(end);
start_time = start_day; end_time = end_day + hours(23) + minutes(30);
Time = start_time:minutes(30):end_time;

names = total_data.Properties.VariableNames;
for i = 1 : length(names)
    name = char(names(i));
    eval([name '= table2array(total_data(:,i));'])
    if i >= 3
        eval([name '(find(' name ' == -9999)) = nan;'])
    end
end

% Radiations
figure(1)
set(gcf,'Position',[200 400 1500 300])
grid on; hold on;
plot(Time, Rn);
title('9m Rn')
ylabel('w/m^2')

% Air Temperature
Air_Temp_20cm(find(abs(Air_Temp_20cm)> 50 | Air_Temp_20cm < -20)) = nan;
Air_Temp_1m(find(abs(Air_Temp_1m)> 50 | Air_Temp_1m < -20)) = nan;
Air_Temp_3m(find(abs(Air_Temp_3m)> 50 | Air_Temp_3m < -20)) = nan;
Air_Temp_5m(find(abs(Air_Temp_5m)> 50 | Air_Temp_5m < -20)) = nan;
Air_Temp_9m(find(abs(Air_Temp_9m)> 50 | Air_Temp_9m < -20)) = nan;

figure(2)
set(gcf,'Position',[200 400 1500 300])
subplot(1, 2, 1)
set (gca,'position',[0.1,0.18,0.45,0.75]);
hold on; grid on;
plot(Time, Air_Temp_20cm);
plot(Time, Air_Temp_1m);
plot(Time, Air_Temp_3m);
plot(Time, Air_Temp_5m);
plot(Time, Air_Temp_9m);
ylabel('^oC')
title('Air Temperature at Above Canopy Site')
subplot(1, 2, 2)
set (gca,'position',[0.6,0.18,0.2,0.75]);
hold on; grid on;
plot([mean(Air_Temp_20cm, 'omitnan'), mean(Air_Temp_1m, 'omitnan'), mean(Air_Temp_3m, 'omitnan'), mean(Air_Temp_5m, 'omitnan'), mean(Air_Temp_9m, 'omitnan')], [0.2, 1, 3, 5, 9])
plot([mean(Air_Temp_20cm, 'omitnan'), mean(Air_Temp_1m, 'omitnan'), mean(Air_Temp_3m, 'omitnan'), mean(Air_Temp_5m, 'omitnan'), mean(Air_Temp_9m, 'omitnan')], [0.2, 1, 3, 5, 9], 'o')
ylabel('Height (m)')
xlabel('Average Air Temperature (^oC)')
xlim([15 20]);

% Soil Temperature and soil heat flux
figure(3)
set(gcf,'Position',[200 400 1500 300])
subplot(1, 2, 1)
set (gca,'position',[0.1,0.18,0.45,0.75]);
hold on; grid on;
plot(Time, soil_temp_2cm);
plot(Time, soil_temp_15cm);
plot(Time, soil_temp_30cm);
plot(Time, soil_temp_40cm);
% plot(Time, soil_temp_60cm);
% plot(Time, soil_temp_80cm);
legend('2cm','15cm','30cm','40cm','60cm','80cm')
ylim([-5 35])
ylabel('^oC');
title('(a)')
subplot(1, 2, 2)
set(gca,'YDir','reverse');
set (gca,'position',[0.6,0.18,0.2,0.75]);
hold on; grid on;
plot([mean(soil_temp_2cm, 'omitnan'), mean(soil_temp_15cm, 'omitnan'), mean(soil_temp_30cm, 'omitnan'), mean(soil_temp_40cm, 'omitnan')], [0.02, 15, 30, 40])
plot([mean(soil_temp_2cm, 'omitnan'), mean(soil_temp_15cm, 'omitnan'), mean(soil_temp_30cm, 'omitnan'), mean(soil_temp_40cm, 'omitnan')], [0.02, 15, 30, 40], 'o')
xlim([16, 18])
xlabel('^oC')
ylabel('Depth (cm)')
title('(b)')


Depth = 2:0.1:40;
T_profile = nan(length(Depth), length(Time));
for i = 1 : length(Depth)
    z = Depth(i);
    if z <15
        sub_T = (z-2)/(15-2) * soil_temp_2cm + (15-z)/(15-2) * soil_temp_15cm;
    elseif z < 30
        sub_T = (z-15)/(30-15) * soil_temp_15cm + (30-z)/(30-15) * soil_temp_30cm;
    elseif z < 40
        sub_T = (z-30)/(40-30) * soil_temp_30cm + (40-z)/(40-30) * soil_temp_40cm;
    end
    T_profile(i,:) = sub_T;
end

figure(4)
set(gcf, 'position',[0, 100, 1200, 240])
imagesc(T_profile)



% RH
figure(5)
set(gcf,'Position',[200 400 1500 300])
grid on; hold on;
plot(Time, RH_20cm);
plot(Time, RH_1m);
plot(Time, RH_3m);
plot(Time, RH_5m);
plot(Time, RH_9m);
ylim([0 100])

% Theta
figure(6)
set(gcf,'Position',[200 400 1500 300])
grid on; hold on;
plot(Time, theta_2cm);
plot(Time, theta_15cm);
plot(Time, theta_30cm);
plot(Time, theta_40cm);
plot(Time, theta_60cm);
plot(Time, theta_80cm);
legend('2cm','15cm','30cm','40cm','60cm','80cm')
title('Volumetric Water Content at Above Canopy Site')

soil_heat_flux_2cm(find(abs(soil_heat_flux_2cm)>200)) = nan;
soil_heat_flux_15cm(find(abs(soil_heat_flux_15cm)>200)) = nan;
soil_heat_flux_40cm(find(abs(soil_heat_flux_40cm)>200)) = nan;
soil_heat_flux_80cm(find(abs(soil_heat_flux_80cm)>50)) = nan;
Rs_net(find(abs(Rs_net))>1500) = nan;
Rl_net(find(abs(Rl_net))>1500) = nan;



W = whos;
above = struct();
for i = 1 :length(W)
    curr = W(i).name;
    above.(curr) = eval(curr);
end

%% Below
clearvars -except above
clc

load Below_data.mat
total_day = total_data.Date;
start_day = total_day(1); end_day = total_day(end);
start_time = start_day; end_time = end_day + hours(23) + minutes(30);
Time = start_time:minutes(30):end_time;

names = total_data.Properties.VariableNames;
for i = 1 : length(names)
    if i == 2
        continue
    end
    name = char(names(i));
    eval([name '= table2array(total_data(:,i));'])
    if i >= 3
        eval([name '(find(' name ' == -9999)) = nan;'])
    end
end

% Radiation
figure(7)
set(gcf,'Position',[200 400 1500 300])
grid on; hold on;
plot(Time, Rn);

% Air Temp and RH
figure(8)
set(gcf,'Position',[200 400 1500 300])
grid on; hold on;
plot(Time, air_temp_20cm);
plot(Time, air_temp_180cm);

figure(9)
set(gcf,'Position',[200 400 1500 300])
grid on; hold on;
plot(Time, RH_20cm);
plot(Time, RH_180cm);

% G and soil surface T
Surface_G(find(abs(Surface_G)>200)) = nan;
figure(10)
set(gcf,'Position',[200 400 1500 300])
grid on; hold on;
yyaxis left
plot(Time, Surface_G);
ylabel('W/m^2')
yyaxis right
plot(Time, Surface_Soil_T);
ylabel('^oC')

% Rain
figure(11)
set(gcf,'Position',[200 400 1500 300])
grid on; hold on;
Rain_mm_30min = [];
Time_30 = [];
for i = 1 : 30: length(Rain_mm_min)-30
    Rain_mm_30min = [Rain_mm_30min, nansum(Rain_mm_min(i:i+30))];
    Time_30 = [Time_30, Time(i)];
end
plot(Time_30, Rain_mm_30min);
ylabel('mm/30min')
title('Precipitation')

Rs_net(find(abs(Rs_net))>1500) = nan;
Rl_net(find(abs(Rl_net))>1500) = nan;

W = whos;
below = struct();
for i = 1 :length(W)
    curr = W(i).name;
    below.(curr) = eval(curr);
end

%% CropLand
clearvars -except above below
clc

load CropLand_data.mat
total_day = total_data.Date;
start_day = total_day(1); end_day = total_day(end);
start_time = start_day; end_time = end_day + hours(23) + minutes(30);
Time = start_time:minutes(30):end_time;

names = total_data.Properties.VariableNames;
for i = 1 : length(names)
    if i == 2
        continue
    end
    name = char(names(i));
    eval([name '= table2array(total_data(:,i));'])
    if i >= 3
        eval([name '(find(' name ' == -9999)) = nan;'])
    end
end

% soil temperature
figure(12)
set(gcf,'Position',[200 400 1500 300])
subplot(1, 2, 1)
set (gca,'position',[0.1,0.18,0.45,0.75]);
grid on; hold on;
plot(Time, Soil_T_surface);
plot(Time, Soil_T_30cm);
plot(Time, Soil_T_50cm);
plot(Time, Soil_T_200cm);
plot(Time, Soil_T_700cm);
legend('Surface', '30cm', '50cm','200cm','700cm');
ylabel('^oC')
title('(a)')
subplot(1, 2, 2)
hold on; grid on;
set(gca,'YDir','reverse');
set (gca,'position',[0.6,0.18,0.2,0.75]);
plot([mean(Soil_T_surface, 'omitnan'), mean(Soil_T_30cm, 'omitnan'), mean(Soil_T_50cm, 'omitnan'), mean(Soil_T_200cm, 'omitnan'), mean(Soil_T_700cm, 'omitnan')], [0.02 30 50 200 700]);
plot([mean(Soil_T_surface, 'omitnan'), mean(Soil_T_30cm, 'omitnan'), mean(Soil_T_50cm, 'omitnan'), mean(Soil_T_200cm, 'omitnan'), mean(Soil_T_700cm, 'omitnan')], [0.02 30 50 200 700],'ro');
ylabel('Depth (cm)')
xlabel('^oC')
title('(b)')

% theta
figure(13)
set(gcf,'Position',[200 400 1500 300])
grid on; hold on;
plot(Time, Theta_surface);
plot(Time, Theta_30cm);
plot(Time, Theta_130cm);
plot(Time, Theta_200cm);
plot(Time, Theta_700cm);


% Rain
figure(14)
set(gcf,'Position',[200 400 1500 300])
grid on; hold on;
Rain_mm_30min = [];
Time_30 = [];
for i = 1 : 30: length(Rain_mm_Tot)-30
    Rain_mm_30min = [Rain_mm_30min, nansum(Rain_mm_Tot(i:i+30))];
    Time_30 = [Time_30, Time(i)];
end
plot(Time_30, Rain_mm_30min);
ylabel('mm/30min')
title('Precipitation')

W = whos;
cropland = struct();
for i = 1 :length(W)
    curr = W(i).name;
    cropland.(curr) = eval(curr);
end


%% AboveFlux
clearvars -except above below cropland
clc

load AboveFlux_data.mat
total_day = total_data.Date;
start_day = total_day(1); end_day = total_day(end);
start_time = start_day; end_time = end_day + hours(23) + minutes(30);
Time = start_time:minutes(30):end_time;

names = total_data.Properties.VariableNames;
for i = 1 : length(names)
    if i == 2
        continue
    end
    name = char(names(i));
    eval([name '= table2array(total_data(:,i));'])
    if i >= 3
        eval([name '(find(' name ' == -9999)) = nan;'])
    end
end


figure(15)
set(gcf,'Position',[200 400 1500 300])
grid on; hold on;
co2_flux(find(abs(co2_flux)>100)) = nan;
h2o_flux(find(abs(h2o_flux)>10)) = nan;
yyaxis left
plot(Time, co2_flux);
ylabel('CO2 flux (\mumol m^{-2} s^{-1})')
yyaxis right
plot(Time, h2o_flux);
ylabel('H2O flux mmol/(m^2s)')

figure(16)
set(gcf,'Position',[200 400 1500 300])
grid on; hold on;
plot(Time, h2o_flux);
ylabel('H2O flux mmol/(m^2s)')

figure(17)
set(gcf,'Position',[200 400 1500 300])
grid on; hold on;
H(find(abs(H)>1000)) = nan;
LE(find(abs(LE)>1000)) = nan;
plot(Time, H)
plot(Time, LE);


h2o_mole_fraction(find(abs(h2o_mole_fraction)>100)) = nan;


W = whos;
aboveflux = struct();
for i = 1 :length(W)
    curr = W(i).name;
    aboveflux.(curr) = eval(curr);
end

%% BelowFlux
clearvars -except above below cropland aboveflux
clc

load BelowFlux_data.mat
total_day = total_data.date;
start_day = total_day(1); end_day = total_day(end);
start_time = start_day; end_time = end_day + hours(23) + minutes(30);
Time = start_time:minutes(30):end_time;

names = total_data.Properties.VariableNames;
for i = 1 : length(names)
    if i == 2
        continue
    end
    name = char(names(i));
    eval([name '= table2array(total_data(:,i));'])
    if i >= 3
        eval([name '(find(' name ' == -9999)) = nan;'])
    end
end

figure(18)
set(gcf,'Position',[200 400 1500 300])
grid on; hold on;
H(find(abs(H)>1000)) = nan;
LE(find(abs(LE)>1000)) = nan;
plot(Time, H)
plot(Time, LE);


h2o_mole_fraction(find(abs(h2o_mole_fraction)>100)) = nan;
co2_flux(find(abs(co2_flux)>50)) = nan;

W = whos;
belowflux = struct();
for i = 1 :length(W)
    curr = W(i).name;
    belowflux.(curr) = eval(curr);
end

clearvars -except above below cropland aboveflux belowflux

%% Combined Plots

%% Energy enclosure at ACS and BCS

% Above
figure(19)
set(gcf,'Position',[200 100 1500 600])
subplot(1, 2, 1)
A = above.Rn - above.soil_heat_flux_2cm;
B = aboveflux.H + aboveflux.LE;
idx = [];
for i = 1 : length(A)
    if ~(isnan(A(i)) | isnan(B(i)))
        idx = [idx, i];
    end
end
P = polyfit(A(idx), B(idx), 1);
scatter(A, B)
grid on; hold on;
xlim([-500 1200]);ylim([-500 1200])
plot([-500 1200], [-500 1200], 'LineWidth',2)
% plot([-500 1200], [-500*P(1) + P(2), 1200*P(1) + P(2)], 'LineWidth',2)
ylabel('E + H (W m^{-2})')
xlabel('Rn - G (W m^{-2})')
title('(a)')
enclosure_stat_P_ACS = P;
% Below
subplot(1, 2, 2)
A = below.Rn - below.Surface_G;
B = belowflux.H + belowflux.LE;
idx = [];
for i = 1 : length(A)
    if ~(isnan(A(i)) | isnan(B(i)))
        idx = [idx, i];
    end
end
P = polyfit(A(idx), B(idx), 1);
scatter(A, B)
grid on; hold on;
xlim([-500 1200]);ylim([-500 1200])
plot([-500 1200], [-500 1200], 'LineWidth',2)
% plot([-500 1200], [-500*P(1) + P(2), 1200*P(1) + P(2)], 'LineWidth',2)
ylabel('E + H (W m^{-2})')
xlabel('Rn - G (W m^{-2})')
title('(b)')
enclosure_stat_P_BCS = P;

figure(20)
set(gcf,'Position',[200 100 1500 800])
subplot(4, 2, 1)
hold on; grid on;
plot(above.Time, above.Rn);
plot(below.Time, below.Rn);
legend('ACS','BCS')
title('(a)')
ylabel('W m^{-2}')
subplot(4, 2, 3)
hold on; grid on;
plot(above.Time, above.soil_heat_flux_2cm);
plot(below.Time, below.Surface_G);
title('(b)')
ylabel('W m^{-2}')
subplot(4, 2, 5)
hold on; grid on;
plot(aboveflux.Time, aboveflux.LE);
plot(belowflux.Time, belowflux.LE);
title('(c)')
ylabel('W m^{-2}')
subplot(4, 2, 7)
hold on; grid on;
plot(aboveflux.Time, aboveflux.H);
plot(belowflux.Time, belowflux.H);
title('(d)')
ylabel('W m^{-2}')

% figure(21)
set(gcf,'Position',[200 100 1500 800])
subplot(4, 2, 2)
hold on; grid on;
plot(above.Time, above.Rn);
plot(below.Time, below.Rn);
xlim([datetime(2019, 4, 26), datetime(2019, 5, 3)])
legend('ACS','BCS')
title('(a)')
ylabel('W m^{-2}')
subplot(4, 2, 4)
hold on; grid on;
plot(above.Time, above.soil_heat_flux_2cm);
plot(below.Time, below.Surface_G);
xlim([datetime(2019, 4, 26), datetime(2019, 5, 3)])
title('(b)')
ylabel('W m^{-2}')
subplot(4, 2, 6)
hold on; grid on;
plot(aboveflux.Time, aboveflux.LE);
plot(belowflux.Time, belowflux.LE);
xlim([datetime(2019, 4, 26), datetime(2019, 5, 3)])
title('(c)')
ylabel('W m^{-2}')
subplot(4, 2, 8)
hold on; grid on;
plot(aboveflux.Time, aboveflux.H);
plot(belowflux.Time, belowflux.H);
xlim([datetime(2019, 4, 26), datetime(2019, 5, 3)])
title('(d)')
ylabel('W m^{-2}')

% Mean of Rn, E, H, and G
mean_Rn_ACS = mean(above.Rn, 'omitnan');
mean_Rn_BCS = mean(below.Rn, 'omitnan');
mean_G_ACS = mean(above.soil_heat_flux_2cm, 'omitnan');
mean_G_BCS = mean(below.Surface_G, 'omitnan');
mean_E_ACS = mean(aboveflux.LE, 'omitnan');
mean_E_BCS = mean(belowflux.LE, 'omitnan');
mean_H_ACS = mean(aboveflux.H, 'omitnan');
mean_H_BCS = mean(belowflux.H, 'omitnan');
%% Energy Diurnal Mean

%Above
Above_Rn_diurnal_mean = get_diurnal_hourly_mean(above.Rn, above.Time, -5, 2);
Above_G_diurnal_mean = get_diurnal_hourly_mean(above.soil_heat_flux_2cm, above.Time, -5, 2);
Above_E_diurnal_mean = get_diurnal_hourly_mean(aboveflux.LE, aboveflux.Time, -5, 2);
Above_H_diurnal_mean = get_diurnal_hourly_mean(aboveflux.H, aboveflux.Time, -5, 2);
Below_Rn_diurnal_mean = get_diurnal_hourly_mean(below.Rn, below.Time, -5, 2);
Below_G_diurnal_mean = get_diurnal_hourly_mean(below.Surface_G, below.Time, -5, 2);
Below_E_diurnal_mean = get_diurnal_hourly_mean(belowflux.LE, belowflux.Time, -5, 2);
Below_H_diurnal_mean = get_diurnal_hourly_mean(belowflux.H, belowflux.Time, -5, 2);
figure(22)
subplot(4, 2, 1)
hold on; grid on
plot(0:0.5:23.5, Above_Rn_diurnal_mean,'LineWidth',1.5)
plot(0:0.5:23.5, Above_Rn_diurnal_mean,'ro')
xticks([0 3 6 9 12 15 18 21 24])
xticklabels({'0' '3' '6' '9' '12' '15' '18' '21' '24'})
title('ACS Rn')
ylabel('W m^{-2}')
subplot(4, 2, 3)
hold on; grid on
plot(0:0.5:23.5, Above_G_diurnal_mean,'LineWidth',1.5)
plot(0:0.5:23.5, Above_G_diurnal_mean,'ro')
xticks([0 3 6 9 12 15 18 21 24])
xticklabels({'0' '3' '6' '9' '12' '15' '18' '21' '24'})
title('ACS G')
ylabel('W m^{-2}')
subplot(4, 2, 5)
hold on; grid on
plot(0:0.5:23.5, Above_E_diurnal_mean,'LineWidth',1.5)
plot(0:0.5:23.5, Above_E_diurnal_mean,'ro')
xticks([0 3 6 9 12 15 18 21 24])
xticklabels({'0' '3' '6' '9' '12' '15' '18' '21' '24'})
title('ACS E')
ylabel('W m^{-2}')
subplot(4, 2, 7)
hold on; grid on
plot(0:0.5:23.5, Above_H_diurnal_mean,'LineWidth',1.5)
plot(0:0.5:23.5, Above_H_diurnal_mean,'ro')
xticks([0 3 6 9 12 15 18 21 24])
xticklabels({'0' '3' '6' '9' '12' '15' '18' '21' '24'})
title('ACS H')
ylabel('W m^{-2}')
subplot(4, 2, 2)
hold on; grid on
plot(0:0.5:23.5, Below_Rn_diurnal_mean,'LineWidth',1.5)
plot(0:0.5:23.5, Below_Rn_diurnal_mean,'ro')
xticks([0 3 6 9 12 15 18 21 24])
xticklabels({'0' '3' '6' '9' '12' '15' '18' '21' '24'})
title('BCS Rn')
ylabel('W m^{-2}')
subplot(4, 2, 4)
hold on; grid on
plot(0:0.5:23.5, Below_G_diurnal_mean,'LineWidth',1.5)
plot(0:0.5:23.5, Below_G_diurnal_mean,'ro')
xticks([0 3 6 9 12 15 18 21 24])
xticklabels({'0' '3' '6' '9' '12' '15' '18' '21' '24'})
title('BCS G')
ylabel('W m^{-2}')
subplot(4, 2, 6)
hold on; grid on
plot(0:0.5:23.5, Below_E_diurnal_mean,'LineWidth',1.5)
plot(0:0.5:23.5, Below_E_diurnal_mean,'ro')
xticks([0 3 6 9 12 15 18 21 24])
xticklabels({'0' '3' '6' '9' '12' '15' '18' '21' '24'})
title('BCS E')
ylabel('W m^{-2}')
subplot(4, 2, 8)
hold on; grid on
plot(0:0.5:23.5, Below_H_diurnal_mean,'LineWidth',1.5)
plot(0:0.5:23.5, Below_H_diurnal_mean,'ro')
xticks([0 3 6 9 12 15 18 21 24])
xticklabels({'0' '3' '6' '9' '12' '15' '18' '21' '24'})
title('BCS H')
ylabel('W m^{-2}')

%% Mass Concentration Diurnal Mean

% H2O Concentration Diurnal Mean
Above_H2O_diurnal_mean = get_diurnal_hourly_mean(aboveflux.h2o_mole_fraction, aboveflux.Time, -5, 2);
Below_H2O_diurnal_mean = get_diurnal_hourly_mean(belowflux.h2o_mole_fraction, belowflux.Time, -5, 2);
figure(23)
subplot(1, 2, 1)
hold on; grid on
plot(0:0.5:23.5, Above_H2O_diurnal_mean,'LineWidth',1.5)
plot(0:0.5:23.5, Above_H2O_diurnal_mean,'ro')
xticks([0 3 6 9 12 15 18 21 24])
xticklabels({'0' '3' '6' '9' '12' '15' '18' '21' '24'})
title('(a)')
ylabel('mmol/mol')
subplot(1, 2, 2)
hold on; grid on
plot(0:0.5:23.5, Below_H2O_diurnal_mean,'LineWidth',1.5)
plot(0:0.5:23.5, Below_H2O_diurnal_mean,'ro')
xticks([0 3 6 9 12 15 18 21 24])
xticklabels({'0' '3' '6' '9' '12' '15' '18' '21' '24'})
title('(b)')
ylabel('mmol/mol')



%% Above Fluxes and Below Fluxes Together
% Wind Speed Horizontal
figure(24)
aboveflux.wind_speed(find(abs(aboveflux.wind_speed)> 3)) = nan;
belowflux.wind_speed(find(abs(belowflux.wind_speed)> 0.55)) = nan;
set(gcf,'Position',[200 200 1500 600])
subplot(2, 1, 1)
hold on; grid on;
plot(aboveflux.Time, aboveflux.wind_speed);
plot(belowflux.Time, belowflux.wind_speed);
legend('ACS','BCS')
title('(a)')
ylabel('ms^{-1}')
subplot(2, 1, 2)
hold on; grid on;
plot(aboveflux.Time, aboveflux.wind_speed);
plot(belowflux.Time, belowflux.wind_speed);
xlim([datetime(2019, 4, 26), datetime(2019, 5, 3)])
ylabel('ms^{-1}')
title('(b)')

[yearly_mean_u_ACS] = yearly_mean(aboveflux.wind_speed, aboveflux.Time); 
[yearly_mean_u_BCS] = yearly_mean(belowflux.wind_speed, belowflux.Time); 

% Wind Speed Vertical
figure(25)
aboveflux.w_unrot(find(abs(aboveflux.w_unrot)> 1)) = nan;
belowflux.w_unrot(find(abs(belowflux.w_unrot)> 0.5)) = nan;
set(gcf,'Position',[200 200 1500 600])
subplot(2, 1, 1)
hold on; grid on;
plot(aboveflux.Time, aboveflux.w_unrot);
plot(belowflux.Time, belowflux.w_unrot);
legend('ACS','BCS')
title('(a)')
ylabel('ms^{-1}')
subplot(2, 1, 2)
hold on; grid on;
plot(aboveflux.Time, aboveflux.w_unrot);
plot(belowflux.Time, belowflux.w_unrot);
xlim([datetime(2019, 4, 26), datetime(2019, 5, 3)])
ylabel('ms^{-1}')
title('(b)')

[yearly_mean_w_ACS] = yearly_mean(aboveflux.w_unrot, aboveflux.Time); 
[yearly_mean_w_BCS] = yearly_mean(belowflux.w_unrot, belowflux.Time); 

% Sonic Temperature and H
figure(26)
aboveflux.total_data.sonic_temperature(find(abs(aboveflux.total_data.sonic_temperature)>400 | abs(aboveflux.total_data.sonic_temperature)<260)) = nan;
belowflux.total_data.sonic_temperature(find(abs(belowflux.total_data.sonic_temperature)>400 | abs(belowflux.total_data.sonic_temperature)<260)) = nan;
mean_sonic_temperature_ACS = mean(aboveflux.total_data.sonic_temperature, 'omitnan');
mean_sonic_temperature_BCS = mean(belowflux.total_data.sonic_temperature, 'omitnan');
set(gcf,'Position',[200 200 1500 600])
subplot(2, 1, 1)
hold on; grid on;
plot(aboveflux.Time, aboveflux.total_data.sonic_temperature - 273.15);
plot(belowflux.Time, belowflux.total_data.sonic_temperature - 273.15);
legend('ACS','BCS')
title('(a)')
ylabel('Sonic Temperature (^oC)')
subplot(2, 1, 2)
hold on; grid on;
plot(aboveflux.Time, aboveflux.total_data.sonic_temperature - 273.15);
plot(belowflux.Time, belowflux.total_data.sonic_temperature - 273.15);
xlim([datetime(2019, 4, 26), datetime(2019, 5, 3)])
ylabel('Sonic Temperature (^oC)')
title('(b)')

figure(27)
set(gcf,'Position',[200 200 1500 600])
subplot(2, 1, 1)
hold on; grid on;
plot(aboveflux.Time, aboveflux.H);
plot(belowflux.Time, belowflux.H);
legend('ACS','BCS')
title('(a)')
ylabel('W m^{-2}')
subplot(2, 1, 2)
hold on; grid on;
plot(aboveflux.Time, aboveflux.H);
plot(belowflux.Time, belowflux.H);
xlim([datetime(2019, 4, 26), datetime(2019, 5, 3)])
ylabel('W m^{-2}')
title('(b)')

% Water Vapor Concentration and Latent Heat Flux
figure(28)
aboveflux.h2o_mixing_ratio(find(abs(aboveflux.h2o_mixing_ratio)>80 | aboveflux.h2o_mixing_ratio<0)) = nan;
belowflux.h2o_mixing_ratio(find(abs(belowflux.h2o_mixing_ratio)>80 | belowflux.h2o_mixing_ratio<0)) = nan;
set(gcf,'Position',[200 200 1500 600])
subplot(2, 1, 1)
hold on; grid on;
plot(aboveflux.Time, aboveflux.h2o_mixing_ratio);
plot(belowflux.Time, belowflux.h2o_mixing_ratio);
legend('ACS','BCS')
title('(a)')
ylabel('mmol mol^{-1}')
subplot(2, 1, 2)
hold on; grid on;
plot(aboveflux.Time, aboveflux.h2o_mixing_ratio);
plot(belowflux.Time, belowflux.h2o_mixing_ratio);
xlim([datetime(2019, 4, 26), datetime(2019, 5, 3)])
ylabel('mmol mol^{-1}')
title('(b)')

figure(29)
set(gcf,'Position',[200 200 1500 600])
subplot(2, 1, 1)
hold on; grid on;
plot(aboveflux.Time, aboveflux.LE);
plot(belowflux.Time, belowflux.LE);
legend('ACS','BCS')
title('(a)')
ylabel('W m^{-2}')
subplot(2, 1, 2)
hold on; grid on;
plot(aboveflux.Time, aboveflux.LE);
plot(belowflux.Time, belowflux.LE);
xlim([datetime(2019, 4, 26), datetime(2019, 5, 3)])
ylabel('W m^{-2}')
title('(b)')

% CO2 concentrations and CO2 Fluxes of ACS and BCS
figure(30)
aboveflux.co2_mixing_ratio(find(abs(aboveflux.co2_mixing_ratio)> 1000 | aboveflux.co2_mixing_ratio<300)) = nan;
belowflux.co2_mixing_ratio(find(abs(belowflux.co2_mixing_ratio)> 1000 | belowflux.co2_mixing_ratio<300)) = nan;
set(gcf,'Position',[200 200 1500 600])
subplot(2, 1, 1)
hold on; grid on;
plot(aboveflux.Time, aboveflux.co2_mixing_ratio);
plot(belowflux.Time, belowflux.co2_mixing_ratio);
legend('ACS','BCS')
title('(a)')
ylabel('ppm')
subplot(2, 1, 2)
hold on; grid on;
plot(aboveflux.Time, aboveflux.co2_mixing_ratio);
plot(belowflux.Time, belowflux.co2_mixing_ratio);
xlim([datetime(2019, 4, 26), datetime(2019, 5, 3)])
ylabel('ppm')
title('(b)')

figure(31)
set(gcf,'Position',[200 200 1500 600])
subplot(2, 1, 1)
hold on; grid on;
plot(aboveflux.Time, aboveflux.co2_flux);
plot(belowflux.Time, belowflux.co2_flux);
legend('ACS','BCS')
title('(a)')
ylabel('(\mumol m^{-2} s^{-1})')
subplot(2, 1, 2)
hold on; grid on;
plot(aboveflux.Time, aboveflux.co2_flux);
plot(belowflux.Time, belowflux.co2_flux);
xlim([datetime(2019, 4, 26), datetime(2019, 5, 3)])
ylabel('(\mumol m^{-2} s^{-1})')
title('(b)')

mean_CO2_ACS = mean(aboveflux.co2_mixing_ratio, 'omitnan');
mean_CO2_BCS = mean(belowflux.co2_mixing_ratio, 'omitnan');

yearly_mean_E_ACS = yearly_mean(aboveflux.LE, aboveflux.Time);
yearly_mean_E_BCS = yearly_mean(belowflux.LE, belowflux.Time);
yearly_mean_H_ACS = yearly_mean(aboveflux.H, aboveflux.Time);
yearly_mean_H_BCS = yearly_mean(belowflux.H, belowflux.Time);

% Precipitation, Water Content at ACS and CLS
figure(32)
set(gcf,'Position',[200 200 1500 600])
subplot(2, 1, 1)
hold on; grid on;
yyaxis left
mean_theta_2cm_ACS = mean(above.theta_2cm, 'omitnan');
mean_theta_15cm_ACS = mean(above.theta_15cm, 'omitnan');
mean_theta_30cm_ACS = mean(above.theta_30cm, 'omitnan');
mean_theta_40cm_ACS = mean(above.theta_40cm, 'omitnan');
mean_theta_60cm_ACS = mean(above.theta_60cm, 'omitnan');
mean_theta_80cm_ACS = mean(above.theta_80cm, 'omitnan');
plot(above.Time, above.theta_2cm, 'Color','#00BCD4','LineStyle','-');
plot(above.Time, above.theta_15cm, 'Color','#F06292','LineStyle','-');
plot(above.Time, above.theta_30cm, 'Color','#4CAF50','LineStyle','-');
plot(above.Time, above.theta_40cm, 'Color','#F9A825','LineStyle','-');
plot(above.Time, above.theta_60cm, '-', 'Color','b');
plot(above.Time, above.theta_80cm, '-', 'Color','#E53935');
ylabel('Volumetric Water Content (m^3 m^{-3})')
yyaxis right
plot(below.Time_30, below.Rain_mm_30min, 'k');
xlim([datetime(2018, 1, 1), datetime(2021, 1, 1)])
ylabel('Precipitation (mm)')
legend('2cm', '15cm','30cm','40cm','60cm','80cm','Rain')
set(gca, 'YDir','reverse')
title('(a)')
subplot(2, 1, 2)
hold on; grid on;
yyaxis left
mean_theta_surface_CLS = mean(cropland.Theta_surface, 'omitnan');
mean_theta_30cm_CLS = mean(cropland.Theta_30cm, 'omitnan');
mean_theta_130cm_CLS = mean(cropland.Theta_130cm, 'omitnan');
mean_theta_200cm_CLS = mean(cropland.Theta_200cm, 'omitnan');
plot(cropland.Time, cropland.Theta_surface, 'Color','#00BCD4','LineStyle','-');
plot(cropland.Time, cropland.Theta_30cm, 'Color','#F06292','LineStyle','-');
plot(cropland.Time, cropland.Theta_130cm, 'Color','#F9A825','LineStyle','-');
plot(cropland.Time, cropland.Theta_200cm, 'Color','b','LineStyle','-');
% plot(cropland.Time, cropland.Theta_700cm, 'Color','#E53935','LineStyle','-');
ylabel('Volumetric Water Content (m^3 m^{-3})')
yyaxis right
plot(cropland.Time_30, cropland.Rain_mm_30min, 'k');
xlim([datetime(2018, 1, 1), datetime(2021, 1, 1)])
set(gca, 'YDir','reverse')
ylabel('Precipitation (mm)')
legend('Surface','30cm','130cm','200cm','Rain')
title('(b)')

figure(33)
set(gcf,'Position',[200 200 1500 600])
subplot(2, 1, 1)
hold on; grid on;
plot(above.Time, above.soil_heat_flux_2cm);
plot(above.Time, above.soil_heat_flux_15cm);
plot(above.Time, above.soil_heat_flux_40cm);
plot(above.Time, above.soil_heat_flux_80cm);
plot(below.Time, below.Surface_G);
legend('ACS 2cm', 'ACS 15cm', 'ACS 40cm', 'ACS 80cm', 'BCS Surface');
ylabel('W m^{-2}')
ylim([-125 200])
title('(a)')
subplot(2, 1, 2)
hold on; grid on;
plot(above.Time, above.soil_heat_flux_2cm);
plot(above.Time, above.soil_heat_flux_15cm);
plot(above.Time, above.soil_heat_flux_40cm);
plot(above.Time, above.soil_heat_flux_80cm);
plot(below.Time, below.Surface_G);
ylabel('W m^{-2}')
ylim([-50 125])
xlim([datetime(2019, 4, 26), datetime(2019, 5, 3)])
title('(b)')



figure(34)
set(gcf,'Position',[200 200 1500 600])
subplot(2, 1, 1)
hold on; grid on;
plot(above.Time, above.Rn);
plot(below.Time, below.Rn);
legend('ACS','BCS')
title('(a)')
ylabel('W m^{-2}')
ylim([-50 1200])
subplot(2, 1, 2)
hold on; grid on;
plot(above.Time, above.Rn);
plot(below.Time, below.Rn);
xlim([datetime(2019, 4, 26), datetime(2019, 5, 3)])
title('(b)')
ylabel('W m^{-2}')

figure(35)
set(gcf,'Position',[200 200 1500 600])
subplot(2, 1, 1)
hold on; grid on;
plot(above.Time, above.short_up - above.short_down);
plot(below.Time, below.short_up - below.short_down);
legend('ACS','BCS')
title('(a)')
ylabel('W m^{-2}')
ylim([-50 1200])
subplot(2, 1, 2)
hold on; grid on;
plot(above.Time, above.short_up - above.short_down);
plot(below.Time, below.short_up - below.short_down);
xlim([datetime(2019, 4, 26), datetime(2019, 5, 3)])
title('(b)')
ylabel('W m^{-2}')

figure(36)
set(gcf,'Position',[200 200 1500 600])
subplot(2, 1, 1)
hold on; grid on;
plot(above.Time, above.long_up - above.long_dn);
plot(below.Time, below.long_up - below.long_dn);
legend('ACS','BCS')
title('(a)')
ylabel('W m^{-2}')
ylim([-150 30])
subplot(2, 1, 2)
hold on; grid on;
plot(above.Time, above.long_up - above.long_dn);
plot(below.Time, below.long_up - below.long_dn);
xlim([datetime(2019, 4, 26), datetime(2019, 5, 3)])
title('(b)')
ylabel('W m^{-2}')

mean_RnS_ACS = mean(above.short_up - above.short_down, 'omitnan');
mean_Rs_down_ACS = mean(above.short_down, 'omitnan');
mean_Rs_up_ACS = mean(above.short_up, 'omitnan');
mean_RnS_BCS = mean(below.short_up - below.short_down, 'omitnan');
mean_Rs_down_BCS = mean(below.short_down, 'omitnan');
mean_Rs_up_BCS = mean(below.short_up, 'omitnan');
mean_RnL_ACS = mean_Rn_ACS - mean_RnS_ACS;
mean_RnL_BCS = mean_Rn_BCS - mean_RnS_BCS;

CO2_flux_diurnal_mean_ACS = get_diurnal_hourly_mean(aboveflux.co2_flux, aboveflux.Time, -5, 2);
CO2_flux_diurnal_mean_BCS = get_diurnal_hourly_mean(belowflux.co2_flux, belowflux.Time, -5, 2);

figure(37)
set(gcf,'Position',[200 200 1500 500])
hold on; grid on;
yyaxis left
plot(0:0.5:23.5, CO2_flux_diurnal_mean_ACS,'LineWidth',2)
ylabel('(\mumol m^{-2} s^{-1})')
yyaxis right
plot(0:0.5:23.5, CO2_flux_diurnal_mean_BCS,'LineWidth',2)
xticks([0 3 6 9 12 15 18 21 24])
xticklabels({'0' '3' '6' '9' '12' '15' '18' '21' '24'})
ylabel('(\mumol m^{-2} s^{-1})')
legend('ACS','BCS')

figure(38)
set(gcf,'Position',[200 200 1500 500])
subplot(2, 1, 1)
hold on; grid on;
plot(aboveflux.Time, aboveflux.co2_mixing_ratio);
plot(belowflux.Time, belowflux.co2_mixing_ratio);
xlim([datetime(2019, 4, 26), datetime(2019, 5, 3)])
ylabel('ppm')
subplot(2, 1, 2)
hold on; grid on;
plot(aboveflux.Time, aboveflux.co2_flux);
plot(belowflux.Time, belowflux.co2_flux);
xlim([datetime(2019, 4, 26), datetime(2019, 5, 3)])
ylabel('(\mumol m^{-2} s^{-1})')


CO2_diurnal_mean_ACS = get_diurnal_hourly_mean(aboveflux.co2_mixing_ratio, aboveflux.Time, -5, 2);
CO2_diurnal_mean_BCS = get_diurnal_hourly_mean(belowflux.co2_mixing_ratio, belowflux.Time, -5, 2);
figure
set(gcf,'Position',[200 200 800 600])
hold on; grid on;
for i = 1 : 2: 47
    sub_CO2_ACS = mean(CO2_diurnal_mean_ACS(i:i+1));
    sub_CO2_BCS = mean(CO2_diurnal_mean_BCS(i:i+1));
    sub_time = (i-1)/2;
    if sub_time < 6 || sub_time >= 16
        y1 = scatter(sub_CO2_ACS, sub_CO2_BCS, 'bo');
        text(sub_CO2_ACS+2, sub_CO2_BCS+2, strcat('(',num2str(sub_time),')'), 'FontSize',12)
    else
        y2 = scatter(sub_CO2_ACS, sub_CO2_BCS, 'ro');
        text(sub_CO2_ACS+2, sub_CO2_BCS-2, strcat('(',num2str(sub_time),')'), 'FontSize',12)
    end
end
legend([y1 y2],{'night time','day time'})
ylabel('BCS CO_2 Concentration (ppm)');
xlabel('ACS CO_2 Concentration (ppm)');


%% night and day time difference analysis
night_index = intersect(find(above.Rn < 40),  find(above.Rn ~= NaN));
day_index = intersect(find(above.Rn >= 40), find(above.Rn ~= NaN));

% night and day time energy enclosure
% day time
figure
set(gcf,'Position',[200 100 1500 600])
subplot(1, 2, 1)
A = above.Rn(day_index) - above.soil_heat_flux_2cm(day_index);
B = aboveflux.H(day_index) + aboveflux.LE(day_index);
idx = [];
for i = 1 : length(A)
    if ~(isnan(A(i)) | isnan(B(i)))
        idx = [idx, i];
    end
end
P = polyfit(A(idx), B(idx), 1);
scatter(A, B)
grid on; hold on;
xlim([-500 1200]);ylim([-500 1200])
plot([-500 1200], [-500 1200], 'LineWidth',2)
% plot([-500 1200], [-500*P(1) + P(2), 1200*P(1) + P(2)], 'LineWidth',2)
ylabel('E + H (W m^{-2})')
xlabel('Rn - G (W m^{-2})')
title('(a)')
enclosure_stat_P_ACS_daytime = P;
% Below
subplot(1, 2, 2)
A = below.Rn(day_index) - below.Surface_G(day_index);
B = belowflux.H(day_index) + belowflux.LE(day_index);
idx = [];
for i = 1 : length(A)
    if ~(isnan(A(i)) | isnan(B(i)))
        idx = [idx, i];
    end
end
P = polyfit(A(idx), B(idx), 1);
scatter(A, B)
grid on; hold on;
xlim([-100 500]);ylim([-100 500])
plot([-500 1200], [-500 1200], 'LineWidth',2)
% plot([-500 1200], [-500*P(1) + P(2), 1200*P(1) + P(2)], 'LineWidth',2)
ylabel('E + H (W m^{-2})')
xlabel('Rn - G (W m^{-2})')
title('(b)')
enclosure_stat_P_BCS_daytime = P;

% night time
figure
set(gcf,'Position',[200 100 1500 600])
subplot(1, 2, 1)
A = above.Rn(night_index) - above.soil_heat_flux_2cm(night_index);
B = aboveflux.H(night_index) + aboveflux.LE(night_index);
idx = [];
for i = 1 : length(A)
    if ~(isnan(A(i)) | isnan(B(i)))
        idx = [idx, i];
    end
end
P = polyfit(A(idx), B(idx), 1);
scatter(A, B)
grid on; hold on;
xlim([-500 500]);ylim([-500 500])
plot([-500 1200], [-500 1200], 'LineWidth',2)
% plot([-500 1200], [-500*P(1) + P(2), 1200*P(1) + P(2)], 'LineWidth',2)
ylabel('E + H (W m^{-2})')
xlabel('Rn - G (W m^{-2})')
title('(a)')
enclosure_stat_P_ACS_nighttime = P;
% Below
subplot(1, 2, 2)
A = below.Rn(night_index) - below.Surface_G(night_index);
B = belowflux.H(night_index) + belowflux.LE(night_index);
idx = [];
for i = 1 : length(A)
    if ~(isnan(A(i)) | isnan(B(i)))
        idx = [idx, i];
    end
end
P = polyfit(A(idx), B(idx), 1);
scatter(A, B)
grid on; hold on;
xlim([-100 500]);ylim([-100 500])
plot([-500 1200], [-500 1200], 'LineWidth',2)
% plot([-500 1200], [-500*P(1) + P(2), 1200*P(1) + P(2)], 'LineWidth',2)
ylabel('E + H (W m^{-2})')
xlabel('Rn - G (W m^{-2})')
title('(b)')
enclosure_stat_P_BCS_nighttime = P;

% energy enclosure diurnal mean values
figure
set(gcf,'Position',[200 100 1500 600])
subplot(1, 2, 1)
hold on; grid on;
disclosure_ACS = above.Rn - above.soil_heat_flux_2cm - aboveflux.H - aboveflux.LE;
disclosure_ACS_diurnal_mean_relativeerror = get_diurnal_hourly_mean(disclosure_ACS, above.Time, -5, 2)./Above_Rn_diurnal_mean;
yyaxis left
plot(0:0.5:23.5, disclosure_ACS_diurnal_mean_relativeerror.*100)
ylabel('%')
ylim([-100 100])
yyaxis right
plot(0:0.5:23.5, disclosure_ACS_diurnal_mean_relativeerror.*Above_Rn_diurnal_mean,'mo--')
plot(0:0.5:23.5, Above_Rn_diurnal_mean,'o-')
ylabel('W m^{-2}')
legend('(R_n - G - E - H)/R_n','(R_n - G - E - H)', 'R_n')
xticks([0 3 6 9 12 15 18 21 24])
xticklabels({'0' '3' '6' '9' '12' '15' '18' '21' '24'})
subplot(1, 2, 2)
hold on; grid on;
disclosure_BCS = below.Rn - below.Surface_G - belowflux.H - belowflux.LE;
disclosure_BCS_diurnal_mean_relativeerror = get_diurnal_hourly_mean(disclosure_BCS, below.Time, -5, 2)./Below_Rn_diurnal_mean;
yyaxis left
plot(0:0.5:23.5, disclosure_BCS_diurnal_mean_relativeerror.*100)
ylabel('%')
ylim([-100 100])
yyaxis right
plot(0:0.5:23.5, disclosure_BCS_diurnal_mean_relativeerror.*Below_Rn_diurnal_mean,'mo--')
plot(0:0.5:23.5, Below_Rn_diurnal_mean,'o-')
ylabel('W m^{-2}')
xticks([0 3 6 9 12 15 18 21 24])
xticklabels({'0' '3' '6' '9' '12' '15' '18' '21' '24'})



% Mean vertical wind speed during daytime
mean_W_ACS_daytime = mean(aboveflux.w_unrot(day_index), 'omitnan');
mean_W_BCS_daytime = mean(belowflux.w_unrot(day_index), 'omitnan');
mean_W_ACS_nighttime = mean(aboveflux.w_unrot(night_index), 'omitnan');
mean_W_BCS_nighttime = mean(belowflux.w_unrot(night_index), 'omitnan');


% % Power Spectrum 
% [pxx,f] = plomb(total_EC_processed.LE,Time_EC_processed,[],10,'power');
% f = f*86400;
% [pk,f0] = findpeaks(pxx,f,'MinPeakHeight',10);
% figure
% set(gcf,'Position',[200 100 1500 250])
% plot(f,pxx,f0,pk,'o')
% xlabel('Frequency (day^{-1})')
% title('Power Spectrum and Prominent Peak of E')
% hold on; grid on
% xlim([0.5 5])


% Forest albedo
albedo_ACS = above.short_up./above.short_down; albedo_ACS = 1./albedo_ACS;
albedo_BCS = below.short_up./below.short_down; albedo_BCS = 1./albedo_BCS;

albedo_ACS(find(albedo_ACS> 1 | albedo_ACS <0)) = nan;
albedo_BCS(find(albedo_BCS> 1 | albedo_BCS <0)) = nan;

albedo_ACS_diurnal_mean = get_diurnal_hourly_mean(albedo_ACS, above.Time, -5, 2);
albedo_BCS_diurnal_mean = get_diurnal_hourly_mean(albedo_BCS, above.Time, -5, 2);
figure
set(gcf,'Position',[200 100 1500 600])
hold on; grid on;
plot(0:0.5:23.5, albedo_ACS_diurnal_mean)
plot(0:0.5:23.5, albedo_BCS_diurnal_mean)
ylim([0 1])


% Pie plot of energy budget 
figure
subplot(1, 2, 1)
p = pie([mean_E_ACS, mean_H_ACS, mean_G_ACS],[true true true]);
colormap([1 0 0; 0 1 0; 0 0 1])
pText = findobj(p,'Type','text');
percentValues = get(pText,'String'); 
txt = {'E: ';'H: ';'G: '}; 
combinedtxt = strcat(txt,percentValues); 
pText(1).String = combinedtxt(1);
pText(2).String = combinedtxt(2);
pText(3).String = combinedtxt(3);
subplot(1, 2, 2)
p = pie([mean_E_BCS, mean_H_BCS, abs(mean_G_BCS)],[true true true]);
colormap([1 0 0; 0 1 0; 0 0 1])
pText = findobj(p,'Type','text');
percentValues = get(pText,'String'); 
txt = {'E: ';'H: ';'G: '}; 
combinedtxt = strcat(txt,percentValues); 
pText(1).String = combinedtxt(1);
pText(2).String = combinedtxt(2);
pText(3).String = combinedtxt(3);

save CCZO_OBS.mat