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
% Monte carlo sensitivity analysis with optional parallel computing
%

function monteCarlo(iter,s,f,g,techDataIn)
%     [mcVar,weatherYear,H2,runTimeGAMS,timeSteps,EVfactor,dRate,CO2source,H2max,landMax,CO2Use]
% delete(gcp)
delete(gcp('nocreate'))
parpool('local',2)
%%Monte Carlo Simulation
% par
parfor simNum=1:iter
    
    %First, create sliced variables, which can run in parallel. All input
    %variables need new variable names. Only first order brackets work
    %a(exam).subVar, NOT a.subVar(exam)
    a                           =   s;
    b                           =   f;
    c                           =   g;
    techData                =   techDataIn;
    
    
    %Set variables
    [b,c,a]                         =   setData(techData,b,c,a);
        
    c.timeStepsIntraYear        =   1:50;%(1+randi(49));
    a.EVfactor                  =   0.8+0.2*rand;    
    a.discountRateInvest        =   0 + 0.1*rand;
    a.co2source                 =   a.co2source.*linspace(0,(0.1+0.2*rand),s.runTime);
    H2maxtemp                   =   linspace(0,0+0.3*rand,s.runTime);   %Share of market
    CH4maxtemp                  =   linspace(0,0+0.3*rand,s.runTime);   %Share of market
    LCH4maxtemp                 =   linspace(0,0+0.3*rand,s.runTime);   %Share of market
    c.H2maxShipping             =   H2maxtemp;
    c.H2maxGoods                =   H2maxtemp;
    c.H2maxAviation             =   H2maxtemp./3;
    
    c.CH4maxGoods               =   CH4maxtemp;
    c.LCH4maxShipping           =   LCH4maxtemp;
    c.LCH4maxGoods              =   LCH4maxtemp;
    
    c.landMax                   =   10^6.*linspace(1.5,0.5,s.runTime);   %ha
    a.weatherYear               =   randi(3);

    a.onShore                   =   round(linspace(55,100+rand*100,7));
    a.offShore                  =   round(linspace(6,30+rand*40,7));
    a.photoV                    =   round(linspace(54,100+rand*150,7));
    a.powerStorage              =   linspace(9000,9000+rand*21000,7);
    a.powerStorageMax           =   linspace(66000,66000+rand*44000,7);
    a.demandPower               =   round(linspace(502,500+rand*200,7));

    [residualLoad,powerYear,a.RENshare,a.RENshare100]   =   vrePower(a.onShore,...
        a.offShore,a.photoV,a.powerLoad,a.demandPower,a.MustRun,...
        a.RENMustRun,a.powerStorage,a.powerStorageMax,a.PVcapFacInst,a.WindOncapFacInst,a.WindOffcapFacInst);
    
    [a.surplusPowerVar,a.surplusPowerVar2,a.posResLoad,a.resLoadDataHour]   =   surplusPower(c,a,residualLoad,powerYear);
    
    %Calculate GHG emissions
    [a,b]                           =   ghgEmissions(a,b);
    
    %Setting dispatchable power demand as upper limit in power sector and
    %passenger road transport demand
    c.Demand(4,:)                   =   sum(a.posResLoad,1).*3.6;
    c.Demand(6,:)                   =   a.demLand;
    
    % Call function for feed cost development
    [a,b]                           =   feedCost(a,b);
    
    % OPEX & CAPEX calculation
    [d,e]       =   costDevNoLearning(a,b);
    
    % Define GAMS parameters
    [gamsTemp,c]                    =   gamsVar(a,b,d,e,simNum,c,techData);
    
    % Run GAMS GHG abatement maximization  (the GAMS call has to be 
    % modified to work in parallel as currently only one .gdx file per 
    % GAMS-file is allowed)
    [gamsOutGHG,c]           =   gamsRun(a,b,c,simNum,iter,gamsTemp,'ghgMax');
    
    %Set GHG budget for cost minimization
    gamsTemp.ghgTarget.val      =   0.8*gamsOutGHG.ghgTarget;
    
    % Run GAMS cost minimization
    [gamsOutCost,c]                  =   gamsRun(a,b,c,simNum,iter,gamsTemp,'costMin');
    
%     runTimeGAMS(simNum)         =   toc;
    mcVar(simNum)               =   gamsOutCost;
    costTot(simNum)             =   mcVar(simNum).cost;
    ghgTarget(simNum)           =   0.9*gamsOutGHG.ghgTarget;
    ghgMax(simNum)              =   gamsOutGHG.ghgTarget;
%     timeSteps(simNum)           =   max(c.timeStepsIntraYear);
%     dRate(simNum)               =   a.discountRateInvest;
%     CO2source(simNum)           =   a.co2source(end);
%     H2max(simNum)               =   c.H2maxShipping(end)*a.demShip(end)+c.H2maxGoods(end)*a.demGoodsLand(end)+c.H2maxAviation(end)*a.demAviation(end);
%     CH4max(simNum)              =   (c.CH4maxShipping(end)+c.LCH4maxShipping(end))*a.demShip(end)...
%                                     + (c.CH4maxGoods(end)+c.LCH4maxGoods(end))*a.demGoodsLand(end); % combining CH4 and LCH4 shares
%     LCH4max(simNum)             =   c.LCH4maxShipping(end)*a.demShip(end)+c.LCH4maxGoods(end)*a.demGoodsLand(end)+c.LCH4maxAviation(end)*a.demAviation(end);
%     landMax(simNum)             =   c.landMax(end);   %ha
    weatherYear(simNum)         =   a.weatherYear;
%     CO2Use(simNum)              =   mcVar(simNum).CO2Use(end);
    renShare(simNum)            =   a.RENshare(7);
    onShore(simNum)             =   a.onShore(7);
    offShore(simNum)            =   a.offShore(7);
    photoV(simNum)              =   a.photoV(7);
    demandPower(simNum)         =   a.demandPower(7);
    
    powerStorage(simNum)        =   a.powerStorage(7);
    powerStorageMax(simNum)     =   a.powerStorageMax(7);
    surplusPower2050(simNum)     =   sum(a.surplusPowerVar(:,31));
%     H2(simNum)        =   sum(mcVar(simNum).prd2(:,c.techbiomass(:,b.numFeed+b.numResidue+2)==1),'all');
%     bioFuels(simNum)            =   sum(mcVar(simNum).prd2(:,c.techbiomass(:,b.numFeed+b.numResidue+2)==0),'all'); %deduct electrofuels non-intermediates
end
%%
plotRow=4;
plotCol=4;
figure()
mCplot(iter,photoV,renShare,'PV','RE',plotRow,plotCol,1,'scatter')
mCplot(iter,onShore,renShare,'WindOn','RE',plotRow,plotCol,2,'scatter')
mCplot(iter,offShore,renShare,'WindOff','RE',plotRow,plotCol,3,'scatter')
mCplot(iter,demandPower,renShare,'PwrDem','RE',plotRow,plotCol,4,'scatter')
mCplot(iter,powerStorage,renShare,'Storage','RE',plotRow,plotCol,5,'scatter')
mCplot(iter,powerStorageMax,renShare,'StoreMax','RE',plotRow,plotCol,6,'scatter')
mCplot(iter,weatherYear,renShare,'WeatherYear','RE',plotRow,plotCol,7,'violin')
i=8;

mCplot(iter,weatherYear,surplusPower2050,'WeatherYear','surplus',plotRow,plotCol,i+1,'violin')
mCplot(iter,renShare,surplusPower2050,'RE','surplus',plotRow,plotCol,i+2,'scatter')

i=12;
mCplot(iter,weatherYear,ghgMax,'WeatherYear','ghgMax',plotRow,plotCol,i+1,'violin')
mCplot(iter,renShare,ghgMax,'RE','ghgMax',plotRow,plotCol,i+2,'scatter')
mCplot(iter,renShare,surplusPower2050,'RE','surplus',plotRow,plotCol,i+3,'scatter')

picName=['../fig/monteCarloScatterFuels'];
set(gcf,'Position',[0 0 900 600])
set(gcf,'PaperUnits','points','PaperPosition',[0 0 900 600],'PaperPositionMode','auto');
print(gcf,'-painters','-depsc','-loose',picName)
saveas(gcf,picName,'tif')

% save(['monteCarloData' datestr(now,'yymmddhhMM') '.mat'])
% figure(87558)
% for simNum=1:iter
%     plot(mcVar(simNum).cost,ghgTarget(simNum),'.')
%     hold on
%     title('Cost vs GHG target','FontSize',18);       
%     ylabel('GHG (Mt)')
%     xlabel('Cost')
%             
%             if simNum==iter
%                 picName=['figures/monteCarloCostGHG'];
%                 set(gcf,'Position',[0 0 400 400])
%                 set(gcf,'PaperUnits','points','PaperPosition',[0 0 400 400],'PaperPositionMode','auto');
%                 print(gcf,'-painters','-depsc','-loose',picName)
%                 saveas(gcf,picName,'tif')
%             end
% end