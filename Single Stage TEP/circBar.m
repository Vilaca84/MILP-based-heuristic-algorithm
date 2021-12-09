function [b, c, m, t, g] = circBar(Y, lim, width, plot_spokes, ax)
% circBar Radial/Circular progress bar charts.
%
%   circBar(Y, ...) creates a bar graph on polar coordinate system with one
%   bar per element in Y.
%
%   circBar(..., LIM) sets the angular limits of the graph. LIM is a
%   scalar and should be superior to MAX(Y).
%
%   circBar(..., WIDTH) sets the bars width. WIDTH must be in the range [0 1].
%
%   circBar(..., AX) plots into the axes specified by AX instead of into
%   the current axes (gca).
%
%   [B, C, M, T, G] = circBar(...) returns handles of graphics objects:
%   - B contains the handles of the bars
%   - C contains the handles of the circles
%   - M contains the handles of the markers
%   - T is the handles of the text objects
%   - G is the handles of the grid

% This is a modified version of radialBar mathworks.com/matlabcentral/fileexchange/61730-radialbar
% Original author: Jerome Briot
% Edited by:       giannit
% Version:         1.0 (16 May 2021)


% Check input parameters

narginchk(4,5)

if ~isnumeric(Y) || ~isvector(Y)
    error('First argument (Y) must be a 1-dimensional numeric array')
end
if ~all(isfinite(Y))
    warning('Some non-finite values (nan or inf) have been removed from the first argument (Y)')
    Y(~isfinite(Y)) = [];
end
if any(Y<0)
    warning('First argument (Y) contains negative values')
end

if ~isnumeric(lim) && ~isscalar(lim)
    error('Second argument (lim) must be scalar');
elseif lim < max(Y)
    error('Second argument (lim) must be greater than max(Y)');
end
% p = floor(log10(abs(max(Y))));
% lim = ceil(max(Y)*10^-p)*10^p; % a possible choice for a default value of lim

if ~isnumeric(width) && ~isscalar(width)
    error('Third argument (width) must be scalar');
elseif width>1 || width<0
    error('Third argument (width) must be in the range [0 1]');
end

if ~islogical(plot_spokes)
    error('Fourth argument (plot_spokes) must be logical true or false')
end

if exist('ax','var')
    if ~ishandle(ax)
        error('Fifth argument (ax) must be an axes handle');
    end
else
    ax = axes;
end

hold(ax, 'on');

res = 200;          % Radial circle resolution
nY  = numel(Y);     % Number of bars
ang = [pi/2 -2*pi]; % Origin and angular length of the graph


%% Bars

s = (1-width)/2;
Th = linspace(0, 2*pi, res);
for n = 1:nY
    % Main bars
    th = linspace(ang(1), ang(1)+Y(n)*ang(2)/lim, res);
    xp{1,n} = [(n+s)*cos(th) (n+1-s)*cos(th(end:-1:1))].';
    yp{1,n} = [(n+s)*sin(th) (n+1-s)*sin(th(end:-1:1))].';
    
    % Alpha bars
    xp{2,n} = [(n+s)*cos(Th) (n+1-s)*cos(Th(end:-1:1))].';
    yp{2,n} = [(n+s)*sin(Th) (n+1-s)*sin(Th(end:-1:1))].';
    
    % Coordinates of the circles centers
    xp{3,n} = [xp{1,n}(1)   + xp{1,n}(end)    yp{1,n}(1)   + yp{1,n}(end)  ] / 2;
    xp{4,n} = [xp{1,n}(res) + xp{1,n}(res+1)  yp{1,n}(res) + yp{1,n}(res+1)] / 2;
end

% Default bars colors
% col = prism(nY); % more at mathworks.com/help/matlab/ref/colormap.html#buc3wsn-1-map
col = gray(nY);
% Circles to simulate bar roundness
r = width/2;
theta = (0:res-1)*(2*pi/res);
for n = 1:nY
    % Bars
    b(1,n) = patch(xp{1,n}, yp{1,n}, col(n,:), 'parent', ax);
    b(2,n) = patch(xp{2,n}, yp{2,n}, col(n,:), 'parent', ax, 'facealpha', 0.3);
    
    % Circles
    x = @(i,r) xp{i,n}(1) + r*cos(theta);
    y = @(i,r) xp{i,n}(2) + r*sin(theta);
    
    c(1,n) = plot(polyshape(x(3,r),y(3,r)),'facecolor',col(n,:),'FaceAlpha',1,'LineStyle','none'); % big circle (start)
    m(1,n) = plot(polyshape(x(3,r/5),y(3,r/5)),'FaceAlpha',0); % small empty circle
    
    c(2,n) = plot(polyshape(x(4,r),y(4,r)),'facecolor',col(n,:),'FaceAlpha',1,'LineStyle','none'); % big circle (end)
    m(2,n) = plot(polyshape(x(4,r/5),y(4,r/5)),'facecolor','k','FaceAlpha',1,'LineStyle','none'); % small filled circle
end
set(b, 'edgecolor', 'none')
uistack(m(:),'top') % small circles on top

% Print value or %
if numel(Y) == 1 && Y >= 0
    if floor(Y) == ceil(Y) && floor(lim) == ceil(lim) % if Y and lim are integer
        text(0,0,num2str([Y lim],'\\fontsize{45}%d\\fontsize{15}\\newlineof %d'),'hor','center','fontname','gadugi')
    else
        text(0,0,num2str(Y/lim*100,'%.0f%%'),'hor','center','fontsize',40)
    end
end


%% Spokes

if plot_spokes
    % Number of spokes (empirical estimation)
    p = floor(log10(abs(max(Y))));
    ns = lim*10^-p+1;
    while ns <= 5
        ns = ns*2-1;
    end

    % Spokes
    th = linspace(ang(1), ang(1)+ang(2), ns);
    xr = [cos(th) ; (nY+1)*cos(th)];
    yr = [sin(th) ; (nY+1)*sin(th)];

    % Radial circles
    th = linspace(ang(1), ang(1)+ang(2), res);
    xth = cos(th(:)) * (nY+1:-1:1);
    yth = sin(th(:)) * (nY+1:-1:1);

    % Plot radial circles and spokes
    g = plot(ax, xth, yth,'k-',xr,yr,'k-');
    set(g, 'color', [.8 .8 .8])

    % Annotate spokes
    th = linspace(ang(1), ang(1)+ang(2), ns);
    th_val = linspace(0,lim,ns);
    if abs(cos(th(1))-cos(th(end)))<1E-5 && abs(sin(th(1))-sin(th(end)))<1E-5
        th(end) = [];
        th_val(end) = [];
    end
    xt = (nY+2)*cos(th);
    yt = (nY+2)*sin(th);
    t = text(xt, yt, cellstr(num2str(round(th_val).', '%d')),'hor', 'center');
    for n = 1:numel(t)
        set(t(n), 'rotation', (th(n)-0.5*pi)*180/pi)
    end
end


%% Set axis limits and appearance

axis(ax, 'equal')
if plot_spokes
    xlim(ax, [min(xth(:)) max(xth(:))]+[-2 2])
    ylim(ax, [min(yth(:)) max(yth(:))]+[-2 2])
end
set(ax, 'xtick', [], 'ytick', [])