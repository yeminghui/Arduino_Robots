
function [nIterations,sizePath,path,run_time] =  RRTconnect3D(dim,segmentLength,random_world,show_output)

 start_cord = [5,50,5];
 goal_cord = [95,50,5];

% create random world
Size = 100;

if random_world ==1
    world = createWorld(NumObstacles,ones(1,dim)*Size,zeros(1,dim),dim);
else
    [world NumObstacles] = createKnownWorld(ones(1,dim)*Size,[0;0;0],dim);
end
start_node = [start_cord,0,0,0];
end_node = [goal_cord,0,0,0];

% establish tree starting with the start node
tree = start_node;

a = clock;

% check to see if start_node connects directly to end_node
if ( (norm(start_node(1:dim)-end_node(1:dim))<segmentLength )...
        &&(collision(start_node,end_node,world,dim)==0) )
    path = [start_node; end_node];
else
    nIterations = 0;
    numPaths = 0;
    flag = 0;
    while numPaths<1,
        [tree,flag] = extendTree(tree,end_node,segmentLength,world,dim);
        numPaths = numPaths + flag;
        nIterations = nIterations+1;
    end
end


path = findMinimumPath(tree,end_node,dim);
path = repocess(path,world,dim);
sizePath = size(path,1);

b = clock;

run_time = 3600*(b(4)-a(4)) + 60 * (b(5)-a(5)) + (b(6) - a(6));

if show_output == 1
    % find path with minimum cost to end_node
    figure(6);
    plotExpandedTree(world,tree,dim);
    plotWorld(world,path,dim);
    % figure(2);
    % plotWorld(world,path,dim);
    %plotExpandedTree(world,tree,dim);
end
end





function world = createWorld(NumObstacles, endcorner, origincorner,dim)

if dim ==3;
    % check to make sure that the region is nonempty
    if (endcorner(1) <= origincorner(1)) || (endcorner(2) <= origincorner(2)) || (endcorner(3) <= origincorner(3))
        disp('Not valid corner specifications!')
        world=[];
        
        % create world data structure
    else
        world.NumObstacles = NumObstacles;
        world.endcorner = endcorner;
        world.origincorner = origincorner;
        
        % create NumObstacles
        bounds = [endcorner(1)- origincorner(1), endcorner(2)-origincorner(2), endcorner(3)-origincorner(3)];
        maxRadius = min(bounds);
        maxRadius = 5*maxRadius/NumObstacles;
        for i=1:NumObstacles,
            % randomly pick radius
            world.radius(i) = maxRadius*rand;
            % randomly pick center of obstacles
            cx = origincorner(1) + world.radius(i)...
                + (endcorner(1)-origincorner(1)-2*world.radius(i))*rand;
            cy = origincorner(2) + world.radius(i)...
                + (endcorner(2)-origincorner(2)-2*world.radius(i))*rand;
            cz = origincorner(2) + world.radius(i)...
                + (endcorner(2)-origincorner(2)-2*world.radius(i))*rand;
            world.cx(i) = cx;
            world.cy(i) = cy;
            world.cz(i) = cz;
        end
    end
end
end

function [world NumObstacles] = createKnownWorld(endcorner, origincorner,dim)
  
if dim == 3
    
    NumObstacles = 4;
    % check to make sure that the region is nonempty
    if (endcorner(1) <= origincorner(1)) | (endcorner(2) <= origincorner(2)) | (endcorner(3) <= origincorner(3)),
        disp('Not valid corner specifications!')
        world=[];
        
        % create world data structure
    else
        world.NumObstacles = NumObstacles;
        world.endcorner = endcorner;
        world.origincorner = origincorner;
        
        % create NumObstacles
        maxRadius = 25;
        
        world.radius(1) = maxRadius;
        cx = 50;
        cy = 15;
        cz = 10;
        world.cx(1) = cx;
        world.cy(1) = cy;
        world.cz(1) = cz;
        
        world.radius(2) = maxRadius;
        cx = 50;
        cy = 40;
        cz = 10;
        world.cx(2) = cx;
        world.cy(2) = cy;
        world.cz(2) = cz;
        
        world.radius(3) = maxRadius;
        cx = 50;
        cy = 60;
        cz = 10;
        world.cx(3) = cx;
        world.cy(3) = cy;
        world.cz(3) = cz;
        
        world.radius(4) = maxRadius;
        cx = 50;
        cy = 25;
        cz = 10;
        world.cx(4) = cx;
        world.cy(4) = cy;
        world.cz(4) = cz;
        
%         world.radius(5) = maxRadius;
%         cx = 75;
%         cy = 75;
%         cz = 25;
%         world.cx(5) = cx;
%         world.cy(5) = cy;
%         world.cz(5) = cz;
%         
%         world.radius(6) = maxRadius;
%         cx = 25;
%         cy = 75;
%         cz = 25;
%         world.cx(6) = cx;
%         world.cy(6) = cy;
%         world.cz(6) = cz;
%         
%         world.radius(7) = maxRadius;
%         cx = 75;
%         cy = 25;
%         cz = 25;
%         world.cx(7) = cx;
%         world.cy(7) = cy;
%         world.cz(7) = cz;
%         
%         world.radius(8) = maxRadius;
%         cx = 75;
%         cy = 25;
%         cz = 75;
%         world.cx(8) = cx;
%         world.cy(8) = cy;
%         world.cz(8) = cz;
%         
%         
%         world.radius(9) = maxRadius;
%         cx = 25;
%         cy = 75;
%         cz = 75;
%         world.cx(9) = cx;
%         world.cy(9) = cy;
%         world.cz(9) = cz;
    end
end
end



function node=generateRandomNode(world,dim)

if dim ==2;
    % randomly pick configuration
    px       = (world.endcorner(1)-world.origincorner(1))*rand;
    py       = (world.endcorner(2)-world.origincorner(2))*rand;
    
    chi      = 0;
    cost     = 0;
    node     = [px, py, chi, cost, 0];
    
    % check collision with obstacle
    while collision(node, node, world,dim),
        px       = (world.endcorner(1)-world.origincorner(1))*rand;
        py       = (world.endcorner(2)-world.origincorner(2))*rand;
        
        chi      = 0;
        cost     = 0;
        node     = [px, py, chi, cost, 0];
    end
    
elseif dim ==3;
    % randomly pick configuration
    px       = (world.endcorner(1)-world.origincorner(1))*rand;
    py       = (world.endcorner(2)-world.origincorner(2))*rand;
    pz       = (world.endcorner(3)-world.origincorner(3))*rand;
    
    chi      = 0;
    cost     = 0;
    node     = [px, py, pz, chi, cost, 0];
    
    % check collision with obstacle
    while collision(node, node, world,dim),
        px       = (world.endcorner(1)-world.origincorner(1))*rand;
        py       = (world.endcorner(2)-world.origincorner(2))*rand;
        pz       = (world.endcorner(3)-world.origincorner(3))*rand;
        
        chi      = 0;
        cost     = 0;
        node     = [px, py, pz, chi, cost, 0];
    end
    
end

end





function collision_flag = collision(node, parent, world,dim)

collision_flag = 0;


for i=1:dim
    if (node(i)>world.endcorner(i))|(node(i)<world.origincorner(i))
        collision_flag = 1;
    end
end

if collision_flag == 0 && dim ==2
    for sigma = 0:.2:1,
        p = sigma*node(1:dim) + (1-sigma)*parent(1:dim);
        % check each obstacle
        for i=1:world.NumObstacles,
            if (norm([p(1);p(2)]-[world.cx(i); world.cy(i)])<=1*world.radius(i)),
                collision_flag = 1;
                break;
            end
        end
    end
    
elseif collision_flag == 0 && dim ==3
    for sigma = 0:.2:1,
        p = sigma*node(1:dim) + (1-sigma)*parent(1:dim);
        % check each obstacle
        for i=1:world.NumObstacles,
            if (norm([p(1);p(2);p(3)]-[world.cx(i); world.cy(i); world.cz(i)])<=1*world.radius(i)),
                collision_flag = 1;
                break;
            end
        end
    end
end
end

function connectingNodes = repocess(tree,world,dim)
% find nodes that connect to end_node
connectingNodes = tree(1,:);
i=1;
while i<size(tree,1),
    for j=i+1:size(tree,1),
        if collision(tree(i,:), tree(j,:), world,dim)==0,
            step=tree(j,:);
            flag=j;
        end
    end
    i=flag;
    connectingNodes = [connectingNodes ; step ];
end
end


function collision_flag = is_point_valid(point, world,dim)

collision_flag = 0;


for i=1:dim
    if (point(i)>world.endcorner(i))||(point(i)<world.origincorner(i))
        collision_flag = 1;
    end
end

if collision_flag == 0 && dim ==2
    
    p = point(1:dim);
    % check each obstacle
    for i=1:world.NumObstacles,
        if (norm([p(1);p(2)]-[world.cx(i); world.cy(i)])<=1*world.radius(i)),
            collision_flag = 1;
            break;
        end
    end
    
elseif collision_flag == 0 && dim ==3
    p = point(1:dim);
    % check each obstacle
    for i=1:world.NumObstacles,
        if (norm([p(1);p(2);p(3)]-[world.cx(i); world.cy(i); world.cz(i)])<=1*world.radius(i)),
            collision_flag = 1;
            break;
        end
    end
end
end



function flag = canEndConnectToTree(tree,end_node,minDist,world,dim)
flag = 0;
% check only last node added to tree since others have been checked
if ( (norm(tree(end,1:dim)-end_node(1:dim))<minDist)...
        & (collision(tree(end,1:dim), end_node(1:dim), world,dim)==0) ),
    flag = 1;
end

end








function [new_tree,flag] = extendTree(tree,end_node,segmentLength,world,dim)

flag = 0;
% select a random point
randomPoint = zeros(1,dim);
for i=1:dim
    randomPoint(1,i) = (world.endcorner(i)-world.origincorner(i))*rand;
end



% find leaf on node that is closest to randomPoint
tmp = tree(:,1:dim)-ones(size(tree,1),1)*randomPoint;
sqrd_dist = sqr_eucl_dist(tmp,dim);
[min_dist,idx] = min(sqrd_dist);

min_parent_idx = idx;

new_point = tree(idx,1:dim);
new_node = tree(idx,:);

pflag = 0;


while norm(new_point-randomPoint)>0 && pflag==0
    
    
    if norm(new_point-randomPoint)<segmentLength
        
        pflag = collision(randomPoint,tree(min_parent_idx,:),world,dim);
        if pflag == 0
            
            new_point = randomPoint;
            min_cost = cost_np(tree(min_parent_idx,:),new_point,dim);
            new_node = [new_point,0,min_cost,min_parent_idx];
            tree = [tree;new_node];
            pflag = 1;
            goal_flag = is_goal(new_node,end_node,segmentLength,world,dim);
            
            if goal_flag == 1;
                tree(end,dim+1)=1;
                flag = 1;
            end
        end
    else
        
        new_point = (randomPoint-tree(min_parent_idx,1:dim));
        new_point = tree(min_parent_idx,1:dim)+(new_point/norm(new_point))*segmentLength;
        
        min_cost  = cost_np(tree(min_parent_idx,:),new_point,dim);
        new_node  = [new_point, 0, min_cost, min_parent_idx];
        
        pflag = collision(new_node,tree(min_parent_idx,:),world,dim);
        
        if pflag == 0
            tree = [tree ; new_node];
            min_parent_idx = size(tree,1);
            
            goal_flag = is_goal(new_node,end_node,segmentLength,world,dim);
            
            if goal_flag == 1;
                tree(end,dim+1)=1;  % mark node as connecting to end.
                pflag = 1;
                flag = 1;
            end
        end
    end
end

new_tree = tree;

end




function goal_flag = is_goal(node,end_node,segmentLength,world,dim)

goal_flag = 0;
if (norm(node(1:dim)-end_node(1:dim))<segmentLength )...
        && (collision(node,end_node,world,dim)==0)
    goal_flag = 1;
end

end



function e_dist = sqr_eucl_dist(array,dim)

sqr_e_dist = zeros(size(array,1),dim);
for i=1:dim
    
    sqr_e_dist(:,i) = array(:,i).*array(:,i);
    
end
e_dist = zeros(size(array,1),1);
for i=1:dim
    
    e_dist = e_dist+sqr_e_dist(:,i);
    
end

end



%calculate the cost from a node to a point
function [cost] = cost_np(from_node,to_point,dim)

diff = from_node(:,1:dim) - to_point;
eucl_dist = norm(diff);
cost = from_node(:,dim+2) + eucl_dist;

end


%calculate the cost from a node to a node
function [cost] = cost_nn(from_node,to_node,dim)

diff = from_node(:,1:dim) - to_node(:,1:dim);
eucl_dist = norm(diff);
cost = from_node(:,dim+2) + eucl_dist;

end

function [cost] = line_cost(from_node,to_point,dim)
diff = from_node(:,1:dim) - to_point;
cost = norm(diff);
end





function path = findMinimumPath(tree,end_node,dim)

% find nodes that connect to end_node
connectingNodes = [];
for i=1:size(tree,1),
    if tree(i,dim+1)==1,
        connectingNodes = [connectingNodes ; tree(i,:)];
    end
end

% find minimum cost last node
[tmp,idx] = min(connectingNodes(:,dim+2));

% construct lowest cost path
path = [connectingNodes(idx,:); end_node];
parent_node = connectingNodes(idx,dim+3);
while parent_node>1,
    parent_node = tree(parent_node,dim+3);
    path = [tree(parent_node,:); path];
end

end



function plotExpandedTree(world,tree,dim)
ind = size(tree,1);
while ind>0
    size(tree);
    branch = [];
    node = tree(ind,:);
    branch = [ branch ; node ];
    parent_node = node(dim+3);
    while parent_node > 1
        cur_parent = parent_node;
        branch = [branch; tree(parent_node,:)];
        parent_node = tree(parent_node,dim+3);
    end
    ind = ind - 1;
    
    if dim == 2
        X = branch(:,1);
        Y = branch(:,2);
        
        p = plot(X,Y);
        set(p,'Color','r','LineWidth',0.5,'Marker','.','MarkerEdgeColor','g');
        hold on;
        
    elseif dim == 3
        X = branch(:,1);
        Y = branch(:,2);
        Z = branch(:,3);
        
        p = plot3(X,Y,Z);
        set(p,'Color','r','LineWidth',0.5,'Marker','.','MarkerEdgeColor','g');
        hold on;
    end
end
end




function plotWorld(world,path,dim)
% the first element is the north coordinate
% the second element is the south coordinate
if dim ==2
    
    N = 10;
    th = 0:2*pi/N:2*pi;
    axis([world.origincorner(1),world.endcorner(1),...
        world.origincorner(2), world.endcorner(2)]);
    hold on
    
    for i=1:world.NumObstacles,
        X = world.radius(i)*sin(th) + world.cx(i);
        Y = world.radius(i)*cos(th) + world.cy(i);
        fill(X,Y,'blue');
    end
    
    X = path(:,1);
    Y = path(:,2);
    p = plot(X,Y);
    
elseif dim ==3
    axis([world.origincorner(1),world.endcorner(1),...
        world.origincorner(2), world.endcorner(2),...
        world.origincorner(3), world.endcorner(3)]);
    hold on
    
    for i=1:world.NumObstacles,
        [X Y Z] = sphere(10);
        X = (X*world.radius(i));
        Y = (Y*world.radius(i));
        Z = (Z*world.radius(i));
        surf(X+world.cx(i),Y+world.cy(i),Z+world.cz(i));
        colormap([0.5 0.2 0.3]);
    end
    
    X = path(:,1);
    Y = path(:,2);
    Z = path(:,3);
    p = plot3(X,Y,Z);
end
set(p,'Color','black','LineWidth',3)
xlabel('X axis');
ylabel('Y axis');
zlabel('Z axis');
title('RRT Connect Algorithm');
end
