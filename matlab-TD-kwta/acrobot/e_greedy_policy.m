function action = e_greedy_policy(Q,nActions,epsilon)
% pick action using an epsilon greedy policy derived from Q: 
 
  if( rand<epsilon ),        
         % explore ... with a random action 
           action=randi(nActions); 
  else 
        [~,action] = max(Q); 
  end