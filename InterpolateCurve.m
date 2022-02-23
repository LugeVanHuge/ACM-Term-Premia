% Linearly interpolate yields from bootstrapped curves

function curve_interp = InterpolateCurve(curve_given,mats_given,nvec)
    
    % initialise array for interpolated yields
    curve_interp = zeros(size(curve_given,1),length(nvec));

    % fill in yields that are already given at specified maturities
    for i = 1:length(nvec)
        if ismember(nvec(i),round(mats_given))
            j = find(round(mats_given)==nvec(i));
            curve_interp(:,i) = curve_given(:,j);
        end
    end
    given = find(sum(curve_interp,1)~=0);   % column indices of yields with given observations
    interp = find(sum(curve_interp,1)==0);   % ditto yields to be interpolated
    % interpolate for yields not given
    for row = 1:size(curve_interp,1)
        curve_interp(row,interp)=interp1(nvec(given),curve_interp(row,given),interp);
    end
end