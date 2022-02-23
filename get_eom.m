% function to extract end-of-month observations from yield curve. Input
% data with time series in rows.
function monthlydata = get_eom_data(data,dates)
T = length(data);

cleandates = [];
for t = 1:T-1
    if month(dates(t))==month(dates(t+1))
        cleandates = [cleandates t];
    end
end

monthlydata = data;
monthlydata(cleandates,:) =[];
end