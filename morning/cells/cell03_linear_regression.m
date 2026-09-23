% Cell 3: linear regression is that same solve
%
% Put a column of ones next to the data, take the pseudoinverse, and the line
% of best fit falls out.

clear; close all;
randn('seed', 1);

% Data from a line we choose, with measurement noise added.
true_slope = 2.0;
true_intercept = 1.0;

x = linspace(0, 10, 40)';
y = true_intercept + true_slope * x + 1.2 * randn(size(x));

% The feature matrix: one column of ones for the intercept, one for x.
A = [ones(size(x)), x];
w = pinv(A) * y;

fprintf('true  intercept %.3f, slope %.3f\n', true_intercept, true_slope);
fprintf('found intercept %.3f, slope %.3f\n\n', w(1), w(2));

yhat = A * w;
ss_res = sum((y - yhat).^2);
ss_tot = sum((y - mean(y)).^2);
fprintf('R squared: %.4f\n', 1 - ss_res/ss_tot);
fprintf('typical error: %.3f\n', sqrt(ss_res/length(y)));

figure;
plot(x, y, 'bo', 'markersize', 6); hold on;
plot(x, yhat, 'r-', 'linewidth', 2);
grid on; xlabel('x'); ylabel('y');
title('Forty noisy points, one pseudoinverse, one line');
legend('measurements', 'least squares fit', 'location', 'northwest');
hold off;
