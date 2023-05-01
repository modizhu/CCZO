%% Models and Simulations
clear
clc
close all

data1 = load('forest_data.mat'); data1 = data1.total_data;
data2 = load('AboveFlux_data.mat'); data2 = data2.total_data;
data3 = load('Below_data.mat'); data3 = data3.total_data;
data4 = load('BelowFlux_data.mat'); data4 = data4.total_data;
data5 = load('CropLand_data.mat'); data5 = data5.total_data;

Time1 = datetime(2016, 8, 31, 0, 0, 0):minutes(30):datetime(2020, 12, 31, 23, 30, 0);
Time2 = datetime(2017, 1, 1, 0, 0, 0):minutes(30):datetime(2020, 12, 31, 23, 30, 0);

%% MEP and z
Cp = 1000;
Rv = 461;
rou = 1.18;
k = 0.4;
T0 = 273.15;
g = 9.8;
% Is = 800;

ratio = 1;
type = 0;

%% Above Canopy Site
TA = data1.Air_Temp_20cm; TA(find(abs(TA)> 100)) = nan;
RH = data1.RH_20cm/100;   RH(find(abs(RH)> 1)) = nan;
Rn_AC = data1.Rn;   Rn_AC(find(abs(Rn_AC)> 1300)) = nan;
H_AC = data2.H; H_AC(find(abs(H_AC)> 500)) = nan;
E_AC = data2.LE; E_AC(find(abs(E_AC)> 1300 | E_AC< -200)) = nan;
G_AC = data1.soil_heat_flux_2cm; G_AC(find(abs(G_AC)> 1300)) = nan;
T_s = data1.soil_temp_2cm;
% Model of Is: delta_G = Is*delta_T*sqrt(w0)
Is = [];
for i = 1 : 48 :length(T_s)-48
    sub_Is = (max(G_AC(i:i+48)) - min(G_AC(i:i+48)))/(max(T_s(i:i+48)) - min(T_s(i:i+48)));
    w0 = 2*pi/86400;
    sub_Is = sub_Is/sqrt(w0);
    Is = [Is, sub_Is];
end
Is(find(Is> 1500 |Is<500))=nan;
Is = mean(Is,'omitnan');

qs = Qs(TA, RH);

z = nan(1, length(Rn_AC));
EMEP_AC = []; HMEP_AC = []; GMEP_AC = [];
for i = 1 : length(Rn_AC)
    curr_month = month(Time1(i));
    if curr_month >= 2 && curr_month < 5
        NDVI = 0.5;
    elseif curr_month >= 5 && curr_month < 9
        NDVI = 0.8;
    elseif curr_month >= 9 && curr_month < 12
        NDVI = 0.5;
    elseif curr_month >= 12 || curr_month < 2
        NDVI = 0.2;
    end
    z(i) = 15 / NDVI * abs((TA(i)+273)/abs(Rn_AC(i)));
    if isnan(z(i)) || z(i) == 0
        z(i) = 9;
    end
    [emep, hmep, gmep, I0] = F_MEP_EHG(Rn_AC(i), TA(i), qs(i), Is, z(i), ratio, type);
    EMEP_AC = [EMEP_AC, emep];
    HMEP_AC = [HMEP_AC, hmep];
    GMEP_AC = [GMEP_AC, gmep];
end

figure
grid on; hold on
plot(Time1, EMEP_AC);
plot(Time1, HMEP_AC);
plot(Time1, GMEP_AC);
ylim([-50 400])

figure
set(gcf,'Position',[100 100 1200 800])
subplot(3, 2, 1)
set(gca, 'Units', 'normalized', 'Position', [0.1 0.7 0.45 0.25])
hold on; grid on;
plot(Time1, EMEP_AC);
plot(Time1, E_AC);
% title('E')
legend('MEP','OBS')
ylabel('E (W m^{-2})')
ylim([-50 900])
xticklabels({})
subplot(3, 2, 2)
A = E_AC;
B = EMEP_AC';
idx = [];
for i = 1 : length(A)
    if ~(isnan(A(i)) | isnan(B(i)))
        idx = [idx, i];
    end
end
P = polyfit(A(idx), B(idx), 1);
r_2 = corrcoef(A(idx),B(idx)); r_2 = r_2(1,2);
RMSE = sqrt(mean((A(idx) - B(idx)).^2));
NRMSE = goodnessOfFit(A(idx),B(idx),'NRMSE');
set(gca, 'Units', 'normalized', 'Position', [0.7 0.7 0.25 0.25])
hold on; grid on;
scatter(E_AC, EMEP_AC)
plot([-500 1200], [-500 1200], 'LineWidth',2)
% plot([-500 1200], [-500*P(1) + P(2), 1200*P(1) + P(2)], 'LineWidth',2)
ylim([-200 800])
xlim([-200 800])
% text(0.7, 0.15, strcat('k =', num2str(P(1), '%0.3f')), 'Units', 'normalized', 'HorizontalAlignment', 'center')
% text(0.7, 0.05, strcat('b =', num2str(P(2), '%0.3f')), 'Units', 'normalized', 'HorizontalAlignment', 'center')
% text(0.7, 0.25, strcat('RMSE =', num2str(RMSE, '%0.3f')), 'Units', 'normalized', 'HorizontalAlignment', 'center')
% text(0.7, 0.35, strcat('r2 =', num2str(r_2, '%0.3f')), 'Units', 'normalized', 'HorizontalAlignment', 'center')
% text(0.7, 0.45, strcat('NRMSE =', num2str(NRMSE, '%0.3f')), 'Units', 'normalized', 'HorizontalAlignment', 'center')
% text(0.7, 0.55, strcat('r =', num2str(sqrt(r_2), '%0.3f')), 'Units', 'normalized', 'HorizontalAlignment', 'center')

subplot(3, 2, 3)
set(gca, 'Units', 'normalized', 'Position', [0.1 0.4 0.45 0.25])
hold on; grid on;
plot(Time1, HMEP_AC);
plot(Time1, H_AC);
% title('H')
% legend('MEP','OBS')
ylabel('H (W m^{-2})')
ylim([-50 600])
xticklabels({})
subplot(3, 2, 4)
A = H_AC;
B = HMEP_AC';
idx = [];
for i = 1 : length(A)
    if ~(isnan(A(i)) | isnan(B(i)))
        idx = [idx, i];
    end
end
P = polyfit(A(idx), B(idx), 1);
r_2 = corrcoef(A(idx),B(idx)); r_2 = r_2(1,2);
RMSE = sqrt(mean((A(idx) - B(idx)).^2));
NRMSE = goodnessOfFit(A(idx),B(idx),'NRMSE');
set(gca, 'Units', 'normalized', 'Position', [0.7 0.4 0.25 0.25])
hold on; grid on;
scatter(H_AC, HMEP_AC)
plot([-500 1200], [-500 1200], 'LineWidth',2)
% plot([-500 1200], [-500*P(1) + P(2), 1200*P(1) + P(2)], 'LineWidth',2)
ylim([-200 800])
xlim([-200 800])
ylabel('MEP (W m^{-2})')
% text(0.7, 0.15, strcat('k =', num2str(P(1), '%0.3f')), 'Units', 'normalized', 'HorizontalAlignment', 'center')
% text(0.7, 0.05, strcat('b =', num2str(P(2), '%0.3f')), 'Units', 'normalized', 'HorizontalAlignment', 'center')
% text(0.7, 0.25, strcat('RMSE =', num2str(RMSE, '%0.3f')), 'Units', 'normalized', 'HorizontalAlignment', 'center')
% text(0.7, 0.35, strcat('r2 =', num2str(r_2, '%0.3f')), 'Units', 'normalized', 'HorizontalAlignment', 'center')
% text(0.7, 0.45, strcat('NRMSE =', num2str(NRMSE, '%0.3f')), 'Units', 'normalized', 'HorizontalAlignment', 'center')
% text(0.7, 0.55, strcat('r =', num2str(sqrt(r_2), '%0.3f')), 'Units', 'normalized', 'HorizontalAlignment', 'center')

subplot(3, 2, 5)
set(gca, 'Units', 'normalized', 'Position', [0.1 0.1 0.45 0.25])
hold on; grid on;
plot(Time1, GMEP_AC);
plot(Time1, G_AC);
% title('G')
ylabel('G (W m^{-2})')
% legend('MEP','OBS')
% xticklabels({})
ylim([-50 250])
subplot(3, 2, 6)
A = G_AC;
B = GMEP_AC';
idx = [];
for i = 1 : length(A)
    if ~(isnan(A(i)) | isnan(B(i)))
        idx = [idx, i];
    end
end
P = polyfit(A(idx), B(idx), 1);
r_2 = corrcoef(A(idx),B(idx)); r_2 = r_2(1,2);
RMSE = sqrt(mean((A(idx) - B(idx)).^2));
NRMSE = goodnessOfFit(A(idx),B(idx),'NRMSE');
set(gca, 'Units', 'normalized', 'Position', [0.7 0.1 0.25 0.25])
hold on; grid on;
scatter(G_AC, GMEP_AC)
plot([-500 1200], [-500 1200], 'LineWidth',2)
% plot([-500 1200], [-500*P(1) + P(2), 1200*P(1) + P(2)], 'LineWidth',2)
ylim([-100 200])
xlim([-100 200])
xlabel('OBS (W m^{-2})')
% text(0.7, 0.15, strcat('k =', num2str(P(1), '%0.3f')), 'Units', 'normalized', 'HorizontalAlignment', 'center')
% text(0.7, 0.05, strcat('b =', num2str(P(2), '%0.3f')), 'Units', 'normalized', 'HorizontalAlignment', 'center')
% text(0.7, 0.25, strcat('RMSE =', num2str(RMSE, '%0.3f')), 'Units', 'normalized', 'HorizontalAlignment', 'center')
% text(0.7, 0.35, strcat('r2 =', num2str(r_2, '%0.3f')), 'Units', 'normalized', 'HorizontalAlignment', 'center')
% text(0.7, 0.45, strcat('NRMSE =', num2str(NRMSE, '%0.3f')), 'Units', 'normalized', 'HorizontalAlignment', 'center')
% text(0.7, 0.55, strcat('r =', num2str(sqrt(r_2), '%0.3f')), 'Units', 'normalized', 'HorizontalAlignment', 'center')

figure
hold on; grid on;
plot(Time1, z)
title('z')
ylabel('m')
ylim([0 100])

EMEP_AC_diurnal_mean = get_diurnal_hourly_mean(EMEP_AC, Time1, -5, 2); E_AC_OBS_diurnal_mean = get_diurnal_hourly_mean(E_AC, Time1, -5, 2);
figure
set(gcf,'Position',[200 400 1500 300])
hold on; grid on;
plot(0:0.5:23.5, EMEP_AC_diurnal_mean,'o-');
plot(0:0.5:23.5, E_AC_OBS_diurnal_mean,'o-');
xticks([0 3 6 9 12 15 18 21 24])
xticklabels({'0' '3' '6' '9' '12' '15' '18' '21' '24'})
title('E')
legend('MEP','OBS')
ylabel('W m^{-2}')

HMEP_AC_diurnal_mean = get_diurnal_hourly_mean(HMEP_AC, Time1, -5, 2); H_AC_OBS_diurnal_mean = get_diurnal_hourly_mean(H_AC, Time1, -5, 2);
figure
set(gcf,'Position',[200 400 1500 300])
hold on; grid on;
plot(0:0.5:23.5, HMEP_AC_diurnal_mean,'o-');
plot(0:0.5:23.5, H_AC_OBS_diurnal_mean,'o-');
legend('MEP','OBS')
xticks([0 3 6 9 12 15 18 21 24])
xticklabels({'0' '3' '6' '9' '12' '15' '18' '21' '24'})
title('H')
ylabel('W m^{-2}')

GMEP_AC_diurnal_mean = get_diurnal_hourly_mean(GMEP_AC, Time1, -5, 2); G_AC_OBS_diurnal_mean = get_diurnal_hourly_mean(G_AC, Time1, -5, 2);
figure
set(gcf,'Position',[200 400 1500 300])
hold on; grid on;
plot(0:0.5:23.5, GMEP_AC_diurnal_mean,'o-');
plot(0:0.5:23.5, G_AC_OBS_diurnal_mean,'o-');
legend('MEP','OBS')
xticks([0 3 6 9 12 15 18 21 24])
xticklabels({'0' '3' '6' '9' '12' '15' '18' '21' '24'})
ylim([-50 100])
title('G')
ylabel('W m^{-2}')

%% Below Canopy Site
% Is = 800;
TA = data3.air_temp_20cm; TA(find(abs(TA)> 100)) = nan;
RH = data3.RH_20cm/100;   RH(find(abs(RH)> 1)) = nan;
Rn_BC = data3.Rn;   Rn_BC(find(abs(Rn_BC)> 1300)) = nan;
H_BC = data4.H; H_BC(find(abs(H_BC)> 500)) = nan;
E_BC = data4.LE; E_BC(find(abs(E_BC)> 1300 | E_BC< -200)) = nan;
G_BC = data3.Surface_G; G_BC(find(abs(G_BC)> 1300)) = nan;
% Model of Is: delta_G = Is*delta_T*sqrt(w0)
Is = [];
for i = 1 : 48 :length(T_s)-48
    sub_Is = (max(G_AC(i:i+48)) - min(G_AC(i:i+48)))/(max(T_s(i:i+48)) - min(T_s(i:i+48)));
    w0 = 2*pi/86400;
    sub_Is = sub_Is/sqrt(w0);
    Is = [Is, sub_Is];
end
Is(find(Is> 1500 |Is<500))=nan;
Is = mean(Is,'omitnan');


qs = Qs(TA, RH);

z = nan(1, length(Rn_BC));
EMEP_BC = []; HMEP_BC = []; GMEP_BC = [];
for i = 1 : length(Rn_BC)
    curr_month = month(Time1(i));
    if curr_month >= 2 && curr_month < 5
        NDVI = 0.5;
    elseif curr_month >= 5 && curr_month < 9
        NDVI = 0.8;
    elseif curr_month >= 9 && curr_month < 12
        NDVI = 0.5;
    elseif curr_month >= 12 || curr_month < 2
        NDVI = 0.2;
    end
    z(i) = 15 / NDVI * abs((TA(i)+273)/abs(Rn_BC(i)));
    if isnan(z(i)) || z(i) == 0
        z(i) = 2;
    end
    [emep, hmep, gmep, I0] = F_MEP_EHG(Rn_BC(i), TA(i), qs(i), Is, z(i), ratio, type);
    EMEP_BC = [EMEP_BC, emep];
    HMEP_BC = [HMEP_BC, hmep];
    GMEP_BC = [GMEP_BC, gmep];
end

figure
grid on; hold on
plot(Time2, EMEP_BC);
plot(Time2, HMEP_BC);
plot(Time2, GMEP_BC);
ylim([-50 400])

figure
set(gcf,'Position',[100 100 1200 800])
subplot(3, 2, 1)
set(gca, 'Units', 'normalized', 'Position', [0.1 0.7 0.45 0.25])
hold on; grid on;
plot(Time2, EMEP_BC);
plot(Time2, E_BC);
% title('E')
legend('MEP','OBS')
ylabel('E (W m^{-2})')
ylim([-50 700])
xticklabels({})
subplot(3, 2, 2)
A = E_BC;
B = EMEP_BC';
idx = [];
for i = 1 : length(A)
    if ~(isnan(A(i)) | isnan(B(i)))
        idx = [idx, i];
    end
end
P = polyfit(A(idx), B(idx), 1);
r_2 = corrcoef(A(idx),B(idx)); r_2 = r_2(1,2);
RMSE = sqrt(mean((A(idx) - B(idx)).^2));
NRMSE = goodnessOfFit(A(idx),B(idx),'NRMSE');
set(gca, 'Units', 'normalized', 'Position', [0.7 0.7 0.25 0.25])
hold on; grid on;
scatter(E_BC, EMEP_BC)
plot([-500 1200], [-500 1200], 'LineWidth',2)
% plot([-500 1200], [-500*P(1) + P(2), 1200*P(1) + P(2)], 'LineWidth',2)
ylim([-200 800])
xlim([-200 800])
% text(0.7, 0.15, strcat('k =', num2str(P(1), '%0.3f')), 'Units', 'normalized', 'HorizontalAlignment', 'center')
% text(0.7, 0.05, strcat('b =', num2str(P(2), '%0.3f')), 'Units', 'normalized', 'HorizontalAlignment', 'center')
% text(0.7, 0.25, strcat('RMSE =', num2str(RMSE, '%0.3f')), 'Units', 'normalized', 'HorizontalAlignment', 'center')
% text(0.7, 0.35, strcat('r2 =', num2str(r_2, '%0.3f')), 'Units', 'normalized', 'HorizontalAlignment', 'center')
% text(0.7, 0.45, strcat('NRMSE =', num2str(NRMSE, '%0.3f')), 'Units', 'normalized', 'HorizontalAlignment', 'center')
% text(0.7, 0.55, strcat('r =', num2str(sqrt(r_2), '%0.3f')), 'Units', 'normalized', 'HorizontalAlignment', 'center')

subplot(3, 2, 3)
set(gca, 'Units', 'normalized', 'Position', [0.1 0.4 0.45 0.25])
hold on; grid on;
plot(Time2, HMEP_BC);
plot(Time2, H_BC);
% title('H')
% legend('MEP','OBS')
xticklabels({})
ylabel('H (W m^{-2})')
ylim([-50 400])
subplot(3, 2, 4)
A = H_BC;
B = HMEP_BC';
idx = [];
for i = 1 : length(A)
    if ~(isnan(A(i)) | isnan(B(i)))
        idx = [idx, i];
    end
end
P = polyfit(A(idx), B(idx), 1);
r_2 = corrcoef(A(idx),B(idx)); r_2 = r_2(1,2);
RMSE = sqrt(mean((A(idx) - B(idx)).^2));
NRMSE = goodnessOfFit(A(idx),B(idx),'NRMSE');
set(gca, 'Units', 'normalized', 'Position', [0.7 0.4 0.25 0.25])
hold on; grid on;
scatter(H_BC, HMEP_BC)
plot([-500 1200], [-500 1200], 'LineWidth',2)
% plot([-500 1200], [-500*P(1) + P(2), 1200*P(1) + P(2)], 'LineWidth',2)
ylim([-200 800])
xlim([-200 800])
ylabel('MEP (W m^{-2})')
% text(0.7, 0.15, strcat('k =', num2str(P(1), '%0.3f')), 'Units', 'normalized', 'HorizontalAlignment', 'center')
% text(0.7, 0.05, strcat('b =', num2str(P(2), '%0.3f')), 'Units', 'normalized', 'HorizontalAlignment', 'center')
% text(0.7, 0.25, strcat('RMSE =', num2str(RMSE, '%0.3f')), 'Units', 'normalized', 'HorizontalAlignment', 'center')
% text(0.7, 0.35, strcat('r2 =', num2str(r_2, '%0.3f')), 'Units', 'normalized', 'HorizontalAlignment', 'center')
% text(0.7, 0.45, strcat('NRMSE =', num2str(NRMSE, '%0.3f')), 'Units', 'normalized', 'HorizontalAlignment', 'center')
% text(0.7, 0.55, strcat('r =', num2str(sqrt(r_2), '%0.3f')), 'Units', 'normalized', 'HorizontalAlignment', 'center')

subplot(3, 2, 5)
set(gca, 'Units', 'normalized', 'Position', [0.1 0.1 0.45 0.25])
hold on; grid on;
plot(Time2, GMEP_BC);
plot(Time2, G_BC);
% title('G')
ylabel('G (W m^{-2})')
% legend('MEP','OBS')
% xticklabels({})
subplot(3, 2, 6)
A = G_BC;
B = GMEP_BC';
idx = [];
for i = 1 : length(A)
    if ~(isnan(A(i)) | isnan(B(i)))
        idx = [idx, i];
    end
end
P = polyfit(A(idx), B(idx), 1);
r_2 = corrcoef(A(idx),B(idx)); r_2 = r_2(1,2);
RMSE = sqrt(mean((A(idx) - B(idx)).^2));
NRMSE = goodnessOfFit(A(idx),B(idx),'NRMSE');
set(gca, 'Units', 'normalized', 'Position', [0.7 0.1 0.25 0.25])
hold on; grid on;
scatter(G_BC, GMEP_BC)
plot([-500 1200], [-500 1200], 'LineWidth',2)
% plot([-500 1200], [-500*P(1) + P(2), 1200*P(1) + P(2)], 'LineWidth',2)
ylim([-100 200])
xlim([-100 200])
xlabel('OBS (W m^{-2})')
% text(0.7, 0.15, strcat('k =', num2str(P(1), '%0.3f')), 'Units', 'normalized', 'HorizontalAlignment', 'center')
% text(0.7, 0.05, strcat('b =', num2str(P(2), '%0.3f')), 'Units', 'normalized', 'HorizontalAlignment', 'center')
% text(0.7, 0.25, strcat('RMSE =', num2str(RMSE, '%0.3f')), 'Units', 'normalized', 'HorizontalAlignment', 'center')
% text(0.7, 0.35, strcat('r2 =', num2str(r_2, '%0.3f')), 'Units', 'normalized', 'HorizontalAlignment', 'center')
% text(0.7, 0.45, strcat('NRMSE =', num2str(NRMSE, '%0.3f')), 'Units', 'normalized', 'HorizontalAlignment', 'center')
% text(0.7, 0.55, strcat('r =', num2str(sqrt(r_2), '%0.3f')), 'Units', 'normalized', 'HorizontalAlignment', 'center')

figure
hold on; grid on;
plot(Time2, z)
title('z')
ylabel('m')
ylim([0 100])

EMEP_BC_diurnal_mean = get_diurnal_hourly_mean(EMEP_BC, Time2, -5, 2); E_BC_OBS_diurnal_mean = get_diurnal_hourly_mean(E_BC, Time2, -5, 2);
figure
set(gcf,'Position',[200 400 1500 300])
hold on; grid on;
plot(0:0.5:23.5, EMEP_BC_diurnal_mean,'o-');
plot(0:0.5:23.5, E_BC_OBS_diurnal_mean,'o-');
legend('MEP','OBS')
xticks([0 3 6 9 12 15 18 21 24])
xticklabels({'0' '3' '6' '9' '12' '15' '18' '21' '24'})
ylim([-50 100])
title('E')
ylabel('W m^{-2}')

HMEP_BC_diurnal_mean = get_diurnal_hourly_mean(HMEP_BC, Time2, -5, 2); H_BC_OBS_diurnal_mean = get_diurnal_hourly_mean(H_BC, Time2, -5, 2);
figure
set(gcf,'Position',[200 400 1500 300])
hold on; grid on;
plot(0:0.5:23.5, HMEP_BC_diurnal_mean,'o-');
plot(0:0.5:23.5, H_BC_OBS_diurnal_mean,'o-');
legend('MEP','OBS')
xticks([0 3 6 9 12 15 18 21 24])
xticklabels({'0' '3' '6' '9' '12' '15' '18' '21' '24'})
ylim([-50 100])
title('H')
ylabel('W m^{-2}')

GMEP_BC_diurnal_mean = get_diurnal_hourly_mean(GMEP_BC, Time2, -5, 2); G_BC_OBS_diurnal_mean = get_diurnal_hourly_mean(G_BC, Time2, -5, 2);
figure
set(gcf,'Position',[200 400 1500 300])
hold on; grid on;
plot(0:0.5:23.5, GMEP_BC_diurnal_mean,'o-');
plot(0:0.5:23.5, G_BC_OBS_diurnal_mean,'o-');
legend('MEP','OBS')
xticks([0 3 6 9 12 15 18 21 24])
xticklabels({'0' '3' '6' '9' '12' '15' '18' '21' '24'})
ylim([-50 100])
title('G')
ylabel('W m^{-2}')









