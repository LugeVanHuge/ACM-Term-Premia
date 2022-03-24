% Fit NSS model to observed yield curve using constant loading parameters.
% Input yield curve with T rows and N columns.

function NSS_params = NSS_fitting(yieldcurve,n_vec)
    T = size(yieldcurve,1);
    N = size(yieldcurve,2);
    
    % Inline functions
    % factor loadings
    L1 = ones(1,N);  % level
    L2 = @(lambda_1) (1-exp(-lambda_1.*n_vec))./(lambda_1.*n_vec); % slope
    L3 = @(lambda_1) L2(lambda_1)-exp(-lambda_1.*n_vec);   % curvature 1
    L4 = @(lambda_2) (1-exp(-lambda_2.*n_vec))./(lambda_2.*n_vec)-...
                                exp(-lambda_2.*n_vec);   % curvature 2
    % NSS yield function
    % params = [lamba_1 lambda_2 beta_0 beta_1 beta_2 beta_3] (Tx6 array)
    NSS_yield = @(params) L1.*params(:,3)+L2(params(:,1)).*params(:,4)+...
        L3(params(:,1)).*params(:,5)+L4(params(:,2)).*params(:,6);
    % objective function
    err = @(params) sum(sum((yieldcurve-NSS_yield(params)).^2));
    % optimisation
    options = optimoptions(@fminunc,'StepTolerance',5e-4,...
        'MaxFunctionEvaluations',1e6,'MaxIterations',1e4);
    params_guess = ones(T,6)*0.05;
    NSS_params = fminunc(err,params_guess,options);
end