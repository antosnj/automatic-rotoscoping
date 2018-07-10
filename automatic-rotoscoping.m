clear all
close all

%% SPECIFY INPUT VIDEO: %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
filename='video.mp4';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  

%% Create video object from filename: %%

input_video=VideoReader(filename);

frame_R=input_video.height;
frame_C=input_video.width;

%Extract number of input frames:
num_frames=round((input_video.FrameRate)*(input_video.Duration));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% SET A SPECIFIC NUMBER OF FRAMES TO BE READ, BELOW, IF FASTER PERFORMANCE 
%%%%% IS DESIRED: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%num_frames=   ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%Create output video:
outputVideo=VideoWriter('output_rotoscoped.avi');
outputVideo.FrameRate=10;
open(outputVideo)


%% Process Frames: %%

for u=1:2:num_frames %Removes a frame every 2 frames in order to give it a bigger cartoon/animation effect.
    
    frame=rgb2gray(read(input_video,u));
    raw_img=frame; %Keep copy of original frame.
    
    %Sharpen image:
    frame=imsharpen(frame);


    %Intensity adjustment:
    frame=imadjust(frame,[0 1],[0.85 1]);

    %Binarization and morphological expansion:
    binarized=imbinarize(frame);
    morpho_expanded=bwmorph(binarized,'remove');

    for row=1:frame_R %Local intensity adjustment:
        for col=1:frame_C
            if morpho_expanded(row,col)==1
                frame(row,col)=raw_img(row,col)+10;
            end
        end
    end

    out_frame=frame;
        
        
    if (mod(u,5)==0) && (mod(u,2)~=0) && (mod(u,3)~=0) %Do this every 5 frames.

        present_img=frame;
        previous_modified_img=previous;

        sum_img=(previous_modified_img+present_img)/2;
    
        %Set threshold to perform intensity adjustment:
        threshold=140;

        %Local intensity adjustment:
        for row=1:frame_R
            for col=1:frame_C
                if sum_img(row,col)<threshold
                    sum_img(row,col)=present_img(row,col);
                end
            end
        end 

        out_frame=sum_img;
  
        
    elseif (mod(u,3)==0) && (mod(u,2)~=0) && (mod(u,5)~=0) %Do this every 3 frames.   
        
        %Intensity adjustment:
        frame=imadjust(frame,[0 1],[0.1 1]);
        
        %Binarization and morphological expansion:
        binarized2=imbinarize(frame);
        morpho_expanded2=bwmorph(binarized2,'skel',Inf);

        %Local intensity adjustment:
        for row=1:frame_R
            for col=1:frame_C
                if morpho_expanded2(row,col)==1
                    frame(row,col)=frame(row,col)+5;
                end
            end
        end
        
        out_frame=frame;
        
        
    end

    previous=frame;
    fprintf('Frame %d processed.\n',u);
    
    
    writeVideo(outputVideo,out_frame);
    
end

close(outputVideo)

implay('output_rotoscoped.avi')


%% PLOTS: %%
frame_show=rgb2gray(read(input_video,50));

%Sharpen image:
frame_sharpened=imsharpen(frame_show);

%Intensity adjustment:
frame_intensity=imadjust(frame_sharpened,[0 1],[0.85 1]);
frame_intensity_copy=frame_intensity;

%1st binarization/morph. exp:
%Binarization and morphological expansion:
binarized=imbinarize(frame_intensity);
morpho_expanded=bwmorph(binarized,'remove');

for row=1:frame_R %Local intensity adjustment:
    for col=1:frame_C
        if morpho_expanded(row,col)==1
            frame_intensity(row,col)=frame_show(row,col)+10;
        end
    end
end

%2nd binarization/morph. exp:
%Intensity adjustment:
frame=imadjust(frame_intensity,[0 1],[0.1 1]);

%Binarization and morphological expansion:
binarized2=imbinarize(frame);
morpho_expanded2=bwmorph(binarized2,'skel',Inf);

%Local intensity adjustment:
for row=1:frame_R
    for col=1:frame_C
        if morpho_expanded2(row,col)==1
            frame(row,col)=frame(row,col)+5;
        end
    end
end


figure(1)
imshow(frame_show)
title('Original/Input Frame')

figure(2)
imshow(frame_sharpened)
title('Sharpening')

figure(3)
imshow(frame_intensity_copy)
title('Intensity Adjustment')

figure(4)
imshow(binarized)
title('Binarization')

figure(5)
imshow(morpho_expanded)
title('Morphological Expansion')

figure(6)
imshow(frame_intensity)
title('After 1st Binarization and Morph. Exp.')

figure(7)
imshow(frame)
title('After 2nd Binarization and Morph. Exp. (Algorithm Output)')


