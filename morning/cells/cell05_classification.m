% Cell 5: pattern classification, by regression to labels
%
% Give one class the label +1 and the other -1, fit them with the pseudoinverse,
% and the boundary is the place where the fit crosses zero.

clear; close all;
randn('seed', 3);

n = 120;
class1 = [randn(n,1)*0.8 + 2, randn(n,1)*0.8 + 2];
class2 = [randn(n,1)*0.8 - 1, randn(n,1)*0.8 - 1];

X = [class1; class2];
labels = [ones(n,1); -ones(n,1)];

% Same feature matrix as before: a column of ones, then the measurements.
A = [ones(size(X,1),1), X];
w = pinv(A) * labels;

fprintf('weights: intercept %.4f, x1 %.4f, x2 %.4f\n', w(1), w(2), w(3));

guess = sign(A * w);
fprintf('training accuracy: %.1f%%\n\n', 100 * mean(guess == labels));
disp('A classifier, fitted with the same one line of algebra as the straight line was.');

% The boundary is w(1) + w(2)*x1 + w(3)*x2 = 0, so x2 = -(w(1) + w(2)*x1)/w(3).
xb = linspace(min(X(:,1))-0.5, max(X(:,1))+0.5, 50);
yb = -(w(1) + w(2)*xb) / w(3);

figure;
plot(class1(:,1), class1(:,2), 'ro', 'markersize', 5); hold on;
plot(class2(:,1), class2(:,2), 'bs', 'markersize', 5);
plot(xb, yb, 'k-', 'linewidth', 2);
grid on; xlabel('feature 1'); ylabel('feature 2');
title('Two classes, and the line where the least squares fit crosses zero');
legend('class +1', 'class -1', 'boundary', 'location', 'northwest');
axis([min(X(:,1))-0.5 max(X(:,1))+0.5 min(X(:,2))-0.5 max(X(:,2))+0.5]);
hold off;
