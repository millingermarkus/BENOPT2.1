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
% Plotting for Monte Carlo
%

function mCplot(iter,x,y,xlab,ylab,m,n,p,type)

sz = 2;
c = 'black';

subplot(m,n,p)
    if contains(type,'scatter')
        scatter(x,y,sz,c,'filled')
%         lsline
        hold on
%         mdl =   fitlm(x,y,'linear');
        mdl =   fitlm(x,y,'quadratic');
%         h   =   plotAdded(mdl)
        plot(mdl,'Marker','none','MarkerFaceColor',c,'MarkerSize',sz)
%         h(3).LineWidth = 0;
        legend off
%         mdl.Coefficients
     text(mean(x),min(y)+(max(y)-min(y))/10,['R^2=' num2str(mdl.Rsquared.Ordinary)],'Color','red','FontSize',8)
    elseif contains(type,'box')
        boxplot(y,x)
    elseif contains(type,'violin')
        violinplot(y,x);
    end
    hold on
    title('')
%     title([xlab '/' ylab],'FontSize',10);
    ylabel(ylab)
    xlabel(xlab)
end
