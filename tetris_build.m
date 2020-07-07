function tetris_build
global gravity
global summoning
global new_gravity
global old_gravity
global score

    tetris_figure = figure('units', 'normalized', 'outerposition', [0.3 0.05 0.5 0.95],'numbertitle','off','name','Tetris', 'menubar', 'none','Color','w','KeyPressFcn',@control,'KeyReleaseFcn',@slow_down,'CloseRequestFcn',@exit_game);
    tetris_axis = axes('units','normalized','position',[0.3 0.05 0.4 0.95]);
    board_length = 10;
    board_height = 26;
    board_area = 240;
    square_size = 1;
    score = 0;
    for i = 1:board_length
        for j = 1:board_height
            tetris_board(i,j) = rectangle('Position',[i-1 j-1 square_size square_size],'FaceColor','k','EdgeColor','r','UserData','no');
        end
    end
    for i = 1:board_length
        for j = 25:26
            tetris_board(i,j).FaceColor = tetris_figure.Color;
            tetris_board(i,j).EdgeColor = tetris_figure.Color;
        end
    end
    tetris_axis.YLim = [0 board_height];
    tetris_axis.XLim = [0 board_length];
    tetris_axis.XAxis.Visible = 'off';
    tetris_axis.YAxis.Visible = 'off';
    
    gravity = 3;
    new_gravity = 20;
    old_gravity = 3;
    shapes{1} = [4 5 5 6;26 26 25 25]; % Z shape
    shapes{2} = [4 5 5 6;25 25 26 26]; % reversed Z shape
    shapes{3} = [4 5 5 6;26 25 26 26]; % T shape
    shapes{4} = [5 5 5 5;26 25 24 23]; % line
    shapes{5} = [4 4 5 6;26 25 25 25]; % reversed L shape
    shapes{6} = [4 5 6 6;25 25 25 26]; % L shape
    shapes{7} = [5 5 6 6;25 26 25 26]; % square
    summoning = 1;
    
    while gravity > 0
        if summoning
            choosing_shape = randi(7);
% choosing_shape = 4;
            a_shape = shapes{choosing_shape};
            for k = 1:4
                tetris_board(a_shape(1,k),a_shape(2,k)).FaceColor = 'w';
                tetris_board(a_shape(1,k),a_shape(2,k)).UserData = 'yes';
            end
        end
        summoning = 0;
        fall(a_shape);
        if ~summoning
            for k = 1:4
                a_shape(2,k) = a_shape(2,k)-1;
            end
            pause(1/gravity);
        end       
    end
    
    function fall(falling_shape)
        falling_counter = 0;
        for k = 1:4
            if falling_shape(2,k)-1 ~= 0 && ~strcmp(tetris_board(falling_shape(1,k),falling_shape(2,k)-1).UserData,'ground') 
                falling_counter = falling_counter+1;
                if falling_counter == 4
                    for l = 1:4
                        if falling_shape(2,l) < 25
                            tetris_board(falling_shape(1,l),falling_shape(2,l)).FaceColor = 'k';
                            tetris_board(falling_shape(1,l),falling_shape(2,l)).UserData = 'no';
                        end
                    end
                    for l = 1:4
                        tetris_board(falling_shape(1,l),falling_shape(2,l)-1).FaceColor = 'w';
                        tetris_board(falling_shape(1,l),falling_shape(2,l)-1).UserData = 'yes';
                    end
                end
            end
        end
        if falling_counter < 4
            for l = 1:4
                tetris_board(falling_shape(1,l),falling_shape(2,l)).FaceColor = 'y';
                tetris_board(falling_shape(1,l),falling_shape(2,l)).UserData = 'ground';
            end
            summoning = 1;
            delete_bottom();
        end   
    end
    
    function delete_bottom(~,~)
        row_counter = 0;
        deleted_row = [];
        for j = 1:board_height-2
            for i = 1:board_length
                if tetris_board(i,j).FaceColor == [1 1 0]
                    row_counter = row_counter + 1;
                end
            end
            if row_counter == 10
                for k = 1:board_length
                    tetris_board(k,j).FaceColor = 'k';
                    tetris_board(k,j).UserData = 'no';
                end
                deleted_row(end+1) = j;
            end
            row_counter = 0;
        end
        while ~isempty(deleted_row)
            for i = 1:board_length
                for j = deleted_row(1):board_height-3
                    tetris_board(i,j).FaceColor = tetris_board(i,j+1).FaceColor;
                    tetris_board(i,j).UserData = tetris_board(i,j+1).UserData;
                end
            end
            deleted_row(1) = [];
            deleted_row = deleted_row - 1;
        end
    end
    
    function control(hObject,~)
        current_key = get(hObject,'CurrentKey'); %leftarrow rightarrow downarrow space
        if strcmp(current_key,'leftarrow')
            move_left();
        elseif strcmp(current_key,'rightarrow')
            move_right();
        elseif strcmp(current_key,'downarrow')
            accelerate();
        elseif strcmp(current_key,'a') || strcmp(current_key,'d')
            turn_90(current_key);
        end
    end
    
    function move_left(~,~)
        moving_counter = 0;
        for k = 1:4
            if a_shape(1,k)-1 ~= 0 && ~strcmp(tetris_board(a_shape(1,k)-1,a_shape(2,k)).UserData,'ground') 
                moving_counter = moving_counter+1;
                if moving_counter == 4
                    for l = 1:4
                        tetris_board(a_shape(1,l),a_shape(2,l)).FaceColor = 'k';
                        tetris_board(a_shape(1,l),a_shape(2,l)).UserData = 'no';
                    end
                    for l = 1:4
                        tetris_board(a_shape(1,l)-1,a_shape(2,l)).FaceColor = 'w';
                        tetris_board(a_shape(1,l)-1,a_shape(2,l)).UserData = 'yes';
                        a_shape(1,l) = a_shape(1,l)-1;
                    end              
                end
            end
        end
    end

    function move_right(~,~)
        moving_counter = 0;
        for k = 1:4
            if a_shape(1,k)+1 ~= 11 && ~strcmp(tetris_board(a_shape(1,k)+1,a_shape(2,k)).UserData,'ground') 
                moving_counter = moving_counter+1;
                if moving_counter == 4
                    for l = 1:4
                        tetris_board(a_shape(1,l),a_shape(2,l)).FaceColor = 'k';
                        tetris_board(a_shape(1,l),a_shape(2,l)).UserData = 'no';
                    end
                    for l = 1:4
                        tetris_board(a_shape(1,l)+1,a_shape(2,l)).FaceColor = 'w';
                        tetris_board(a_shape(1,l)+1,a_shape(2,l)).UserData = 'yes';
                        a_shape(1,l) = a_shape(1,l)+1;
                    end              
                end
            end
        end
    end

    function accelerate(~,~)
        gravity = new_gravity;
    end
    
    function slow_down(hObject,~)
        if strcmp(get(hObject,'CurrentKey'),'downarrow')
            gravity = old_gravity;
        end
    end

    function turn_90(key)
        if choosing_shape ~= 7
            center = a_shape(:,2);
            for k = 1:4
                a_new_shape(1,k) = a_shape(1,k) - center(1,1); 
                a_new_shape(2,k) = a_shape(2,k) - center(2,1);
                tetris_board(a_shape(1,k),a_shape(2,k)).FaceColor = 'k';
                tetris_board(a_shape(1,k),a_shape(2,k)).UserData = 'no';
            end
            for k = 1:4
                if strcmp(key,'a')
                    rotated(1,k) = -a_new_shape(2,k); % x' = xcosf - ysinf
                    rotated(2,k) = a_new_shape(1,k); % y' = xsinf + ycosf
                else
                    rotated(1,k) = a_new_shape(2,k);
                    rotated(2,k) = -a_new_shape(1,k);
                end
            end
            for k = 1:4
                a_new_shape(1,k) = rotated(1,k) + center(1,1);
                a_new_shape(2,k) = rotated(2,k) + center(2,1);
            end
            a_new_shape = fix(a_new_shape); % for not going out of the board or replacing already fallen blocks
            for k = 1:4
                a_shape(1,k) = a_new_shape(1,k);
                a_shape(2,k) = a_new_shape(2,k);
                tetris_board(a_shape(1,k),a_shape(2,k)).FaceColor = 'w';
                tetris_board(a_shape(1,k),a_shape(2,k)).UserData = 'yes';
            end
        end
    end

    function fixed_shape = fix(fixing_shape)
        check_fix_left = false;
        check_fix_right = false;
        %%%%%%%%%%%%% TOOOOO HARD
        for k = 1:4
            if fixing_shape(1,k) < 1 || strcmp(tetris_board(fixing_shape(1,k),fixing_shape(2,k).UserData),'ground')
                fixing_shape(1,:) = fixing_shape(1,:) + 1;
                check_fix_left = true;
            end
        end
        for k = 1:4
            if fixing_shape(1,k) > 10 || strcmp(tetris_board(fixing_shape(1,k),fixing_shape(2,k).UserData),'ground')
                fixing_shape(1,:) = fixing_shape(1,:) - 1;
                check_fix_left = true;
            end
        end
        fixed_shape = fixing_shape;
    end


%     function fixed_shape = fix(fixing_shape)
%         for k = 1:4
%             if fixing_shape(1,k) < 1 || fixing_shape(1,k) > 10 || fixing_shape(2,k) < 1
% %             if strcmp(tetris_board(fixing_shape(1,k),fixing_shape(2,k)).UserData,'ground') || fixing_shape(1,k) < 1 || fixing_shape(1,k) > 10 || fixing_shape(2,k) < 1    
%                 fixing_shape = check_fixing_direction(fixing_shape(1,k),fixing_shape(2,k),fixing_shape);
%             end
%         end
%         fixed_shape = fixing_shape;
%     end
%     
%     function check_fixing_shape = check_fixing_direction(fix_x,fix_y,check_fixing_shape)
%         if fix_x == max(check_fixing_shape(1,k))
%             check_fixing_shape(1,:) = check_fixing_shape(1,:)-1;
%         elseif fix_x == min(check_fixing_shape(1,k))
%             check_fixing_shape(1,:) = check_fixing_shape(1,:)+1;
%         end
%         if fix_y == max(check_fixing_shape(2,k))
%             check_fixing_shape(2,:) = check_fixing_shape(2,:)-1;
%         elseif fix_y == min(check_fixing_shape(2,k))
%             check_fixing_shape(2,:) = check_fixing_shape(2,:)+1;
%         end        
%     end

    function exit_game(~,~)
        delete(tetris_figure)
        close all
    end
end