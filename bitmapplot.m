function I=bitmapplot(x,y,Ibackground,options)
% BITMAPPLOT, Linear plot in bitmap.
%
% Iplot=bitmapplot(x,y,Ibackground,options)
%
% inputs,
%   x : a vector with x values
%   y : a vector with y values, with same length as x 
%   Ibackground: the bitmap used as background when a m x n x 3 matrix
%       color plots are made, when m x n a greyscale plot.
%   options: struct with options such as color
% 
% outputs,
%   Iplot: The bitmap containing the plotted lines
%
% note,
%   Colors are always [r(ed) g(reen) b(lue) a(pha)], with range 0..1.
%   when Ibackground is grayscale, the mean of r,g,b is used as grey value.
%
% options,
%   options.Color: The color of the line.
%   options.FillColor: If this color is set, the region between 
%          the x and y coordnates will be filled with this color.
%   options.LineWidth: Thickness of the line in pixels 1,2,3..n
%   options.Marker: The marker type: 'o', '+' or '*'.
%   options.MarkerColor: The color of the markers used.
%   options.MarkerSize: The size of the markers used
%
% example,
%   % Make empty bitmap
%   I = zeros([320 256 3]);
%   
%   % Add a line
%   x=rand(1,10)*50+50; y=linspace(1,512,10);
%   I=bitmapplot(x,y,I);
%
%   % Add a thick red line
%   x=rand(1,10)*50+100; y=linspace(1,256,10);
%   I=bitmapplot(x,y,I,struct('LineWidth',5,'Color',[1 0 0 1]));
%
%   % Add a line with markers
%   x=rand(1,10)*50+150; y=linspace(1,256,10);
%   I=bitmapplot(x,y,I,struct('Marker','*','MarkerColor',[1 0 1 1],'Color',[1 1 0 1]));
%
%   % Add a filled polygon
%   x=[1 100 30 100]+200; y=[30 1 250 200];
%   I=bitmapplot(x,y,I,struct('FillColor',[0 1 0 0.5],'Color',[1 1 0 1]));
%
%   % Add a filled polygon on top
%   x=[30 80 70 120]+200; y=[30 1 250 200];
%   I=bitmapplot(x,y,I,struct('FillColor',[1 0 0 0.5],'Color',[1 0 0 1]));
%
%   lines={'Plot Test,','BitmapPlot version 1.2'};
%   % Plot text into background image
%   I=bitmaptext(lines,I,[1 1],struct('Color',[1 1 1 1]));
%   
%   % Show the bitmap
%   figure, imshow(I);
%
% Function is written by D.Kroon University of Twente (April 2009)


% Process inputs
defaultoptions=struct('Color',[0 0 1 1],'FillColor',[],'LineWidth',1,'Grid',[],'MarkerColor',[1 0 0 1],'Marker',[],'MarkerSize',6);
if(~exist('options','var')), 
    options=defaultoptions; 
else
    tags = fieldnames(defaultoptions);
    for i=1:length(tags)
         if(~isfield(options,tags{i})),  options.(tags{i})=defaultoptions.(tags{i}); end
    end
    if(length(tags)~=length(fieldnames(options))), 
        warning('register_images:unknownoption','unknown options found');
    end
end

% The function works with double values (store class for ouput)
Classb=class(Ibackground);
Ibackground=im2double(Ibackground);

% x and y to row vectors
x=round(x(:))'; y=round(y(:))';

% Make line, marker an fill bitmap
I_line=zeros([size(Ibackground,1) size(Ibackground,2)]);
I_marker=zeros([size(Ibackground,1) size(Ibackground,2)]);
I_fill = zeros([size(Ibackground,1)+2 size(Ibackground,2)+2]);

% Close the line if, fill color is set
if(~isempty(options.FillColor)), x=[x x(1)]; y=[y y(1)]; end

% Loop through all line coordinates
for i=1:(length(x)-1)
   % Calculate the pixels needed to construct a line of 1 pixel thickness
   % between two coordinates.
   xp=[x(i) x(i+1)];  yp=[y(i) y(i+1)]; 
   dx=abs(xp(2)-xp(1)); dy=abs(yp(2)-yp(1));
   if(dx==dy)
     if(xp(2)>xp(1)), xline=xp(1):xp(2); else xline=xp(1):-1:xp(2); end
     if(yp(2)>yp(1)), yline=yp(1):yp(2); else yline=yp(1):-1:yp(2); end
   elseif(dx>dy)
     if(xp(2)>xp(1)), xline=xp(1):xp(2); else xline=xp(1):-1:xp(2); end
     yline=linspace(yp(1),yp(2),length(xline));
   else
     if(yp(2)>yp(1)), yline=yp(1):yp(2); else yline=yp(1):-1:yp(2); end
     xline=linspace(xp(1),xp(2),length(yline));   
   end
   
   % Make closed line structure for fill if FillColor specified.
   if(~isempty(options.FillColor))
        xline_fill=xline; yline_fill=yline;
        % Limit to boundaries
        xline_fill(xline_fill<1)=1; yline_fill(yline_fill<1)=1;
        xline_fill(xline_fill>size(I_line,1))=size(I_line,1); 
        yline_fill(yline_fill>size(I_line,2))=size(I_line,2);
        % I_fill is one pixel larger than I_line to allow background fill
        xline_fill=xline_fill+1; yline_fill=yline_fill+1;
        % Insert all pixels in the fill image
        I_fill(round(xline_fill)+(round(yline_fill)-1)*size(I_fill,1))=1;
   end

   if(options.LineWidth==1)
       % Remove pixels outside image
       xline1=xline; yline1=yline;
       check=(xline1<1)|(yline1<1)|(xline1>size(I_line,1))|(yline1>size(I_line,2));
       xline1(check)=[]; yline1(check)=[];
       % Insert all pixels in the line image
       I_line(round(xline1)+round(yline1-1)*size(I_line,1))=1;
   elseif(options.LineWidth>1) % Add more pixel is line-width is larger than 1...    
       % Calculate normal on line
       ang=[yline(end)-yline(1) xline(end)-xline(1)]; ang=ang./(0.00001+sqrt(sum(ang.^2)));
       for j=-((options.LineWidth-1)/2):((options.LineWidth-1)/2);
           % Make lines close to the other lines
           xline1=xline+(ang(1)*j); yline1=yline-(ang(2)*j);
           % Remove pixels outside image
           check=(xline1<1)|(yline1<1)|(xline1>size(I_line,1))|(yline1>size(I_line,2));
           xline1(check)=[]; yline1(check)=[];
           % Insert all pixels in the line image
           I_line(ceil(xline1)+floor(yline1-1)*size(I_line,1))=1;
           I_line(floor(xline1)+floor(yline1-1)*size(I_line,1))=1;
           I_line(ceil(xline1)+ceil(yline1-1)*size(I_line,1))=1;
           I_line(floor(xline1)+ceil(yline1-1)*size(I_line,1))=1;
       end
   end
end

% Fill the line image I_fill
if(~isempty(options.FillColor))
    I_fill=bwfill(I_fill,1,1); I_fill=1-I_fill(2:end-1,2:end-1);
end

% Make marker image
if(~isempty(options.Marker))
    % Make marker pixels (center 0,0)
    switch(options.Marker)
        case '+'
            markerx=[-(options.MarkerSize/2):(options.MarkerSize/2) zeros(1,options.MarkerSize+1)];
            markery=[zeros(1,options.MarkerSize+1) -(options.MarkerSize/2):(options.MarkerSize/2)]; 
        case '*'
            markerx=[-(options.MarkerSize/2):(options.MarkerSize/2) zeros(1,options.MarkerSize+1)];
            markery=[zeros(1,options.MarkerSize+1) -(options.MarkerSize/2):(options.MarkerSize/2)]; 
            markerx=[markerx -(options.MarkerSize/2):(options.MarkerSize/2) -(options.MarkerSize/2):(options.MarkerSize/2)];
            markery=[markery -(options.MarkerSize/2):(options.MarkerSize/2) (options.MarkerSize/2):-1:-(options.MarkerSize/2)];
        case 'o'
            step=360/(2*pi*options.MarkerSize);
            markerx=options.MarkerSize/2*sind(0:step:90);
            markery=options.MarkerSize/2*cosd(0:step:90);
            markerx=[markerx -markerx markerx -markerx];
            markery=[markery markery -markery -markery];
    end
    % Add all line markers to the marker image
    for i=1:length(x);
        % Move marker to line coordinate
        xp=round(markerx)+round(x(i));  yp=round(markery)+round(y(i)); 
        % Remove outside marker pixels
        check=(xp<1)|(yp<1)|(xp>size(I_line,1))|(yp>size(I_line,2));
        xp(check)=[]; yp(check)=[];
        I_marker(xp+(yp-1)*size(I_line,1))=1;
    end
end    


% Adjust the lines and markers  with alpha value
I_line=I_line*options.Color(4);
if(~isempty(options.FillColor)), I_fill=I_fill*options.FillColor(4); end
if(~isempty(options.Marker)), I_marker=I_marker*options.MarkerColor(4); end

% Add lines, markers and fill in the right colors in the image
I=Ibackground;
if(size(Ibackground,3)==3) 
    % Color image
    for i=1:3
        if(~isempty(options.FillColor)),
            I(:,:,i)=I(:,:,i).*(1-I_fill)+options.FillColor(i)*(I_fill);
        end
        I(:,:,i)=I(:,:,i).*(1-I_line)+options.Color(i)*(I_line);
        if(~isempty(options.Marker)),
            I(:,:,i)=I(:,:,i).*(1-I_marker)+options.MarkerColor(i)*(I_marker);
        end
    end
else
    % Grey scale
    if(~isempty(options.FillColor)),
        I=I.*(1-I_fill)+mean(options.FillColor(1:3))*(I_fill);
    end
    I=I.*(1-I_line)+mean(options.Color(1:3))*(I_line);
    if(~isempty(options.Marker)),
        I=I.*(1-I_marker)+mean(options.MarkerColor(1:3))*(I_marker);
    end
end

% Set to range 0..1
I(I>1)=1; I(I<0)=0;

% Back to class background
switch (Classb)
    case 'single', I=im2single(I);
    case 'int16', I=im2int16(I);
    case 'uint8', I=im2uint8(I);
    case 'uint16', I=im2uint16(I);
end




