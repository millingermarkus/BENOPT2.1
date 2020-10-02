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
% Merit order plotting
%

function meritOrderPlot(prod,cost,legendNames,col,year,scenario,xlab,ylab,tit,yMax,xMax,fileName)
%% Creates a sorted merit order rectangle plot
[costSort,index]    =   sort(cost,'Ascend');
base=0;
% figure()

for i=1:length(prod)
    ax(i)   =   rectangle('Position',[base 0 prod(index(i)) costSort(i)]);
    hold on
    if prod(index(i))>0 % For rectangles no legends can be created (directly)
     text(base+prod(index(i))/2,cost(index(i))+1,legendNames{index(i)},'VerticalAlignment','bottom','HorizontalAlignment','left','Rotation',90,'Interpreter','none')
    end
    base = base+prod(index(i));
    ax(i).FaceColor = col(index(i),:);
    ax(i).EdgeColor = col(index(i),:);
end


    xlim([0 xMax])
    ylim([0 yMax])
%     xlabel(['Production ' num2str(year) ' (PJ)'])
    xlabel(xlab)
    ylabel(ylab)
%     ylabel('Cost (€ GJ^{-1})')   
    grid on
    title(tit)
%     fileName    =   ['figures/meritOrder' num2str(year)];
    print(gcf,'-painters','-depsc','-loose',fileName)
    saveas(gcf,fileName)
    saveas(gcf,fileName,'png')