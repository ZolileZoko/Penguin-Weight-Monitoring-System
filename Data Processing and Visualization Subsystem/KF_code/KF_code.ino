#include "HX711.h"

#define DOUT  13
#define CLK   12

HX711 scale;

// Kalman filter variables
double x = 0.0;
double P = 1e4;
double Q = 1e-5;
double R = pow(0.5, 2);
double last_measurement = 0.0;
double some_threshold = 2.0;

// Moving average variables
#define WINDOW_SIZE 15
double readings[WINDOW_SIZE] = {0};  // initialize to zero
int idx = 0;  // <-- renamed from 'index'
int count = 0;
double total = 0.0;

double movingAverage(double newValue) {
  total -= readings[idx];
  readings[idx] = newValue;
  total += newValue;
  idx = (idx + 1) % WINDOW_SIZE;

  if (count < WINDOW_SIZE) count++;

  return total / count;
}

void setup() {
  Serial.begin(115200);
  scale.begin(DOUT, CLK);
  scale.set_scale(283.507);  // Set your calibration factor here
  delay(5000);
  scale.tare();
  delay(2000);

  // Print header for Serial Plotter
  Serial.println("Raw\tFiltered\tSmoothed");
}

void loop() {
  if (scale.is_ready()) {
    double z = scale.get_units(5);
    double delta_z = fabs(z - last_measurement);
    last_measurement = z;

    // Step 1: Apply moving average on raw measurement first
    double ma_value = movingAverage(z);

    // Step 2: Adjust Kalman filter parameters dynamically based on MA value changes
    double delta_ma = fabs(ma_value - x);  // difference from last filtered state
    if (delta_ma > some_threshold) {
      Q = 1e-2;
      R = pow(0.1, 2);
    } else {
      Q = 1e-5;
      R = pow(0.3, 2);
    }

    // Step 3: Kalman filter equations on the moving averaged value
    double x_pred = x;
    double P_pred = P + Q;
    double K = P_pred / (P_pred + R);
    x = x_pred + K * (ma_value - x_pred);
    P = (1.0 - K) * P_pred;

    // Print: Raw, Moving Average, Kalman Filtered
    Serial.print(z, 3);      // Raw
    Serial.print("\t");
    Serial.print(ma_value, 3);  // Moving Average smoothed
    Serial.print("\t");
    Serial.println(x, 3);    // Kalman Filtered

  } else {
    Serial.println("0\t0\t0");
  }

  delay(100);  // 10 Hz
}

