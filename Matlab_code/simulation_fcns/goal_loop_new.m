% todo: add animation to see what is going on

% note 1: make sure that the initial conditions for ODEs are updated for each run

%% add required paths and data
% clear all;
load('../results/360seconds_systemID_tendondriven_babbling_model.mat')
load handel
all_rewards=zeros(1,200);
all_attempt_numbers=zeros(1,200);
all_return_numbers=zeros(1,200);

%%  initializations
T=10; % simulations length
framespersec=500; % fs
dt=1/framespersec;
tspan_features=linspace(0,T,T*framespersec);
number_of_feautures=10; %T*fs should be = to number_of_features * each_feature_lenght
each_feature_length=500;
done=false;
best_reward=-1000;
net_adapt=net;
best_features=zeros(1,10);
best_pattern_run_kinematics=[];
best_input_force_values=[];
run_numbers = [0 0];
rewards=[];
best_rewards_mode1=[];
best_rewards_mode2=[];
Y_thresh = -1.9; %with -1.85 Y_thresh, 1.9 is almost the highest possible reward
angle_limiting_factor = 0.8;
phase_goal_reward = 1.0;
fine_run_limit = 15;
%% main loop
%coarse search
while ~done%reward < 3
% end_flag=true;
    pause(5)
    close all;nnet.guis.closeAllViews();
    [net_adapt, new_features, run_numbers, done, search_mode] = ...
        generate_new_action_fcn(reinforce_type, phase_goal_reward, net_adapt, best_pattern_run_kinematics, best_input_force_values, best_reward, best_features, run_numbers, fine_run_limit, tspan_features);
    if ~done    
        [new_reward, new_pattern_run_kinematics, new_input_force_values, new_desired_angs_and_locs, new_real_angs_and_locs] = ...
            run_simulation_get_reward_fcn(new_features, net_adapt, tspan_features,dt,ode_params_init, options, Y_thresh, angle_limiting_factor);
        new_reward
        best_reward
        %physical system will get activation trajectories instead of features as the input.
        %it is easier to work with for the simulation to have feature.
        if new_reward>best_reward
            %net = new_net;
            best_reward = new_reward;
            best_features = new_features;
            best_pattern_run_kinematics = new_pattern_run_kinematics;
            best_input_force_values = new_input_force_values;
            best_desired_angs_and_locs = new_desired_angs_and_locs;
            best_real_angs_and_locs = new_real_angs_and_locs;
            best_run_model=net_adapt;
        end
        rewards = [rewards; new_reward];
        if strcmp(search_mode,'c')
            best_rewards_mode1=[best_rewards_mode1;best_reward];
        else
            best_rewards_mode2=[best_rewards_mode2;best_reward];
        end
    end
end
