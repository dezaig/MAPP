%author: J. Roychowdhury, 2012/05/01-08
%Test script to generate characteristics curves for MVS DAAV6 model using MNA Equation engine
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	generate characteristic curves on a DAAV6 NFET driven 
%	by VGS and VDS voltages sources
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%see DAEAPIv6_doc.m for a description of the functions here.
%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Type "help MAPPlicense" at the MATLAB/Octave prompt to see the license      %
%% for this software.                                                          %
%% Copyright (C) 2008-2013 Jaijeet Roychowdhury <jr@berkeley.edu>. All rights  %
%% reserved.                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






MNAEqnEngine_DAAV6_P_N_devices; % DAEAPI script that sets up DAE

if 0 == 1
	% set DC inputs
	DAE = feval(DAE.set_uQSS, 'vgs:::E', 1.2, DAE);
	DAE = feval(DAE.set_uQSS, 'vddN:::E', 1.2, DAE);
	% run DC
	qss = QSS(DAE);
	qss = feval(qss.solve, qss);
	feval(qss.print, qss);
end 

% DC sweep over vdd and vgs 
%dcsweep2 = DC(dae);
%dcsweep2 = solve2(dcsweep2, 'vgs', 0.1, 1.2, 0.1, 'vdd', 0, 1.2, 0.05);
%sol2 = getsolution(dcsweep2);

oidxN = feval(DAE.unkidx, 'vddN:::ipn', DAE);
oidxP = feval(DAE.unkidx, 'vddP:::ipn', DAE);
i = 0; 
IDSNs = [];
IDSPs = [];
VGSs = 0.1:0.1:1.2;
VDSs = 0:0.05:1.2;
for vgs = VGSs
	DAE = feval(DAE.set_uQSS, 'vgsN:::E', vgs, DAE);
	DAE = feval(DAE.set_uQSS, 'vgsP:::E', vgs, DAE);
	i = i+1; j = 0;
	for vdd = VDSs
		DAE = feval(DAE.set_uQSS, 'vddP:::E', vdd, DAE);
		DAE = feval(DAE.set_uQSS, 'vddN:::E', vdd, DAE);
		qss = QSS(DAE);
		qss = feval(qss.solve, qss);
		sol = feval(qss.getsolution, qss);
		j = j+1;
		IDSNs(i,j) = sol(oidxN,1);
		IDSPs(i,j) = sol(oidxP,1);
	end
end

figure;
hold on;
xlabel 'Vds';
ylabel 'Ids';
for i=1:length(VGSs) % step vgs
      toplot = -1000*IDSNs(i,:); % mA
      plot(VDSs, toplot, 'b.-');
end
grid on; axis tight;

display(sprintf('\nINFO: Next, we will overlay Intel 65nm IEDM05 NFET data'));
display('INFO: on the DC sweep simulation.');
display(sprintf('\nINFO: Press Enter/Return to continue:\n'));
pause;


%Check calibration
%Output Id-Vd data from IEDM 05

data=[0.00      0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00
0.05    211.49  195.63  185.56  157.50  129.69  94.29   63.81   35.20   11.90
0.10    419.22  386.75  367.73  311.89  240.38  184.79  117.99  60.17   23.14
0.15    621.35  575.30  500.21  429.11  347.96  254.38  166.26  75.43   28.30
0.20    772.59  703.10  627.23  527.07  423.57  307.06  192.13  90.28   30.19
0.25    920.19  821.60  727.12  608.78  483.24  344.11  209.08  103.71  35.21
0.30    1031.50 938.64  810.97  668.63  525.59  369.89  223.80  108.10  37.74
0.35    1139.10 1025.50 877.52  722.66  558.86  392.79  238.38  119.47  41.75
0.40    1228.80 1093.30 937.12  768.60  588.69  412.71  252.98  128.78  47.09
0.45    1300.80 1147.10 977.51  795.72  613.54  429.37  264.01  135.79  52.44
0.50    1350.70 1188.70 1012.80 821.74  629.67  446.89  278.42  146.82  53.83
0.55    1390.30 1219.40 1036.50 844.64  648.28  457.96  289.21  149.62  58.98
0.60    1428.90 1252.90 1059.40 863.98  665.63  474.42  297.55  157.33  64.15
0.65    1460.90 1277.10 1085.90 881.22  682.97  487.11  310.57  162.86  64.15
0.70    1489.50 1300.00 1103.00 898.74  695.81  499.44  317.09  169.99  70.27
0.75    1510.90 1322.20 1121.40 917.60  710.65  512.24  330.59  173.59  72.44
0.80    1531.60 1338.30 1141.70 931.78  720.96  522.04  335.85  186.25  77.59
0.85    1550.20 1358.90 1159.40 945.82  739.52  533.38  348.35  191.71  83.13
0.90    1569.10 1373.10 1173.90 964.88  750.17  545.17  356.59  200.71  86.79
0.95    1588.40 1392.30 1189.00 978.77  760.94  559.21  369.81  206.10  92.54
1.00    1603.20 1406.00 1204.80 990.78  773.46  569.82  376.74  215.18  94.82
1.05    1619.20 1421.30 1215.40 1004.30 786.84  577.12  384.82  220.33  98.11
1.10    1636.20 1437.60 1228.30 1016.50 801.68  591.62  395.81  228.97  105.51
1.15    1653.40 1451.00 1242.70 1030.80 814.94  605.03  403.35  235.62  108.40
1.20    1675.60 1470.20 1250.50 1036.60 831.51  611.17  412.83  245.36  120.42];

hold on
plot(data(:,1), data(:,2:end)*1e-3, 'r.-')
title 'daaV6 NFET with d/s resistors: blue: DAAV6-ModSpec/DAEAPI, red: IEDM05 measurement';
grid on; axis tight;



% PFET plots
figure;
hold on;
xlabel 'Vds';
ylabel 'Ids';
for i=1:length(VGSs) % step vgs
      toplot = -1000*IDSPs(i,:); % mA
      plot(-VDSs, toplot, 'b.-');
end
grid on; axis tight;

display(sprintf('\nINFO: Next, we will overlay Intel 65nm IEDM05 PFET data'));
display('INFO: on the DC sweep simulation.');
display(sprintf('\nINFO: Press Enter/Return to continue:\n'));
pause;

%Output Id-Vd data from IEDM 05
% data from IEDM 05
data=[-1.20715,0.000942,0.000720812,0.000502689,0.000274449,8.14912e-05
-1.19966,0.000932,0.000719293,0.000500969,0.00027311,8.0628e-05
-1.16662,0.000922539,0.000712593,0.000493379,0.000267201,7.6818e-05
-1.12254,0.000909387,0.000703655,0.000483254,0.000259317,7.17357e-05
-1.0927,0.000900483,0.000697604,0.000476599,0.000253981,7.17064e-05
-1.06074,0.000892823,0.000689748,0.000469549,0.000248726,7.1675e-05
-0.991591,0.000876251,0.000671456,0.000455847,0.000238775,6.44971e-05
-0.936063,0.000862943,0.000656766,0.000445915,0.000229197,5.92488e-05
-0.909229,0.00085496,0.000649667,0.000438806,0.000224568,5.69797e-05
-0.84686,0.00083624,0.000633168,0.000422283,0.000216728,5.33539e-05
-0.80108,0.000822499,0.000621057,0.000410814,0.000210176,4.98597e-05
-0.754783,0.000808552,0.000608809,0.000399941,0.000203226,4.60036e-05
-0.668435,0.000777293,0.000585966,0.000382082,0.000187551,4.11738e-05
-0.650156,0.000770553,0.00058113,0.000378073,0.000184232,3.99269e-05
-0.609527,0.000751915,0.000570382,0.000369163,0.000177501,3.65429e-05
-0.573295,0.000733739,0.000557911,0.000361192,0.000172494,3.35251e-05
-0.504255,0.000697847,0.000534023,0.000345822,0.000162954,3.01919e-05
-0.473738,0.000681983,0.000521906,0.000337597,0.000156193,2.87185e-05
-0.444444,0.000666754,0.000510275,0.000329702,0.000149704,2.7508e-05
-0.408178,0.000640643,0.000494696,0.000317854,0.000141669,2.60094e-05
-0.34546,0.000587324,0.000461817,0.000294435,0.000131281,2.34554e-05
-0.267069,0.000507232,0.000392855,0.000259255,0.000116241,2.04725e-05
-0.235555,0.000473482,0.000360884,0.000240824,0.000107634,1.92733e-05
-0.198515,0.000414973,0.000321524,0.000219161,9.72414e-05,1.6632e-05
-0.153522,0.000343905,0.000269889,0.000180048,8.21127e-05,1.3159e-05
-0.13344,0.000301,0.000239273,0.00016259,7.36672e-05,1.16088e-05
-0.106411,0.00024325,0.000196126,0.000136323,6.19535e-05,9.52231e-06
-0.0853718,0.000198301,0.000162543,0.000115878,5.08838e-05,7.01339e-06
-0.0752331,0.000174677,0.000142431,0.000106025,4.55492e-05,5.80432e-06
-0.0514077,0.000116715,9.51689e-05,7.24484e-05,3.30132e-05,2.96307e-06
-0.0,-8.34956e-06,-6.80753e-06,2.1684e-19,-2.35911e-06,-3.16744e-06];
data=data*1e3;

hold on;
plot(data(:,1)*1e-3, data(:,2:end), 'r.-');

grid on; axis tight;
title 'daaV6 PFET with d/s resistors: blue: DAAV6-ModSpec/DAEAPI; red: IEDM05 measurement';
