clc;
clearvars;
close all;

%% ========================================================================
% 0. THÔNG SỐ CẤU HÌNH
% ========================================================================
filename   = '096_300_7l.csv';
F_MAX_PLOT = 200e3; % Giới hạn tần số hiển thị: 200 kHz (200,000 Hz)

%% ========================================================================
% 1. ĐỌC DỮ LIỆU CSV
% ========================================================================
try
    data = readmatrix(filename);
catch
    data = csvread(filename);
end

% Loại bỏ dòng NaN
valid_rows = ~isnan(data(:,1)) & ~isnan(data(:,2));
time_raw   = data(valid_rows,1);
signal_raw = data(valid_rows,2);

%% ========================================================================
% 2. TÍNH TẦN SỐ LẤY MẪU & NỘI SUY
% ========================================================================
N_raw  = length(time_raw);
dt_avg = (time_raw(end) - time_raw(1)) / (N_raw - 1);

% Nội suy về lưới thời gian đều
t_uniform = linspace(time_raw(1), time_raw(end), N_raw)';
s_uniform = interp1(time_raw, signal_raw, t_uniform, 'linear');

dt = (t_uniform(end) - t_uniform(1)) / (N_raw - 1);
Fs = 1 / dt;

fprintf('=========================================\n');
fprintf('FILE: %s\n', filename);
fprintf('So mau N = %d\n', N_raw);
fprintf('Tan so lay mau Fs = %.2f Hz (%.2f kHz)\n', Fs, Fs/1000);
fprintf('=========================================\n');

%% ========================================================================
% 3. TÍNH PHỔ FFT
% ========================================================================
% Loại bỏ thành phần DC
v_ac = s_uniform - mean(s_uniform);
N    = length(v_ac);

% Biến đổi FFT
Y = fft(v_ac);

% Phổ biên độ 1 phía
P1 = abs(Y(1:floor(N/2)+1)) / N;
if N > 2
    P1(2:end-1) = 2 * P1(2:end-1);
end

% Độ phân giải & Trục tần số (Hz)
df = Fs / N;
f  = (0:floor(N/2)) * df;

%% ========================================================================
% 4. VẼ PHỔ TẦN SỐ FFT (NỀN TRẮNG - ĐẾN 200 kHz)
% ========================================================================
figure( ...
    'Name', 'Phổ Tần Số FFT (0 - 200 kHz)', ...
    'Color', 'white', ...
    'Position', [100 100 1100 600]);

ax = axes( ...
    'Parent', gcf, ...
    'Color', 'white', ...
    'XColor', 'black', ...
    'YColor', 'black', ...
    'LineWidth', 1.2, ...
    'FontSize', 11, ...
    'FontWeight', 'bold');
hold(ax, 'on');

% Vẽ phổ FFT (Trục X đổi sang kHz cho dễ nhìn)
plot(ax, f / 1000, P1, ...
    'Color', [0 0.35 0.8], ...
    'LineWidth', 1.1);

% Giới hạn trục X tối đa 200 kHz
xlim(ax, [0, F_MAX_PLOT / 1000]);

% Tìm đỉnh lớn nhất trong khoảng 0-200kHz để chỉnh trục Y
idx_200k = find(f <= F_MAX_PLOT);
if ~isempty(idx_200k)
    ylim(ax, [0, max(P1(idx_200k)) * 1.15]);
end

% Tên trục & Tiêu đề
xlabel(ax, 'Frequency (kHz)', 'Color', 'black', 'FontSize', 11, 'FontWeight', 'bold');
ylabel(ax, '|Vpeak| (V)', 'Color', 'black', 'FontSize', 11, 'FontWeight', 'bold');
title(ax, 'Single-Sided FFT Spectrum (0 - 200 kHz)', 'Color', 'black', 'FontSize', 13, 'FontWeight', 'bold');

% Lưới đồ thị
grid(ax, 'on');
ax.GridColor = [0.75 0.75 0.75];
ax.GridAlpha = 0.5;
box(ax, 'on');

hold(ax, 'off');
fprintf('Đã hoàn tất vẽ phổ FFT.\n');