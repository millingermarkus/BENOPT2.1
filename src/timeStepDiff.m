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


function timeStepDiff(s,g,powerData)
                [residualLoad,powerYear]    =   vrePower(powerData,s.onShore,s.offShore,s.photoV,s.demandPower,s.MustRun,s.RENMustRun); %Calculation of hourly residual load and other power metrics
                figure()
                hold on
                
                iMax=60;
            for i=[1:1:iMax,8760]
                g.timeStepsIntraYear        =   1:(1+i);
                tic
                z(i).surplusPowerVar           =   surplusPower(g,s,residualLoad,powerYear); %Calculation of surplus power (TWh) per year and time step
                toc
%                 r.resLoadDataHour(i)    =   -sum(q(i).resLoadDataHour(:,7));
                i
            end
            
            totlim=sum(z(8760).surplusPowerVar,'all');
            %%
            for i=1:1:iMax
                unused(i)=100*(1-sum(z(i).surplusPowerVar,'all')/totlim);
            end

                plot(1:iMax,unused,'-');
%             plot(xlim,[totlim totlim],'-');
            
    ylabel('Difference (%)')
    xlabel('Number of Intra-year steps (t_{st})')
    grid on
    grid minor
    xlim([1 iMax])
    ylim([0 20])
    title('Difference to total residual load over total time span')
    print(gcf,'-painters','-depsc','-loose','figures/timeStepDiff')
    saveas(gcf,'figures/timeStepDiff.tif')
end