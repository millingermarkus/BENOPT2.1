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

function [gamsOut,g]   =   gamsRun(s,f,g,scenario,noScenarios,gamsTemp,version)

% Start GAMS function
error=1;
runComplete=0;
while error==1 && runComplete==0
    if contains(version,'ghgMax')
        gamsTemp.ghgTarget.val  = 1;
        gamsTemp.solveOption.val  = 0;
        solName = ['matsol' num2str(scenario) '1'];
    elseif contains(version,'costMin')
        gamsTemp.solveOption.val  = 1;
        solName = ['matsol' num2str(scenario) '2'];
    end
    
    wgdx('matdata.gdx',g.d,g.C,g.I,g.J,g.F,g.B,g.BR,g.BF,g.tb,g.ts,g.fuelType,g.PwrSrc,g.PwrMix,g.PwrRes,...
        g.tDiesel,g.tEtOH,g.tCH4,g.tLNG,g.tH2,g.tEV,g.tAviationFuel,...
        gamsTemp.costMarg,...
        gamsTemp.costInv,...
        gamsTemp.costInvLevel,...
        gamsTemp.ghgEmisFeed,...
        gamsTemp.ghgEmisT1,...
        gamsTemp.ghgEmisGateWheel,...
        gamsTemp.powerMixEmis,...
        gamsTemp.ghgRef,...
        gamsTemp.residualLoad,...
        gamsTemp.convEta,...
        gamsTemp.convEtaBiomSpec,...
        gamsTemp.capF,...
        gamsTemp.cap0,...
        gamsTemp.demand,...
        gamsTemp.bioResPot,...
        gamsTemp.bioResPotImport,...
        gamsTemp.resImportMax,...
        gamsTemp.landDmdPJ,...
        gamsTemp.landMax,...
        gamsTemp.feedLandUseInit,...
        gamsTemp.heatByprod,...
        gamsTemp.biomassPrice,...
        gamsTemp.powerPrice,...
        gamsTemp.heatPrice,...
        gamsTemp.powerInput,...
        gamsTemp.heatInput,...
        gamsTemp.biomassPriceImport,...
        gamsTemp.lifeT,...
        gamsTemp.historicFuelDemand,...
        gamsTemp.newVehicSharePass,...
        gamsTemp.CO2input,...
        gamsTemp.CO2source,...
        gamsTemp.CO2price,...
        gamsTemp.H2input,...
        gamsTemp.ghgTarget,...
        gamsTemp.dMax,...
        gamsTemp.H2Max,...
        gamsTemp.CH4Max,...
        gamsTemp.LCH4Max,...
        gamsTemp.ghgRefCO2,...
        gamsTemp.pwrMixMax,...
        gamsTemp.vehicleKMroadTot,...
        gamsTemp.MJperKMavgICEV,...
        gamsTemp.relativeFuelEconomy,...    gamsTemp.vehicleCostPerGJfuel,...
        gamsTemp.posResLoad,...
        gamsTemp.solveOption);
    
    tic
    system(['gams benopt.gms gdx=' solName]); %lo=3
    toc
    
    % Test if problem is infeasible or run was faulty
    statstr.name    =   'returnstat';
    gamsOut.stat    =   rgdx(solName, statstr);
    if isequal(size(gamsOut.stat.val),[1 2])
        runComplete = 1;
        if gamsOut.stat.val(1,1)~=1  || gamsOut.stat.val(1,2)~=1
            error = 1;
            disp('infeasible - rerun')
        else
            error = 0;
        end
    else
        runComplete = 0;
        disp('run faulty - rerun')
    end
end

% %     if gamsOut.stat.val(1,1)~=1
%         if stat.val(1,1)~=1  || stat.val(1,2)~=1
%             error('Problem infeasible!')
%         end
%     end

% Import results from GAMS

TS2str.uels = {s.techNames, s.sectorNames};
TS2str.name = 'TS';
TS2str.form = 'full';
TS2data = rgdx(solName, TS2str);

g.TS2=cell(1,10);
for j=1:s.numSectors
    g.TS2{j}=transpose(find(TS2data.val(:,j)==1));
end

prdstr.uels = {strsplit(num2str(s.year)), s.techNames, s.sectorNames};
prdstr.name = 'prd';
prdstr.form = 'full';
prd = rgdx(solName, prdstr);
gamsOut.prd=prd.val;

inststr.uels = {strsplit(num2str(s.year)), s.techNames};
inststr.name = 'inst';
inststr.form = 'full';
instCap = rgdx(solName, inststr);
gamsOut.instCap=instCap.val;

coststr.name = 'cost';
coststr.form = 'full';
cost = rgdx(solName, coststr);
gamsOut.cost=cost.val;

costAnnualstr.uels = {strsplit(num2str(s.year))};
costAnnualstr.name = 'costAnnual';
costAnnualstr.form = 'full';
costAnnual = rgdx(solName, costAnnualstr);
gamsOut.costAnnual=costAnnual.val;

feedstr.uels = {strsplit(num2str(s.year)), s.techNames, f.feedNames, g.cats};
feedstr.name = 'feedUse';
feedstr.form = 'full';
feedUse = rgdx(solName, feedstr);
gamsOut.feedUse=feedUse.val;

feedImportstr.uels = {strsplit(num2str(s.year)), s.techNames, f.feedNames};
feedImportstr.name = 'feedUseImport';
feedImportstr.form = 'full';
feedUseImport = rgdx(solName, feedImportstr);
gamsOut.feedUseImport=feedUseImport.val;

capstr.uels = {strsplit(num2str(s.year)), s.techNames};
capstr.name = 'cap';
capstr.form = 'full';
capCAP = rgdx(solName, capstr);
gamsOut.capCAP=capCAP.val;

costTechstr.uels    =   {strsplit(num2str(s.year)), s.techNames};
costTechstr.name    =   'costTech';
costTechstr.form    =   'full';
costTech            =   rgdx(solName, costTechstr);
gamsOut.techCost    =   costTech.val; %unit: M€ /year

ghgAbateTechstr.uels    =   {strsplit(num2str(s.year)), s.techNames};
ghgAbateTechstr.name    =   'ghgAbateTech';
ghgAbateTechstr.form    =   'full';
ghgAbateTech            =   rgdx(solName, ghgAbateTechstr);
gamsOut.ghgAbateTech    =   ghgAbateTech.val; %unit: ktCO2eq
%
%     capFoutstr.uels    =   {strsplit(num2str(s.year)), s.techNames};
%     capFoutstr.name    =   'capFout';
%     capFoutstr.form    =   'full';
%     capFout            =   rgdx(solName, capFoutstr);
%     gamsOut.capFout    =   capFout.val;

powerResUsestr.uels = {strsplit(num2str(1:1:max(g.timeStepsIntraYear))), strsplit(num2str(s.year))};
powerResUsestr.name = 'residualLoadUse';
powerResUsestr.form = 'full';
powerResUse         = rgdx(solName, powerResUsestr);
gamsOut.powerResUse = powerResUse.val;

dispatchPrdstr.uels = {strsplit(num2str(s.year)), strsplit(num2str(1:1:max(g.timeStepsIntraYear))), s.techNames, s.sectorNames};
dispatchPrdstr.name = 'prdDaily';
dispatchPrdstr.form = 'full';
dispatchPrd         = rgdx(solName, dispatchPrdstr);
gamsOut.dispatchPrd = dispatchPrd.val;

CO2Usestr.uels = {strsplit(num2str(s.year))};
CO2Usestr.name = 'CO2use';
CO2Usestr.form = 'full';
CO2Use = rgdx(solName, CO2Usestr);
gamsOut.CO2Use=CO2Use.val;

if contains(version,'ghgMax')
    ghgAbatementstr.name = 'ghgAbatement';
    ghgAbatementstr.form = 'full';
    ghgTarget = rgdx(solName, ghgAbatementstr);
    gamsOut.ghgTarget=ghgTarget.val;
end

%%
% Densing results

%Dispatch (year,timeStep,tech)
gamsOut.dispatchPrd2    =   sum(gamsOut.dispatchPrd,4);

% Energy production (time,tech) [PJ]
gamsOut.prd2 = (sum(gamsOut.prd,3).*s.powerByprod+sum(gamsOut.prd,3).*s.heatByprod); %3 to 2 dimensions sorted by techs

% Energy production (time,market) [PJ]
%     o.prd4 = sum(sum(o.prd3,2),1); %2 to 1 dimension, sorted by markets

% Biomass Use (time,tech) [PJ]
gamsOut.feedUse2 = squeeze(sum(sum(gamsOut.feedUse,4),3)); %4 to 2 dimensions sorted by techs

% Biomass Use (time,biomass Type) [PJ]
gamsOut.feedUse3 = squeeze(sum(sum(gamsOut.feedUse,2),4)); %4 to 2 dimensions sorted by biomass

% Biomass Use (time, tech, biomass) [PJ]
gamsOut.feedUse4 = squeeze(sum(gamsOut.feedUse,4)); %4 to 3 dimensions

% Biomass Use Import (time,tech) [PJ]
gamsOut.feedUseImport2 = squeeze(sum(gamsOut.feedUseImport,3)); %3 to 2 dimensions sorted by techs

% Biomass Use Import (time,biomass Type) [PJ]
gamsOut.feedUseImport3 = squeeze(sum(gamsOut.feedUseImport,2)); %3 to 2 dimensions sorted by biomass

%%Correcting total demand in PJ by the fuel economy per km
indexEl                        =   find(contains(s.techNames,{'BEV'}));
indexH2                        =   find(contains(s.techNames,{'FCEV'}));
gamsOut.DemandRoadPass    =   g.Demand(6,:)-s.relativeFuelEconomy(indexEl).*(gamsOut.prd(:,indexEl,6))'+(gamsOut.prd(:,indexEl,6))';
gamsOut.DemandRoadPass    =   gamsOut.DemandRoadPass-s.relativeFuelEconomy(indexH2).*(gamsOut.prd(:,indexH2,6))'+(gamsOut.prd(:,indexH2,6))';

for sector = 1:11
    gamsOut.DemandAdapt(sector,:)   =   g.Demand(sector,:)-s.relativeFuelEconomy(indexH2,sector).*(gamsOut.prd(:,indexH2,sector))'+(gamsOut.prd(:,indexH2,sector))'...
        -s.relativeFuelEconomy(indexEl,sector).*(gamsOut.prd(:,indexEl,sector))'+(gamsOut.prd(:,indexEl,sector))';%+((gamsOut(scenario).prd(:,indexH2,sector))*(1-s.relativeFuelEconomy(indexH2)))';
end
end