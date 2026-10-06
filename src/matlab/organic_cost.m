function value = organic_cost(s, duration, convention)
% C42 line105 / Cellular_Automata_demo cost block; paper (30) conflicts.
% s=[OFU BPC PWC PPC]. Named source accounting, arbitrary cost units.
validateattributes(s,{'numeric','logical'},{'size',[1 4],'binary'});
validateattributes(duration,{'numeric'},{'scalar','finite','nonnegative'});
switch convention
    case 'c42', pestCost=12; weedPeriod=6;
    case 'ca', pestCost=15; weedPeriod=6;
    case 'documented_notes', pestCost=15; weedPeriod=3;
    otherwise, error('task4:cost','Unknown cost convention');
end
value = duration*s(1)/6 + (200+2*duration/3)*s(2) ...
    + 5*duration/weedPeriod*s(3) + pestCost*duration/6*s(4);
end
