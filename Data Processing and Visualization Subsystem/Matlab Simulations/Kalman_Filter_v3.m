% Number of measurements (simulate time steps)
num_steps = 200;

% Simulated true weight (e.g., 3700g for a penguin)
true_weight = 3700;

% Measurement noise standard deviation (sensor noise HX711 load cell)
measurement_noise_std = 0.15e-3;

% Simulate noisy measurements
rng(1);  % for reproducibility
z = zeros(1, num_steps);  % start with no penguin

% Penguin steps on between step 50 and 150
z(51:150) = true_weight + measurement_noise_std * randn(1, 100);

% Kalman filter variables
x = 0;           % initial estimate of weight
P = 1e4;         % initial estimation error covariance (large uncertainty)
Q = 1e-3;        % process noise covariance (adjusted for faster tracking)
R = measurement_noise_std^2;  % measurement noise covariance

% Storage
x_estimates = zeros(1, num_steps);
K_values = zeros(1, num_steps);  % optional: to plot Kalman Gain

% Kalman filter loop
for k = 1:num_steps
    % Predict step
    x_pred = x;
    P_pred = P + Q;  % prediction of error covariance
    
    % Assume penguin is present and moving only if the weight is non-zero
    % For dynamic movement, assume that movement causes increased noise
    if z(k) > 100  % assume penguin is present only if > 100g
        % Increase process noise if the penguin is moving (i.e., weight fluctuates)
        if k > 50 && k < 150  % During the "waddling" period (example)
            Q = 1e-2;  % Increase process noise during movement
            R = (measurement_noise_std * 2)^2;  % Increase measurement noise during movement (waddling)
        else
            Q = 1e-3;  % Lower process noise when penguin is more stable
            R = measurement_noise_std^2;  % Normal measurement noise when stationary
        end

        % Kalman gain
        K = P_pred / (P_pred + R);
        
        % Update step
        x = x_pred + K * (z(k) - x_pred);
        P = (1 - K) * P_pred;
        K_values(k) = K;
    else
        % No update if no penguin
        x = x_pred;
        P = P_pred;
        K_values(k) = 0;
    end

    % Store estimate
    x_estimates(k) = x;
end
% Plot only the noisy measurement
figure;
plot(1:num_steps, z, 'r.');
xlabel('Time Step');
ylabel('Weight (g)');
title('Noisy Penguin Weight Measurements');
legend('Noisy Measurement');
grid on;
