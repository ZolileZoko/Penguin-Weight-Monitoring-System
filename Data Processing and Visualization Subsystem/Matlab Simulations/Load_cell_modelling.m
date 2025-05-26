%% Load Cell Signal Processing with True Weights Import
clear all; close all; clc;

% 1. Import true weights from Excel file
try
    opts = detectImportOptions('trueWeights.xlsx');
    opts = setvartype(opts, 'true_weight', 'double'); % Force numeric conversion
    weightTable = readtable('trueWeights.xlsx', opts);
    
    if ~ismember('true_weight', weightTable.Properties.VariableNames)
        error('Column "true_weight" not found in Excel file');
    end
    
    trueWeights = weightTable.true_weight;
    trueWeights = trueWeights(~isnan(trueWeights)); % Remove NaNs
    
    if isempty(trueWeights)
        error('No valid weights found in the file');
    end
    
    fprintf('Successfully imported %d weights from trueWeights.xlsx\n', length(trueWeights));
    disp('Imported weights:');
    disp(trueWeights');
catch ME
    error('Error reading trueWeights.xlsx: %s', ME.message);
end

% 2. Initialize results storage
num_weights = length(trueWeights);
results = table((1:num_weights)', trueWeights, zeros(num_weights,1), zeros(num_weights,1), ...
    'VariableNames', {'Trial', 'TrueWeight_kg', 'Measured_kg', 'Error_kg'});

% 3. Processing parameters
fs = 100; % Sampling frequency (Hz)
num_samples = 500; % Number of samples per measurement
t = 0:1/fs:10-1/fs; % Extended time vector (10 seconds)
N_ma = 20; % Moving average window size

% 4. Process each weight measurement
for i = 1:num_weights
    weight = trueWeights(i);
    
    % Create base signal with overshoot
    base_signal = weight + 0.5*exp(-3*t).*cos(10*t);

    % Waddling noise parameters
    waddle_freq = 1.2;
    step_impact = 0.3;
    duty_cycle = 0.6;
    waddle_amp = 0.12 + 0.03*rand();
    
    waddle_signal = zeros(size(t));
    for j = 2:length(t)
        phase = 2*pi*waddle_freq*t(j) + 0.1*randn();
        waddle_signal(j) = waddle_amp * weight * sin(phase);
        if mod(phase, 2*pi) < 2*pi*duty_cycle
            waddle_signal(j) = waddle_signal(j) + step_impact * weight * exp(-50 * mod(phase, 2*pi));
        end
    end
    
    % Combine signal components
    signal = base_signal + 0.05*randn(size(t)) ... % White noise
           + 0.001*sin(2*pi*0.01*t) ...            % Drift
           + 0.003*(1-exp(-t/1800)) ...            % Creep
           + waddle_signal;                        % Waddling

    % Simulate ADC quantization
    adc_bits = 12;
    adc_max = 2^adc_bits - 1;
    weight_range = [0, 10];
    
    signal_normalized = (signal - weight_range(1)) / (weight_range(2) - weight_range(1));
    signal_clipped = max(0, min(1, signal_normalized));
    signal_quantized = round(signal_clipped * adc_max) / adc_max;
    signal_digital = signal_quantized * (weight_range(2) - weight_range(1)) + weight_range(1);

    % Filter pipeline
    filtered_ma = movmean(signal_digital, N_ma);
    
    
    % Stable average (now using last 3 seconds for stability)
    stable_measurement = mean(filtered_ma(end-300:end));
    
    % Store
    results.Measured_kg(i) = stable_measurement;
    results.Error_kg(i) = stable_measurement - weight;

    % Plot (continuous-style)
    if mod(i,4) == 1 || num_weights <= 8
        figure('Position', [100 100 1000 500], 'Color', 'w', ...
               'Name', sprintf('Trial %d: True = %.3f kg', i, weight));
        
        % Plot raw signal
        plot(t, signal, 'b', 'LineWidth', 1.2);
        hold on;
        
        % Plot filtered signal
        plot(t, filtered_ma, 'r', 'LineWidth', 2.5);
        
        % Add horizontal line for true weight
        yline(weight, '--k', 'LineWidth', 1.5, 'Label', 'True Weight');
        
        title(sprintf('Trial %d: True = %.3f kg | Measured = %.3f kg | Error = %.3f kg', ...
            i, weight, stable_measurement, results.Error_kg(i)), 'FontSize', 12);
        
        xlabel('Time (s)', 'FontSize', 11);
        ylabel('Weight (kg)', 'FontSize', 11);
        legend('Raw Signal', 'Filtered Output', 'Location', 'best');
        grid on;
        
        % Set axis limits
        xlim([0 10]);
        ylim([min(signal)*0.95 max([signal, filtered_ma])*1.05]);
        
        % Add zoomed inset
        axes('Position', [0.6 0.6 0.3 0.3]);
        box on;
        plot(t(end-300:end), filtered_ma(end-300:end), 'r', 'LineWidth', 2);
        hold on;
        yline(stable_measurement, '--g', 'LineWidth', 1.5);
        title('Final 3s (Stable Region)');
        xlim([7 10]);
        grid on;
    end
end

% 5. Results table
disp(' ');
disp('=== EXPERIMENT RESULTS ===');
disp(results(:, {'Trial', 'TrueWeight_kg', 'Measured_kg', 'Error_kg'}));
disp(' ');

% 6. Statistics
fprintf('=== MEASUREMENT STATISTICS ===\n');
fprintf('Number of trials: %d\n', num_weights);
fprintf('Mean Absolute Error: %.4f kg\n', mean(abs(results.Error_kg)));
fprintf('Max Absolute Error:  %.4f kg\n', max(abs(results.Error_kg)));
fprintf('Error Standard Deviation: %.4f kg\n', std(results.Error_kg));
fprintf('Relative Error (%% of true weight): %.2f%%\n', ...
    100*mean(abs(results.Error_kg./results.TrueWeight_kg)));

% Lowpass Filter Function
function y = butter_lowpass(data, cutoff, fs, order)
    nyq = 0.5*fs;
    normal_cutoff = cutoff/nyq;
    [b,a] = butter(order, normal_cutoff, 'low');
    y = filtfilt(b, a, data);
end
