
clc; clear; close all;

%% Created in 2015/11/30, Pattern Recognition homework, 
%   Read frames from a video and save them as images.
%   Developed with matlab 2012b
 
vr = VideoReader('linSenRd.mov');
%vr = VideoReader('MAH00911.MP4');
v = read(vr);
size(v)                                                                     % Format of v: #y, #x, #channel, #frames, maybe column major

maxX = size(v,2)
maxY = size(v,1)
display = v;
endFrames = vr.NumberOfFrames                                               % Get the total frames of the video
frames = 50;                                                               % Set training frames
result = zeros(maxX, maxY, frames);
wholeResult = zeros(1, endFrames);

sprintf('size of video, v: ')


xStart = 1, yStart = 1;
SetX = maxX; SetY = maxY;
RGBchannel = 3;
size(result);

% Read frames from video and save them as jpeg format images (first 100 frames)
for x = 1: maxX
    for y = 1: maxY
        for i = 1: frames
           result(x, y, i) = v(y, x, RGBchannel , i); 
           %imwrite(v(:, :, : , i), strcat('frame-', num2str(i), '.jpg'));
        end
    end
end

% show b-channel value plot
%subplot(2,2,1);
%plot(1:1:frames, result(1:frames), 'k-');
%title('b channel for the first 100 frames');

% compute gaussian distribution via the first-100-frame, get the mean(mu),
% and sigma.
%subplot(2,2,2);

mu = zeros(maxX, maxY);
sigmaSquared = zeros(maxX, maxY);
for x = 1: maxX
    for y = 1: maxY
        mu(x, y) = sum(result(x, y, 1:frames)) / length(result(x, y, 1:frames));
        sigmaSquared(x, y) = sum( (result(x, y, 1:frames) - mu(x, y)).^2 )/ length(result(x, y, 1:frames));
%        range = (mu - sqrt(sigmaSquared)) :0.1: (mu + sqrt(sigmaSquared));  
    end
end

sprintf('^^^^^^')
size(mu)
size(sigmaSquared)
%mu = sum(result(1:frames)) / length(result(1:frames))
%sigmaSquared = sum( (result(1:frames) - mu).^2 )/ length(result(1:frames))
%range = (mu - sqrt(sigmaSquared)) :0.1: (mu + sqrt(sigmaSquared));
% draw the gaussian distribution
%plot(range, normal_distribution(range, mu, sqrt(sigmaSquared)));
%title('gaussian MLE figure');
%view(90, -90);

% predict if there's a moving object in the rest of the frames.
% use 3*sigma as the threshold

%%%%%%%%%%%%%%%% TEST%%%%%%%%%%%%%%
%for y = 1: maxY
%    v(y, 470, 1, 2) = 255;
%    v(y, 470, 2, 2) = 255;
%    v(y, 470, 3, 2) = 255;
%    imshow(v(:, :, :, 2))
%end

for i = 1 : endFrames
    subplot(2,2,4);
    %imshow(v(:, :, :, i))
   % hold off;
    %if( v(460, 470, 3 , i) < 75 ) sprintf('s Moving object appeared in %d', i)
    for x = xStart: SetX
        for y = yStart: SetY
            if( (v(y, x, RGBchannel , i) < mu(x, y) -sigmaSquared(x, y)*10) || ( v(y, x, RGBchannel , i) > mu(x, y) +sigmaSquared(x, y)*10)) 
               %sprintf('s Moving object appeared in %d', i)
                %hold on;
                %plot(x, y, 'rx')
                v(y, x, 1, i) = 255;
                v(y, x, 2, i) = 255;
                v(y, x, 3, i) = 255;
            end       
        end
    end
    imshow(v(:, :, :, i))
    % show b-channel value of the whole video
    subplot(2,2,3);
    wholeResult(i) = display(470, 460, RGBchannel, i);
    plot(1:endFrames, wholeResult, 'k-');
%    title('b channel for the whole 900 frames');
    pause(0.001)
end

