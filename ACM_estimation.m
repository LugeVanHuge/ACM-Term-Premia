% Perform term premium decomposition as per the ACM method.
% K = no. factors from PCA.
% Input yield curve with T columns (time) and N rows (maturity)
% Input nvec, tvec as vectors of maturities, time series respectively, both
% in months.

function [term_prem,yields_fitted,yields_rn] = ACM_estimation(K,nvec,tvec,yieldcurve)
%% Parameters
N = length(nvec)-1;
T = length(tvec)-1;

%% PCA
[~,PCs,PC_coeffs] = pca(yieldcurve'); % PCA
PC_weights = PC_coeffs./sum(PC_coeffs);
X = PCs(:,1:K)';    % state variables

%% Compute excess returns
rf = yieldcurve(1,:);   % 1-month yield as risk-free short rate
% bond prices
P = exp(-nvec'.*yieldcurve);
% 1-month holding returns
h = log(P(1:end-1,2:end))-log(P(2:end,1:end-1));
% excess returns
e = h-rf(1:end-1)*1/12;

%% Estimate VAR(1) parameters
Xl = X(:,1:end-1);  % lagged pricing factors, t = t_0:T-1
Xc = X(:,2:end);    % contemporaneous factors , t = t_1:T
Phi = zeros(K,K);
mu = zeros(K,1);
for k = 1:K
    y = Xc(k,:)';
    R1 = [ones(T,1),Xl(k,:)'];
    est1 = (R1'*R1)\R1'*y;    % OLS regression
    mu(k) = est1(1);
    Phi(k,k) = est1(2);
end
V = Xc-(mu+Phi*Xl);   % residuals (shocks)
Sigma = V*V'/T;

%% Estimate return pricing parameters
% group regressors
R2 = [ones(T,1) V' Xl']';
% estimate parameters
est2 = e*R2'*inv(R2*R2');
a = est2(:,1);
beta = est2(:,2:2+K-1)';
c = est2(:,2+K:end);
E = e-(a*ones(1,T)+beta'*V+c*Xl);
% estimate parameters for next step
sigma = sqrt(trace(E*E')/(N*T));
B_star = zeros(K^2,N);
for i=1:N
    b_star = beta(:,i)*beta(:,i)';
    B_star(:,i) = b_star(:);
end
B_star = B_star';

%% Estimate price of risk parameters
lambda_0 = (beta*beta')\beta*(a+...
    1/2*(B_star*Sigma(:)+sigma^2*ones(N,1)));
lambda_1 = (beta*beta')\beta*c;
Lambda = Sigma^(-1/2)*(lambda_0+lambda_1*Xc);

%% Estimate short rate parameters
R3 = [ones(T,1) Xc']; % group regressors
est3 = (R3'*R3)\R3'*(rf(2:end)/12)';
delta_0 = est3(1);
delta_1 = est3(2:end);

%% Determine ATS bond pricing parameters
% subscript rn denotes risk-neutral pricing parameters
A = zeros(N,1);
A(1) = -delta_0;
A_rn = A;
B = zeros(K,N);
B(:,1) = -delta_1;
B_rn = B;
for i=2:N
    A(i) = A(i-1)+B(:,i-1)'*(mu-lambda_0)+...
        1/2*(B(:,i-1)'*Sigma*B(:,i-1)+sigma^2)-delta_0;
    A_rn(i) = A_rn(i-1)+B_rn(:,i-1)'*mu+...
        1/2*(B_rn(:,i-1)'*Sigma*B_rn(:,i-1)+sigma^2)-delta_0;
    B(:,i) = (B(:,i-1)'*(Phi-lambda_1)-delta_1')';
    B_rn(:,i) = (B_rn(:,i-1)'*Phi-delta_1')';
end

%% Determine model-implied yields and term premium
yields_fitted = -1./nvec(1:end-1)'.*(A+B'*X);
yields_rn = -1./nvec(1:end-1)'.*(A_rn+B_rn'*X);    % risk-neutral yields
term_prem = yields_fitted-yields_rn;    % estimated term premium
e_fitted = A(1:end-1)+B(:,1:end-1)'*Xc+A(2:end)-...
    B(:,2:end)'*Xl+A(1)+B(:,1)'*Xl;     % model-implied excess returns

end