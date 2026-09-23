% AI in Material Science
% University of Calicut, 24 September 2026
% Morning session: foundations, from linear algebra to learning
%
% Nine short cells, one per topic. Teach the topic, then ask the room to run
% the next cell.
%
% To run one cell:
%   MATLAB  click anywhere inside the cell and press Ctrl+Enter
%   Octave  select the lines of the cell and press F9
%
% If your Octave does not do cells, run the matching file in the cells folder
% instead: type cell01_column_row at the prompt, then cell02_pseudoinverse,
% and so on.
%
% Every cell stands on its own. A participant who missed one can still run
% the next. Cells 8 and 9 read a file from the data folder beside this script.


%% Cell 1  The column-row (C&R) decomposition
%
% Every matrix is a product of its independent columns and a small set of rows.
% Run this after the first block on linear algebra.

clear; close all;

% A matrix built so that the dependence between its columns is visible.
c1 = [1; 2; 3; 1];
c3 = [0; 1; 1; 2];
A = [c1, 2*c1, c3, c1 + c3];

disp('A ='); disp(A);
fprintf('rank of A is %d, but A has %d columns\n\n', rank(A), size(A,2));

% Walk the columns from left to right and keep one only if it adds new rank.
piv = [];
sofar = [];
for j = 1:size(A,2)
  if rank([sofar, A(:,j)]) > rank(sofar)
    piv(end+1) = j;
    sofar = [sofar, A(:,j)];
  end
end

C = A(:, piv);
fprintf('independent columns of A: '); fprintf('%d ', piv); fprintf('\n');
disp('C ='); disp(C);

% R holds the recipe for rebuilding every column of A from the columns of C.
% The pseudoinverse gives it in one line.
R = pinv(C) * A;
disp('R ='); disp(round(R * 1000) / 1000);

fprintf('largest entry of A - C*R is %.2e\n', max(max(abs(A - C*R))));
disp('So A = C*R, with C holding 2 columns and R holding 2 rows.');
disp('The rank is the number of columns of C, and that is all the matrix really carries.');

% The same fact as a picture: every column of A lies on the plane spanned by C.
figure;
plot3([0 C(1,1)], [0 C(2,1)], [0 C(3,1)], 'b-', 'linewidth', 2); hold on;
plot3([0 C(1,2)], [0 C(2,2)], [0 C(3,2)], 'b-', 'linewidth', 2);
for j = 1:size(A,2)
  plot3([0 A(1,j)], [0 A(2,j)], [0 A(3,j)], 'r--', 'linewidth', 1);
end
grid on; xlabel('x'); ylabel('y'); zlabel('z');
title('First three rows: every column of A (red) is a mix of the two in C (blue)');
hold off;

%% Cell 2  The pseudoinverse as a projection
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

%% Cell 3  Linear regression
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

%% Cell 4  Non-linear regression
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

%% Cell 5  Pattern classification
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

%% Cell 6  Random Fourier features
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

%% Cell 7  The random kitchen sink
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

%% Cell 8  A neural network trained without backpropagation
%
% 1797 handwritten digits, eight by eight pixels each. One hidden layer whose
% weights are random and never touched, and an output layer solved with pinv.

clear; close all;
randn('seed', 6);

% Find digits.csv whether you run this from the cells folder or from the
% folder above it.
datafile = '';
here = fileparts(mfilename('fullpath'));
tries = {fullfile(here, '..', 'data', 'digits.csv'), ...
         fullfile(here, 'data', 'digits.csv'), ...
         fullfile('..', 'data', 'digits.csv'), ...
         fullfile('data', 'digits.csv'), ...
         'digits.csv'};
for k = 1:length(tries)
  if exist(tries{k}, 'file')
    datafile = tries{k};
    break;
  end
end
if isempty(datafile)
  error('digits.csv not found. Change to the morning folder and run again.');
end

raw = csvread(datafile);

X = raw(:, 1:64) / 16;        % pixel values, scaled to roughly 0 to 1
y = raw(:, 65);               % the digit shown, 0 to 9
fprintf('loaded %d images of %d pixels\n', size(X,1), size(X,2));

% Split into a training set and a test set the model never sees.
n = size(X,1);
idx = randperm(n);
ntrain = round(0.7 * n);
tr = idx(1:ntrain);
te = idx(ntrain+1:end);

% Turn each label into a row of ten numbers, +1 in the right place.
Y = -ones(n, 10);
for i = 1:n
  Y(i, y(i) + 1) = 1;
end

% The hidden layer: random weights, a random shift, and a tanh. Never adjusted.
H = 600;
W1 = randn(64, H) * 0.5;
b1 = randn(1, H) * 0.5;
hidden = @(Z) tanh(Z * W1 + repmat(b1, size(Z,1), 1));

Htr = hidden(X(tr,:));
Hte = hidden(X(te,:));

% The output layer: one pseudoinverse.
W2 = pinv(Htr) * Y(tr,:);

[junk, guess_tr] = max(Htr * W2, [], 2);
[junk, guess_te] = max(Hte * W2, [], 2);
acc_tr = 100 * mean((guess_tr - 1) == y(tr));
acc_te = 100 * mean((guess_te - 1) == y(te));

fprintf('hidden layer: %d random units, never trained\n', H);
fprintf('training accuracy: %.2f%%\n', acc_tr);
fprintf('test accuracy    : %.2f%%\n\n', acc_te);
disp('No gradients, no epochs, no learning rate. The fit is one matrix solve.');

% Show sixteen test digits with what the network called them.
figure;
for k = 1:16
  subplot(4, 4, k);
  img = reshape(X(te(k), :), 8, 8)';
  imagesc(img); axis off; colormap(gray);
  title(sprintf('%d', guess_te(k) - 1));
end

%% Cell 9  SMILES, SELFIES and a first chemical model
%
% A molecule is written as a line of text. Count what is in that line and you
% already have a feature vector. The fit is the same pseudoinverse as before.
%
% SMILES writes atoms as letters, rings as digits, branches in brackets:
%
%   name        SMILES                          SELFIES                                       logS
%   Methanol    CO                              [C][O]                                         1.57
%   Ethanol     CCO                             [C][C][O]                                      1.10
%   Benzene     c1ccccc1                        [C][=C][C][=C][C][=C][Ring1][=Branch1]        -1.64
%   Toluene     Cc1ccccc1                       [C][C][=C][C][=C][C][=C][Ring1][=Branch1]     -2.21
%   Phenol      c1ccccc1O                       [C][=C][C][=C][C][=C][Ring1][=Branch1][O]      0.00
%   Caffeine    Cn1cnc2n(C)c(=O)n(C)c(=O)c12    [C][N][C][=N][C][N][Branch1][C][C]...         -0.88
%
% SELFIES writes the same molecule so that every possible string is a valid
% molecule. That is why the generative models in the afternoon session prefer it.

clear; close all;

% Find the data file whether you run this from the cells folder or above it.
datafile = '';
here = fileparts(mfilename('fullpath'));
tries = {fullfile(here, '..', 'data', 'esol_selfies.csv'), ...
         fullfile(here, 'data', 'esol_selfies.csv'), ...
         fullfile('..', 'data', 'esol_selfies.csv'), ...
         fullfile('data', 'esol_selfies.csv'), ...
         'esol_selfies.csv'};
for k = 1:length(tries)
  if exist(tries{k}, 'file')
    datafile = tries{k};
    break;
  end
end
if isempty(datafile)
  error('esol_selfies.csv not found. Change to the morning folder and run again.');
end

% Read the file line by line. Column 1 name, 2 SMILES, 3 SELFIES, 4 solubility.
fid = fopen(datafile, 'r');
header = fgetl(fid);
feat = [];
target = [];
nread = 0;
while true
  line = fgetl(fid);
  if ~ischar(line)
    break;
  end
  parts = strsplit(line, ',');
  if length(parts) < 4
    continue;
  end
  smiles = parts{2};
  selfies = parts{3};
  logS = str2double(parts{4});
  if isnan(logS)
    continue;
  end

  % Twelve numbers, each one a count of something in the text.
  row = [length(smiles), ...
         sum(smiles == 'C'), ...
         sum(smiles == 'c'), ...
         sum(smiles == 'O'), ...
         sum(smiles == 'N'), ...
         sum(smiles == '='), ...
         sum(smiles == '#'), ...
         sum(smiles == '('), ...
         sum(smiles == 'l') + sum(smiles == 'r') + sum(smiles == 'F'), ...
         sum(smiles >= '0' & smiles <= '9'), ...
         sum(selfies == '['), ...
         length(selfies)];

  nread = nread + 1;
  feat(nread, :) = row;
  target(nread, 1) = logS;
end
fclose(fid);

fprintf('read %d molecules from %s\n', nread, datafile);
fprintf('each molecule became %d numbers, counted straight from its text\n\n', size(feat,2));

% Hold some molecules back so the score is honest.
randn('seed', 7);
idx = randperm(nread);
ntrain = round(0.8 * nread);
tr = idx(1:ntrain);
te = idx(ntrain+1:end);

A = [ones(nread,1), feat];
w = pinv(A(tr,:)) * target(tr);

pred_tr = A(tr,:) * w;
pred_te = A(te,:) * w;
r2 = @(y, f) 1 - sum((y-f).^2) / sum((y-mean(y)).^2);

fprintf('R squared on the molecules it was fitted to : %.4f\n', r2(target(tr), pred_tr));
fprintf('R squared on the molecules it never saw     : %.4f\n', r2(target(te), pred_te));
fprintf('typical error: %.3f log units\n\n', sqrt(mean((target(te) - pred_te).^2)));

disp('Counting characters is a crude way to describe a molecule, and it already');
disp('explains most of the solubility. This afternoon you will replace the counts');
disp('with proper chemical descriptors and watch the same solve do better.');

figure;
plot(target(te), pred_te, 'bo', 'markersize', 5); hold on;
lims = [min(target)-0.5, max(target)+0.5];
plot(lims, lims, 'k--', 'linewidth', 1.5);
grid on; axis([lims lims]);
xlabel('measured logS'); ylabel('predicted logS');
title('Solubility of held-out molecules, from counting characters');
hold off;
