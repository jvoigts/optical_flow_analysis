%  Applies the Horn–Schunck method 
% (https://en.wikipedia.org/wiki/Horn%E2%80%93Schunck_method)
% to a video and extract motion profile over time.
%
% This method is set up to run on video recorded with a neuralynx system 
% and tracks mouse activity levels over time to quantify arousal levels.
% 
% uses
% http://www.mathworks.com/matlabcentral/fileexchange/22756-horn-schunck-optical-flow-method
%
%
% This method was used in:
%
% Lewis LD, Voigts J, Flores FJ, Schmitt LI, Wilson MA, Halassa MM, Brown EN
% Thalamic reticular nucleus induces fast and local modulation of arousal state. 
% 2015 eLife ;10.7554/eLife.08760
%
addpath(fullfile('HSmethod'));
%% make demo video
% or read from mpeg instead

Nframes=200;
Istack=zeros(320,480,Nframes);

mouse=zeros(20);mouse(6:end,6:end)=fspecial('disk',7)*3; mouse([1:9]+1,[1:9]+1)=max(mouse([1:9]+1,[1:9]+1),fspecial('disk',4)); mouse(2:3,2:3)=.02;
for i=1:20
    x=10*sin(-i/15)+28; y=10*cos(-i/20)+14; mouse(round(x),round(y))=.02;
end;
mouse=mouse./max(mouse(:));

t=((sin([1:Nframes]/130)).^6)*80;
mousepos=round([(sin(t./25)*60)-(cos(10+t./5)*50); (cos(t./30)*100)+(cos(10+t./6)*50)  ])+200;

for i=1:Nframes
    Istack(:,:,i)=0.1;
    Istack(100:end-100,100:end-100,i)=0;
    Istack(1:50,:,i)=1;
    Istack(mousepos(1,i),mousepos(2,i),i)=100+rand*5;
    Istack(:,:,i)=conv2(Istack(:,:,i),mouse,'same');
    Istack(:,:,i)= Istack(:,:,i)+rand(size( Istack(:,:,i)))*30;
end;

%% run horn schunck

motion=zeros(1,Nframes);

smoothing=.5;

for i=2:Nframes
[u, v] = HS(Istack(:,:,i-1), Istack(:,:,i), 1, 10, zeros(size(Istack(:,:,1))), zeros(size(Istack(:,:,1))), 0, 0);

motion_norm_im=sqrt(u.^2+v.^2);

motion(i)=smoothing*motion(i-1)+(1-smoothing)*max(motion_norm_im(:));

clf;
subplot(221);
imagesc(Istack(:,:,i)); daspect([1 1 1]);
title('input');
subplot(222);
imagesc(motion_norm_im); daspect([1 1 1]);
title('norm of motion from HS method');
subplot(2,2,[3 4]);
plot(motion);
title('max. motion');
xlabel('t (frames)');
ylabel('motion index');
drawnow;

end