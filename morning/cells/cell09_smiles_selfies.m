% Cell 9: SMILES, SELFIES, and a first chemical model
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
