function tests = test_targets
tests=functiontests(localfunctions);
end
function testTranscription(t)
h=historical_targets; verifyEqual(t,height(h.table5),14);
verifyEqual(t,h.table5{1,:},[0 0 1 0 380.9 .31683 200]);
verifyEqual(t,h.table5{end,:},[1 1 1 1 387.45 .41561 566.67]);
verifyEqual(t,size(unique(h.table5{:,1:4},'rows'),1),14);
verifyEqual(t,h.modelIIpaper.Crop,[354.3522;377.8184]);
verifyEqual(t,h.modelIIalternate.Crop,[347.0200;374.8967]);
verifyNotEqual(t,h.modelIIpaper.Stability,h.modelIIalternate.Stability);
verifyEqual(t,h.modelIII.Cost,[10.8093;10.7527]);
end
function testSensitivityArithmetic(t)
h=historical_targets; a=sensitivity_arithmetic(h.table7);
verifyEqual(t,a.stabilityEndpoint,.00288,'AbsTol',1e-13);
verifyEqual(t,a.fieldEndpoint,-.01896,'AbsTol',1e-13);
verifyEqual(t,a.stabilityDifference,-.00578,'AbsTol',1e-13);
verifyEqual(t,a.fieldDifference,.03976,'AbsTol',1e-13);
verifyEqual(t,numel(a.stabilityAdjacent),5);
end
