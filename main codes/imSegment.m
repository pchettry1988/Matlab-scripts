function [BW] = imSegment(input_image)
[rows, columns] = size(input_image);
BW = false(rows, columns);

F = figure;
F.WindowState = 'maximized';
imshow(input_image);
i = 1;
while i<100
    Continue = questdlg('Would you like to remove more vessels?', 'Remove', 'Yes', 'No','Yes');
    switch Continue
        case 'Yes'
            roi = drawfreehand;
            roi.Closed = true;
            roi.LineWidth = 1;
                       
            Delete = questdlg('Would you like to remove the last ROI?','Remove','Yes', 'No', 'No');
            switch Delete
                case 'Yes'
                    delete(roi);
                case 'No'
                    mask = createMask(roi);
                    BW = BW | mask;
            end
%             imshow(cumulativeBinaryImage)
        case 'No'
            i = 100;
            close(F);
    end
end   
end
    