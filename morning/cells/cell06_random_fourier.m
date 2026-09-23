% Cell 6: random Fourier features
%
% Instead of choosing the features by hand, take cosines of random projections
% of the input. Nothing about them is tuned, and the output layer is still pinv.

clear; close all;
randn('seed', 4); rand('seed', 4);

x = linspace(-4, 4, 200)';
y = sin(2*x) + 0.4*cos(7*x);

% Build D random features: cos(x * omega + phase), with omega and phase drawn once.
make_features = @(x, omega, phase) cos(x * omega' + repmat(phase', size(x,1), 1));

widths = [5, 20, 100];
fits = zeros(length(x), length(widths));

for k = 1:length(widths)
  D = widths(k);
  omega = randn(D,1) * 2;
  phase = rand(D,1) * 2 * pi;
  Z = make_features(x, omega, phase);
  w = pinv(Z) * y;                       % the only thing that is fitted
  fits(:,k) = Z * w;
  ss_res = sum((y - fits(:,k)).^2);
  ss_tot = sum((y - mean(y)).^2);
  fprintf('%4d random features -> R squared %.4f\n', D, 1 - ss_res/ss_tot);
end

fprintf('\n');
disp('The random numbers were never adjusted. Only the last layer was solved.');

figure;
plot(x, y, 'k-', 'linewidth', 2); hold on;
plot(x, fits(:,1), 'b--', 'linewidth', 1.2);
plot(x, fits(:,2), 'g--', 'linewidth', 1.2);
plot(x, fits(:,3), 'r-', 'linewidth', 1.5);
grid on; xlabel('x'); ylabel('y');
title('A wiggly function, fitted with random cosines');
legend('truth', '5 features', '20 features', '100 features', 'location', 'northwest');
hold off;
