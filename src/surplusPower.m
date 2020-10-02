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
% Function for adapting excess electricity to a lower temporal resolution
% 

function [surplusPowerVar,surplusPowerVar2,posResLoadVar,resLoadDataHour]   =   surplusPower(g,s,residualLoad,powerYear)

resLoadDataHour                     =   sort(residualLoad(1:end,1:end),'descend')./1000000; %TW
% posResLoadDataHour                          =   resLoadDataHour;
% posResLoadDataHour(posResLoadDataHour<0)    =   0;
% resLoadDataHour(resLoadDataHour>0)          =   0;
timeStepIndex                               =   8760/max(g.timeStepsIntraYear);
residualLoadData                            =   -resLoadDataHour(round((1+timeStepIndex)/2:timeStepIndex:end),1:end); % starting with half time step, half bar above real curve
% residualLoadData                          =   -resLoadDataHour(timeStepIndex:timeStepIndex:end,1:end); % starting with time step, all bars stay below real curve
residualLoadData2                           =   -resLoadDataHour(round(1:timeStepIndex:end),1:end); % starting with 1, all bars stay above real curve
residualHoursInput                          =   1:8760;
residualYearsInput                          =   powerYear;
surplusPowerVar                             =   zeros(size(residualHoursInput,1),s.runTime);

for k=1:max(g.timeStepsIntraYear)
    surplusPowerVar(k,:)            =   timeStepIndex.*interp1(residualYearsInput,residualLoadData(k,:),2020:1:2050,'linear'); %TW
    surplusPowerVar2(k,:)            =   timeStepIndex.*interp1(residualYearsInput,residualLoadData2(k,:),2020:1:2050,'linear'); %TW
end

for m=1:s.runTime
    surplusPowerVar(:,m)            =   interp1(g.timeStepsIntraYear,surplusPowerVar(:,m),1:1:max(g.timeStepsIntraYear),'linear');
    surplusPowerVar2(:,m)            =   interp1(g.timeStepsIntraYear,surplusPowerVar2(:,m),1:1:max(g.timeStepsIntraYear),'linear');
end

posResLoadVar                       =   -surplusPowerVar;
posResLoadVar(posResLoadVar<0)      =   0;

surplusPowerVar(surplusPowerVar<0)  =   0;

end