% Cell 7: the random kitchen sink on two interleaved half moons
%
% Two classes that no straight line can separate. Random features first,
% pseudoinverse second, and the boundary bends on its own.

clear; close all;
randn('seed', 5); rand('seed', 5);

% Build the two half moons.
n = 200;
t1 = pi * rand(n,1);
moon1 = [cos(t1), sin(t1)] + 0.12*randn(n,2);
t2 = pi * rand(n,1);
moon2 = [1 - cos(t2), 0.5 - sin(t2)] + 0.12*randn(n,2);

X = [moon1; moon2];
labels = [ones(n,1); -ones(n,1)];

% A straight line on the raw coordinates, for comparison.
A_plain = [ones(size(X,1),1), X];
w_plain = pinv(A_plain) * labels;
acc_plain = 100 * mean(sign(A_plain * w_plain) == labels);

% Now the kitchen sink: project onto random directions, pass through a cosine.
D = 300;
W = randn(2, D) * 2.5;
b = rand(1, D) * 2 * pi;
Z = cos(X * W + repmat(b, size(X,1), 1));
w = pinv(Z) * labels;
acc_rks = 100 * mean(sign(Z * w) == labels);

fprintf('straight line on the raw features : %.1f%% correct\n', acc_plain);
fprintf('%d random features, then pinv     : %.1f%% correct\n\n', D, acc_rks);
disp('The random layer was never trained. Only the output weights were solved.');

% Colour the whole plane by what the model would say there.
gx = linspace(min(X(:,1))-0.4, max(X(:,1))+0.4, 120);
gy = linspace(min(X(:,2))-0.4, max(X(:,2))+0.4, 120);
[GX, GY] = meshgrid(gx, gy);
G = [GX(:), GY(:)];
ZG = cos(G * W + repmat(b, size(G,1), 1));
decision = reshape(ZG * w, size(GX));

figure;
contourf(GX, GY, decision, [-100 0 100]); hold on;
plot(moon1(:,1), moon1(:,2), 'ro', 'markersize', 4, 'linewidth', 1.2);
plot(moon2(:,1), moon2(:,2), 'bs', 'markersize', 4, 'linewidth', 1.2);
xlabel('feature 1'); ylabel('feature 2');
title('Two half moons and the region the random kitchen sink assigns to each');
hold off;
