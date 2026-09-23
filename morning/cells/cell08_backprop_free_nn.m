% Cell 8: a neural network trained without backpropagation
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
