close all; clear; clc;

% File path
filename = "C:\Users\lci7564\Downloads\st_2025-04-14_1740_08.36_400RPM_AC300_3x3_center_10D.dat";

% Open the file
fid = fopen(filename, 'r');

% Define format: 1 datetime (2 strings), followed by 18 floating-point numbers
formatSpec = '%s %s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f';

% Read data
data = textscan(fid, formatSpec);

% Close the file
fclose(fid);

% Combine the two string parts into full datetime strings
datetimeStr = strcat(data{1}, {' '}, data{2});

% Convert to datetime format
timestamps = datetime(datetimeStr, 'InputFormat', 'yyyy-MM-dd HH:mm:ss.SSS');

% Extract numerical data into a matrix
numericalData = cell2mat(data(3:end));

% Now 'timestamps' is a datetime array and 'numericalData' is an Nx18 matrix

% Centering all columns
numCols = size(numericalData, 2);

% Center the data (remove mean of each column)
numericalData_centered = numericalData - mean(numericalData, 1);

% Flip Column 13 (after centering)
numericalData_centered(:, 13) = -numericalData_centered(:, 13);

% Plot the centered and flipped data for Column 1 & 2
figure('Name', 'Centered and Flipped Column 13 & 14 Plot');
subplot(2,1,1);
plot(timestamps, numericalData_centered(:,1), 'b-', 'DisplayName', 'Column 1');
hold on;
plot(timestamps, numericalData_centered(:,2), 'r-', 'DisplayName', 'Column 2');
hold off;
xlabel('Timestamp');
ylabel('Value');
title('Centered Time Series: Column 1 & 2');
legend('show');
grid on;

% Plot the centered and flipped data for Column 13 & 14
subplot(2,1,2);
plot(timestamps, numericalData_centered(:,13), 'b-', 'DisplayName', 'Column 13');
hold on;
plot(timestamps, numericalData_centered(:,14), 'r-', 'DisplayName', 'Column 14');
hold off;
xlabel('Timestamp');
ylabel('Value');
title('Centered and Flipped Time Series: Column 13 & 14');
legend('show');
grid on;

% DFT computation for centered and flipped Columns 1 & 2
sig1_centered = numericalData_centered(:,1);
sig2_centered = numericalData_centered(:,2);

% DFT computation for Columns 13 & 14
sig13_centered = numericalData_centered(:,13);
sig14_centered = numericalData_centered(:,14);

% ========== DFT for Column 1 & 2 ==========
[f1_whole, Y1_whole] = dft_calc(sig1_centered);
[f2_whole, Y2_whole] = dft_calc(sig2_centered);

% ========== DFT for Column 13 & 14 ==========
[f13_whole, Y13_whole] = dft_calc(sig13_centered);
[f14_whole, Y14_whole] = dft_calc(sig14_centered);

% ===== Plot DFTs for Column 1 & 2 =====
figure("Name", "DFT of Column 1 and 2 (Centered)");
subplot(2,1,1);
semilogy(f1_whole, Y1_whole);
legend("Whole Signal");
xlabel('Frequency (Hz)');
ylabel('|Y(f)|');
title('DFT of Column 1 (Centered)');
grid on;

subplot(2,1,2);
semilogy(f2_whole, Y2_whole);
legend("Whole Signal");
xlabel('Frequency (Hz)');
ylabel('|Y(f)|');
title('DFT of Column 2 (Centered)');
grid on;

% ===== Plot DFTs for Column 13 & 14 =====
figure("Name", "DFT of Column 13 and 14 (Centered and Flipped)");
subplot(2,1,1);
semilogy(f13_whole, Y13_whole);
legend("Whole Signal");
xlabel('Frequency (Hz)');
ylabel('|Y(f)|');
title('DFT of Column 13 (Centered and Flipped)');
grid on;

subplot(2,1,2);
semilogy(f14_whole, Y14_whole);
legend("Whole Signal");
xlabel('Frequency (Hz)');
ylabel('|Y(f)|');
title('DFT of Column 14 (Centered)');
grid on;

% ========== Spectrogram for Column 1 & 2 ==========
dt = seconds(median(diff(timestamps)));  % Calculate the time step
Fs = 1 / dt;  % Sampling frequency

figure("Name", "Spectrogram of Column 1 and 2 (Centered)");

subplot(2,1,1);
spectrogram(sig1_centered, 256, 200, 512, Fs, 'yaxis');
title('Spectrogram of Column 1 (Centered)');

subplot(2,1,2);
spectrogram(sig2_centered, 256, 200, 512, Fs, 'yaxis');
title('Spectrogram of Column 2 (Centered)');

% ========== Spectrogram for Column 13 & 14 ==========
figure("Name", "Spectrogram of Column 13 and 14 (Centered and Flipped)");

subplot(2,1,1);
spectrogram(sig13_centered, 256, 200, 512, Fs, 'yaxis');
title('Spectrogram of Column 13 (Centered and Flipped)');

subplot(2,1,2);
spectrogram(sig14_centered, 256, 200, 512, Fs, 'yaxis');
title('Spectrogram of Column 14 (Centered)');

% ========== Function for DFT Calculation ========== 
function [f, Y] = dft_calc(signal)
    L = length(signal);
    if mod(L,2) == 1
        L = L - 1;
        signal = signal(1:L);
    end

    Yfft = fft(signal);
    P2 = abs(Yfft / L);
    np = ceil((L+1)/2);
    P1 = P2(1:np);
    P1(2:end-1) = 2 * P1(2:end-1); % one-sided

    Fs = 1 / 0.015;  % Fixed sample rate as in your code
    f = Fs * (0:(L/2)) / L;
    Y = abs(Yfft(1:length(f)));
end
