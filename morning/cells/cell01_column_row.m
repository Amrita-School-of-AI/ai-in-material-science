% Cell 1: the column-row (C&R) decomposition
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
