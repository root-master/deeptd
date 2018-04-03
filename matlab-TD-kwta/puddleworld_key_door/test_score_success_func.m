function [successful_key_door_episodes, successful_key_episodes, scores_vec, total_episodes] = test_score_success_func(ep,Wih, biasih, Who, biasho)

withBias = 1;

nMeshx = 20; nMeshy = 20;

successful_key_door_episodes = [];
successful_key_episodes = [];
scores_vec = [];
% Input of function approximator
xgridInput = 1.0 / nMeshx;
ygridInput = 1.0 / nMeshy;
xInputInterval = 0 : xgridInput : 1.0;
yInputInterval = 0 : ygridInput : 1.0;

% the number of states -- This is the gross mesh states ; the 1st tiling 
nStates = length(xInputInterval) * length(yInputInterval); 

% on each grid we can choose from among this many actions 
% [ up , down, right, left ]
% (except on edges where this action is reduced): 
nActions = 4; 

%% kwta and regular BP Neural Network
% Weights from input (x,y,x_goal,y_goal) to hidden layer
InputSize = 2 * ( length(xInputInterval) + length(yInputInterval ));
nCellHidden = round(0.5 * nStates);

xgrid = 1 / (nMeshx);
ygrid = 1 / (nMeshy);
% parameter of Gaussian Distribution
sigmax = 1.0 / nMeshx; 
sigmay = 1.0 / nMeshy;

ep_id = 1;
total_episodes = 0;
for x=xInputInterval,
    for y=yInputInterval,
        
        agentReached2Key = false;
        agentReached2Door = false;
        agentBumped2wall = false;
        t = 1;
        scores = 0;
        first_time_visit_key = false;
        
        s=[x,y];
        [agentinPuddle,~] = CreatePuddle(s);
        if agentinPuddle
            continue
        end
        
        
        keyinPuddle = true;
        
        while keyinPuddle
            key = initializeState(xInputInterval,yInputInterval);
            [keyinPuddle,~] = CreatePuddle(key);
        end
        
        doorinPuddle = true;
     
        while doorinPuddle
            door = initializeState(xInputInterval,yInputInterval);
            [doorinPuddle,~] = CreatePuddle(door);
        end
        
        g = key;
        while(t<=84)
            if success(s,key) && ~first_time_visit_key
                agentReached2Key = true;
                scores = scores + 10;
                g = door;
                successful_key_episodes = [successful_key_episodes, ep_id];
                first_time_visit_key = true;
            end
            
            if agentReached2Key
               if success(s,door)
                   agentReached2Door = true;
                   scores = scores + 100;
                   successful_key_door_episodes = [successful_key_door_episodes, ep_id];
                   scores_vec = [scores_vec, scores];
                   break
               end
            end
            
            
             sx = sigmax * sqrt(2*pi) * normpdf(xInputInterval,s(1),sigmax);
             sy = sigmay * sqrt(2*pi) * normpdf(yInputInterval,s(2),sigmay);
             gx = sigmax * sqrt(2*pi) * normpdf(xInputInterval,g(1),sigmax);
             gy = sigmay * sqrt(2*pi) * normpdf(yInputInterval,g(2),sigmay);
             % Using st as distributed input for function approximator
             st = [sx,sy,gx,gy];                
             Q = kwta_NN_forward_new(st, Wih, biasih, Who, biasho);
             [~,a] = max(Q);
             sp1 = UPDATE_STATE(s,a,xgrid,xInputInterval,ygrid,yInputInterval);
             if all(s==sp1)
                 agentBumped2wall = true;
             end
             rew = ENV_REWARD(sp1);
             scores = scores + rew;
             
             s = sp1;
             t = t+1;
             if t == 84
                 scores_vec = [scores_vec, scores];
                 break
             end
            
        end
                
    ep_id = ep_id + 1;
    total_episodes = total_episodes + 1;
    end
end
