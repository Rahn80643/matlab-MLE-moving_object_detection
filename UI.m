function varargout = UI(varargin)

% UI MATLAB code for UI.fig
%      UI, by itself, creates a new UI or raises the existing
%      singleton*.
%
%      H = UI returns the handle to a new UI or the handle to
%      the existing singleton*.
%
%      UI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UI.M with the given input arguments.
%
%      UI('Property','Value',...) creates a new UI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before UI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to UI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help UI

% Last Modified by GUIDE v2.5 05-Jan-2016 22:36:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @UI_OpeningFcn, ...
                   'gui_OutputFcn',  @UI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

% End initialization code - DO NOT EDIT


% --- Executes just before UI is made visible.
function UI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to UI (see VARARGIN)


% Choose default command line output for UI
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);



% UIWAIT makes UI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = UI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in btnExecute.
function btnExecute_Callback(hObject, eventdata, handles)
% hObject    handle to btnExecute (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%sprintf('Current pressed is %d', pressed);
%pressed = 1;

frameCntTr = str2double(get(handles.frameCnt,'string'))
thresSize = str2double(get(handles.thresholdSize,'string'))
checkX = str2double(get(handles.posX,'string'))
checkY = str2double(get(handles.posY,'string'))
channel = str2double(get(handles.editChannel, 'string'))

    vr = VideoReader('linSenRd.mov');
    %vr = VideoReader('MAH00911.MP4');
    v = read(vr);
    size(v)                                                                 % Format of v: #y, #x, #channel, #frames, maybe column major

    maxX = size(v,2)
    maxY = size(v,1)
    display = v;
    endFrames = vr.NumberOfFrames                                           % Get the total frames of the video
    frames = frameCntTr;                                                    % Set training frames
    result = zeros(maxX, maxY, frames);
    wholeResult = zeros(1, endFrames);
    sprintf('size of video, v: ');


    xStart = 1; yStart = 1;
    SetX = maxX; SetY = maxY;
    RGBchannel = channel;
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

    sprintf('^^^^^^');
    size(mu);
    size(sigmaSquared);
    %mu = sum(result(1:frames)) / length(result(1:frames))
    %sigmaSquared = sum( (result(1:frames) - mu).^2 )/ length(result(1:frames))
    %range = (mu - sqrt(sigmaSquared)) :0.1: (mu + sqrt(sigmaSquared));
    % draw the gaussian distribution
    subplot(2,3,4);
    range = (mu(checkX, checkY) - sqrt(sigmaSquared(checkX, checkY))) :0.1: (mu(checkX, checkY) + sqrt(sigmaSquared(checkX, checkY))); 
    plot(range, normal_distribution(range, mu(checkX, checkY), sqrt(sigmaSquared(checkX, checkY))));
    title('gaussian MLE figure');
    view(90, -90);

    % predict if there's a moving object in the rest of the frames.
    % use thresSize*sigma as the threshold

    for i = 1 : endFrames
        subplot(2,3,6);
        %imshow(v(:, :, :, i))
       % hold off;
        %if( v(460, 470, 3 , i) < 75 ) sprintf('s Moving object appeared in %d', i)
        hold off;
        for x = xStart: SetX
            for y = yStart: SetY
                if( (v(y, x, RGBchannel , i) < mu(x, y) -sigmaSquared(x, y)* thresSize) || ( v(y, x, RGBchannel , i) > mu(x, y) +sigmaSquared(x, y)* thresSize))                   
                    v(y, x, 1, i) = 255;
                    v(y, x, 2, i) = 255;
                    v(y, x, 3, i) = 255;
                end       
            end
        end
        imshow(v(:, :, :, i))
        hold on;
        plot(checkX, checkY, 'rx');
        % show b-channel value of the whole video
        subplot(2,3,5);
        wholeResult(i) = display(470, 460, RGBchannel, i);
        plot(1:endFrames, wholeResult, 'k-');
    %    title('b channel for the whole 900 frames');
        pause(0.001)
    end




function frameCnt_Callback(hObject, eventdata, handles)
% hObject    handle to frameCnt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of frameCnt as text
%        str2double(get(hObject,'String')) returns contents of frameCnt as a double

%frameCnt = str2double(get(hObject, 'String'))



% --- Executes during object creation, after setting all properties.
function frameCnt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frameCnt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%frameCnt = str2double(get(hObject, 'String'))


function thresholdSize_Callback(hObject, eventdata, handles)
% hObject    handle to thresholdSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of thresholdSize as text
%        str2double(get(hObject,'String')) returns contents of thresholdSize as a double

%thresSize = str2double(get(hObject, 'String'))

% --- Executes during object creation, after setting all properties.
function thresholdSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to thresholdSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%thresSize = str2double(get(hObject, 'String'))


function posX_Callback(hObject, eventdata, handles)
% hObject    handle to posX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of posX as text
%        str2double(get(hObject,'String')) returns contents of posX as a double

%posX = str2double(get(hObject, 'String'))

% --- Executes during object creation, after setting all properties.
function posX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to posX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%posX = str2double(get(hObject, 'String'))


function posY_Callback(hObject, eventdata, handles)
% hObject    handle to posY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of posY as text
%        str2double(get(hObject,'String')) returns contents of posY as a double
%posY = str2double(get(hObject, 'String'))


% --- Executes during object creation, after setting all properties.
function posY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to posY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%posY = str2double(get(hObject, 'String'))

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over btnExecute.
function btnExecute_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to btnExecute (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function editChannel_Callback(hObject, eventdata, handles)
% hObject    handle to editChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editChannel as text
%        str2double(get(hObject,'String')) returns contents of editChannel as a double


% --- Executes during object creation, after setting all properties.
function editChannel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
