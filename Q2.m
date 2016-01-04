clc; clear; close all;

%% Created in 2015/11/30, Pattern Recognition homework, 
%   Read frames from a video and save them as images.
%   Developed with matlab 2012b
 
vr = VideoReader('linSenRd.mov');
v = read(vr);
display = v;
%frameCnt = 0;
endFrames = vr.NumberOfFrames
frames = 100;
result = zeros(1, frames);
wholeResult = zeros(1, endFrames);

sprintf('size of video, v: ')
size(v)                                                                     % Format of v: #y, #x, #channel, #frames, maybe column major
maxX = size(v,2)
maxY = size(v,1)


SetX = 800; SetY = 470;
RGBchannel = 1;

% Read frames from video and save them as jpeg format images (first 100 frames)
for i = 1: frames
   result(i) = v(SetY, SetX, RGBchannel , i); 
   %imwrite(v(:, :, : , i), strcat('frame-', num2str(i), '.jpg'));
end
size(result)

% show b-channel value plot
subplot(2,2,1);
plot(1:1:frames, result(1:frames), 'k-');
title('b channel for the first 100 frames');

% compute gaussian distribution via the first-100-frame, get the mean(mu),
% and sigma.
subplot(2,2,2);
mu = sum(result(1:frames)) / length(result(1:frames))
sigmaSquared = sum( (result(1:frames) - mu).^2 )/ length(result(1:frames))
range = (mu - sqrt(sigmaSquared)) :0.1: (mu + sqrt(sigmaSquared));
% draw the gaussian distribution
plot(range, normal_distribution(range, mu, sqrt(sigmaSquared)));
title('gaussian MLE figure');
view(90, -90);

% predict if there's a moving object in the rest of the frames.
% use 3*sigma as the threshold

for i = 1 : endFrames
    subplot(2,2,4);
    imshow(v(:, :, :, i))
    hold off;
    %if( v(460, 470, 3 , i) < 75 ) sprintf('s Moving object appeared in %d', i)
    for x = SetX: SetX
        for y = SetY: SetY
            if( (v(y, x, RGBchannel , i) < mu-sigmaSquared) || ( v(y, x, RGBchannel , i) > mu+sigmaSquared)) 
                %sprintf('s Moving object appeared in %d', i)
                hold on;
                plot(x, y, 'rx')
                %v(460, 470, 1, i) = 255;
                %v(460, 470, 2, i) = 255;
                %v(460, 470, 3, i) = 255;
            end
        end
    end
    pause(0.01);
    % show b-channel value of the whole video
    subplot(2,2,3);
    wholeResult(i) = display(SetY, SetX, RGBchannel, i);
    plot(1:endFrames, wholeResult, 'k-');
    title('b channel for the whole 900 frames');
end

