%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot the track
figure; hold on;
plot(x_center, y_center, '--k', 'LineWidth', 1); % Track
plot(x_inner, y_inner, 'r', 'LineWidth', 1);  % Inner Track
plot(x_outer, y_outer, 'r', 'LineWidth', 1);  % Outer Track
grid on;

% Formatting
title('Race Track');
xlabel('X Position (m)');
ylabel('Y Position (m)');
xlim([-800, 800]);
ylim([-200, 600]);

%Running the simulink 

simout = sim("Proj4_FINAL.slx", 'ReturnWorkspaceOutputs', 'on')
car_simx = simout.X.Data;
car_simy = simout.Y.Data;
sim_SOC = simout.SOC.Data; % Ensure correct simulation output extraction
sim_SOCt= simout.SOC.Time;

% Defining the animated line
car_path = animatedline('Color', 'r', 'LineWidth', 2);

% Define square size
car_size = 10; % Length of the square's sides

% Defining car as square
%Defining x and y vertices and sizing the car using a car size of 10
car_x = [-1 1 1 -1] * car_size; 
car_y = [-1 -1 1 1] * car_size;
car_patch = patch(x_center(1) + car_x, y_center(1) + car_y, 'b'); %starting the car at the initial x and y points on the centerline

% Animation Loop
num_frames = length(car_simx);
for i = 1:num_frames
    %Updates animated line
    addpoints(car_path, car_simx(i), car_simy(i));

    % Updates car position 
    set(car_patch, 'XData', car_simx(i) + car_x, 'YData', car_simy(i) + car_y);

    drawnow;
end

timer = toc; % end timer

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% outputs the time it took to complete the final script time
disp(['The FINAL_SCRIPT took ', num2str(timer), ' seconds to run.']);

% coutns loops compared to the threshold
loop_count = 0;
loop_threshold = 0;  % line thereshold
out_of_bounds = false;  % flag if car is out of bounds
car_simx = simout.X.Data;  % Extract X data from FINAL_SCRIPT.m
car_simy = simout.Y.Data;  % Extract Y data from FINAL_SCRIPT.m

% Track boundaries from FINAL_SCRIPT
x_inner = [x_straightB_in, x_curveR_in, x_straightT_in, x_curveL_in];
y_inner = [y_straightB_in, y_curveR_in, y_straightT_in, y_curveL_in];
x_outer = [x_straightB_out, x_curveR_out, x_straightT_out, x_curveL_out];
y_outer = [y_straightB_out, y_curveR_out, y_straightT_out, y_curveL_out];

% loop to check both in car bounds and threshold passed for one loop
for i = 2:length(car_simx)
    % checks if car crosses the threshold (start/end) of one loop
    if car_simx(i-1) < loop_threshold && car_simx(i) >= loop_threshold
        loop_count = loop_count + 1;
    end

    % checks if car is between defined track parameters of inner and outer bounds
    distance_to_inner = sqrt((car_simx(i) - x_inner).^2 + (car_simy(i) - y_inner).^2);
    distance_to_outer = sqrt((car_simx(i) - x_outer).^2 + (car_simy(i) - y_outer).^2);

    % if out of bounds, it calls the flag aboe
    if any(distance_to_inner < 0) || any(distance_to_outer < 0)
        out_of_bounds = true;
        break;  % stops loop if car is out of track width
    end
end

% outputs the total number of loops
disp(['Number of loops: ', num2str(loop_count)]);

% determines car in track or out otuput
if out_of_bounds
    car_status = 'Car went out of track bounds.';
else
    car_status = 'Car stayed within track bounds.';
end

% outputs the car track status
disp(car_status);



figure;
hold on;
grid on;
plot(sim_SOCt,sim_SOC, 'b')
xlabel('Time (s)');
ylabel('State of Charge (%)');
title('SOC vs. Time');
hold off;
