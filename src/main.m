%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BENOPT (BioENergy OPTimisation model)
%     Copyright (C) 2012-2020 Markus Millinger
%
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
%
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
%
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <https://www.gnu.org/licenses/>.
%
% Contact: markus.millinger@ufz.de
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Start function for the model
%

clearvars;
close all;

%% Data Import

% Conversion options, biomass crops and residues and other data
% techData                =   ...
%   importdata('../data/BENOPT_inputData_200409.xls'); %Save to variable - comment out if the .mat-file is up to date
% save('../data/techData.mat','techData'); %Save to .mat-file - comment out if the .mat-file is up to date
techData                    =   ...
    importdata('../data/techData.mat'); %reads data from .mat file

%Set NaN data to zero
techData.data.techInputData(isnan(techData.data.techInputData))             =   0;
techData.data.feedstockInputData(isnan(techData.data.feedstockInputData))   =   0;

%% Scenario parameter calculation and optimisation in GAMS

noScenarios                 =   2;
for scenario                =   1:noScenarios
    
    %Clear variables for each scenario loop
    %(f=feedstock, g=gams related variables, s=technologies, gamsTemp=gams variables)
    clear matdata.gdx;
    clear gamsTemp;
    clear g;
    clear f;
    clear s;
    
    %Set some dimensions
    s.numTech                   =   size(techData.data.techInputData(1,:),2); 
    s.numSectors                =   11;
    f.numResidue                =   12;
    f.numCrop                   =   size(techData.data.feedstockInputData(1,1:end),2);
        
    %Some general variables
    s.inflation                 =   0;
    s.plantPayBackTime          =   20;
    s.dieselCostStart           =   0.9; %€/l
    s.referenceGHGemission      =   94.1; %kgCO2/GJ
    s.priceDevFactor            =   0.04; % frac/a
    
    f.wheatPriceStart           =   189;% %€/tFM
    f.rapeSeedPriceStart        =   381;% %€/tFM
    s.erePriceShare             =   0.7; %Excess electricity price (share of power mix price) [0,1] (1=same price as power mix)
    
    s.runTime                   =   2051-2020;
    
    %How many time steps within each year - up to 8760 possible (heavy on run-time)
    g.timeStepsIntraYear        =   1:50;

    %Set country specific data
    countryID                   =   'DE';
    s.weatherYear               =   {'2017'};
    fileID = ['../data/powerData' strjoin([countryID s.weatherYear],'_') '.mat'];
    
    if isfile(fileID)
        powerDataCountry        =   ... %reads data from .mat file
            importdata(fileID); 
    else 
        %Read power system data for each region in 60 min resolution
        powerData               =   readtable('../data/time_series_60min_singleindex.csv');
        powerDataCountry        =   ... %Save to .mat-file
            powerData(contains(powerData.cet_cest_timestamp,s.weatherYear),...
            contains(powerData.Properties.VariableNames,countryID));
        save(fileID,'powerDataCountry'); 
    end
    
    % Set country-specific data
    % Make sure the initial capacity for solar PV and On- and offshore wind
    % are correct, as the capacity factor is based on this unless capacity
    % data is available in the open power system data
    [f,g,s]                     =   ...
        setCountryData(techData,countryID,powerDataCountry,s,f,g); %Set country specific data
    
    %Set all other parameters
    [f,g,s]                     =   setData(techData,f,g,s);
        
    %% Monte Carlo sensitivity analysis example of VRE module
%     monteCarlo(1000,s,f,g,techData);

    %% Scenario loop
    switch scenario
        case 1 %Base scenario
        case 2 %No arable land for energy crops
            g.landMax                           =   10^6.*linspace(0,0,s.runTime);   %ha
    end
    
    %Calculation of hourly residual load and other power metrics
    [residualLoad,powerYear,s.RENshare,s.RENshare100]   =   ...
        vrePower(s.onShore,...
        s.offShore,s.photoV,s.powerLoad,s.demandPower,s.MustRun,...
        s.RENMustRun,s.powerStorage,s.powerStorageMax,s.PVcapFacInst,...
        s.WindOncapFacInst,s.WindOffcapFacInst);
    
    %Calculation of surplus power (TWh) per year and time step
    [s.surplusPowerVar,s.surplusPowerVar2,s.posResLoad,s.resLoadDataHour]   =   ...
        surplusPower(g,s,residualLoad,powerYear);
    
    %Setting dispatchable power demand as upper limit in power sector and
    %passenger road transport demand
    g.Demand(4,:)                   =   sum(s.posResLoad,1).*3.6;
    g.Demand(6,:)                   =   s.demLand;
    
    % Call function for feed cost development
    [s,f]                           =   feedCost(s,f);
    
    %Calculate GHG emissions
    [s,f]                           =   ghgEmissions(s,f);
    
    % OPEX & CAPEX calculation
    [o(scenario),p(scenario)]       =   costDevNoLearning(s,f);
    
    % Define GAMS parameters
    [gamsTemp,g]                    =   ...
        gamsVar(s,f,o(scenario),p(scenario),scenario,g,techData);
    
    % Run GAMS
    [gamsOut(scenario),g]           =   ...
        gamsRun(s,f,g,scenario,noScenarios,gamsTemp,'ghgMax');
    
    %% Iterate pareto
    noPareto = 2;
    
    % Set the GHG target vector (as share of max. achievable GHG abatement
    % from GHG optimization)
    iterStep =  [0.99,0.95,0.85,0.7,0.5,0.6];
    
    for paretoIter=1:noPareto
        gamsTemp.ghgTarget.val          =   ...
            iterStep(paretoIter)*gamsOut(scenario).ghgTarget;
        
        [paretoTemp,g]                  =   ...
            gamsRun(s,f,g,scenario,noScenarios,gamsTemp,'costMin');
        paretoVar(scenario,paretoIter)  =   paretoTemp;
    end
end

%% Plotting
plotting(s,f,o,p,g,gamsOut,noScenarios,paretoVar,noPareto,iterStep)
