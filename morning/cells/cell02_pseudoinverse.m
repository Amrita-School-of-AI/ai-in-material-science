% Cell 2: the pseudoinverse as a projection
%
% Ax = b usually has no solution. The pseudoinverse returns the x whose Ax sits
% closest to b, and the part it cannot reach is left over at right angles.

clear; close all;

% Part 1: one direction in three dimensions, so the geometry is visible.
a = [1; 2; 2];
b = [4; 1; 3];

x = pinv(a) * b;      % the best multiple of a
p = a * x;            % the projection of b onto the line through a
r = b - p;            % what is left over

fprintf('best multiple of a : x = %.4f\n', x);
fprintf('projection p       : [%.3f %.3f %.3f]\n', p);
fprintf('residual r = b - p : [%.3f %.3f %.3f]\n', r);
fprintf('a dot r            : %.2e   (zero, so r is at right angles to a)\n\n', a' * r);

t = linspace(-0.5, 2.5, 20);
figure;
plot3(a(1)*t, a(2)*t, a(3)*t, 'b-', 'linewidth', 2); hold on;
plot3(b(1), b(2), b(3), 'ro', 'markersize', 10, 'linewidth', 2);
plot3(p(1), p(2), p(3), 'gs', 'markersize', 10, 'linewidth', 2);
plot3([b(1) p(1)], [b(2) p(2)], [b(3) p(3)], 'k--', 'linewidth', 1.5);
grid on; xlabel('x'); ylabel('y'); zlabel('z');
title('b (red) projected onto the line through a (blue). The dashed drop is at right angles.');
hold off;

% Part 2: the same idea with more data than unknowns.
A = [1 1; 1 2; 1 3; 1 4; 1 5];
y = [2.1; 3.9; 6.2; 7.8; 10.1];

w = pinv(A) * y;
fprintf('least squares solution from pinv     : [%.4f %.4f]\n', w);
fprintf('least squares solution from backslash: [%.4f %.4f]\n', A \ y);

res = y - A*w;
fprintf('residual still at right angles to every column: [%.2e %.2e]\n', A' * res);
fprintf('sum of squared error: %.4f\n', sum(res.^2));
disp('No iteration, no learning rate. One solve.');
