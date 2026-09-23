% Cell 4: non-linear regression, with the same solve
%
% The data now bends. The method does not change. Only the columns of A change.

clear; close all;
randn('seed', 2);

x = linspace(-3, 3, 60)';
y = 0.5*x.^3 - 2*x + 1 + 0.8*randn(size(x));

% Fit 1: a straight line, which cannot bend.
A_line = [ones(size(x)), x];
w_line = pinv(A_line) * y;

% Fit 2: add powers of x as extra columns. Still one pseudoinverse.
A_poly = [ones(size(x)), x, x.^2, x.^3];
w_poly = pinv(A_poly) * y;

% Fit 3: bumps placed along x instead of powers. Still one pseudoinverse.
centres = linspace(-3, 3, 10);
A_bump = ones(size(x));
for k = 1:length(centres)
  A_bump = [A_bump, exp(-(x - centres(k)).^2)];
end
w_bump = pinv(A_bump) * y;

r2 = @(y, f) 1 - sum((y-f).^2) / sum((y-mean(y)).^2);
fprintf('straight line      : %d columns, R squared %.4f\n', size(A_line,2), r2(y, A_line*w_line));
fprintf('powers up to cubic : %d columns, R squared %.4f\n', size(A_poly,2), r2(y, A_poly*w_poly));
fprintf('ten gaussian bumps : %d columns, R squared %.4f\n\n', size(A_bump,2), r2(y, A_bump*w_bump));
disp('Same pinv on all three. The only difference is what went into the columns.');

figure;
plot(x, y, 'ko', 'markersize', 5); hold on;
plot(x, A_line*w_line, 'b-', 'linewidth', 1.5);
plot(x, A_poly*w_poly, 'r-', 'linewidth', 2);
plot(x, A_bump*w_bump, 'g--', 'linewidth', 2);
grid on; xlabel('x'); ylabel('y');
title('One method, three choices of features');
legend('data', 'line', 'powers of x', 'gaussian bumps', 'location', 'northwest');
hold off;
