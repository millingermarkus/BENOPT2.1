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

function weatherYearDiff(s,g,powerData)
                [residualLoad,powerYear]    =   vrePower(powerData,s.onShore,s.offShore,s.photoV,s.demandPower,s.MustRun,s.RENMustRun); %Calculation of hourly residual load and other power metrics
                figure()
                hold on
                
                iMax=60;
            for i=1:3
                s.weatherYear                   =   i;
                z(i).surplusPowerVar           =   surplusPower(g,s,residualLoad,powerYear); %Calculation of surplus power (TWh) per year and time step
                surPlusSum(i)   =   sum(z(i).surplusPowerVar(:,s.runTime));
            end
            
                bar(surPlusSum);
            
    ylabel('Surplus power 2050 (TWh)')
    xlabel('Weather year')
    set(gca,'xticklabel',{'2016','2017','2018'},'XTick',[1,2,3])
    grid on
%     xlim([1 iMax])
%     ylim([0 20])
    title('Weather year surplus power difference')
    print(gcf,'-painters','-depsc','-loose','figures/weatherYearDiff')
    saveas(gcf,'figures/weatherYearDiff.tif')
end