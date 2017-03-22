function [networkTableInfo] = mainNetworksCCs(numCell, classOfCell, serieOfCell, distanceMatrix, adjacencyMatrix)
%
%
%	Developed by Daniel Sanchez-Gutierrez improved by Pedro Gomez-Galvez

weigth_graph = distanceMatrix .* adjacencyMatrix;

%% Basic measurements
n_connections_per_node=degrees_und(adjacencyMatrix);%% number of connections of each node
mean_n_connections_per_node=mean(full(n_connections_per_node));
std_n_connections_per_node=std(full(n_connections_per_node));

strengths=strengths_und(weigth_graph); %%Sum of weights of links connected to the node
mean_strengths=mean(strengths);
std_strengths=std(strengths);

%% Resistence measurements
assortativity_cc=assortativity(weigth_graph,0); %possitive value indicates nodes tend to joir to others with similiar degree
density=density_und(weigth_graph);%Fraction of products of degrees across all edges
%% Segregation measurements
Coef_cluster=clustering_coef_wu(weigth_graph);  %the fraction of node�s neighbors that are neighbors of each other
mean_coef_cluster=mean(Coef_cluster);
std_coef_cluster=std(Coef_cluster);

transitivity=transitivity_wu(weigth_graph);  %Ratio of 'triangles to triplets'.alternative to coef cluster
[optime_structure,maximated_modularity]=modularity_und(weigth_graph); %quantify the degree in which the network may be subdivided into such clearly delineated groups
mean_optime_structure=mean(optime_structure);
std_optime_structure=std(optime_structure);

%% Integration measurements
[lambda,efficiency,eccentricity,radius,diameter]=charpath(weigth_graph) ;
%lambda: mean graph distance
%efficiency: inverse shortest path in a network
%eccentricity: shortest path length between a node and any other node
%radius: minimun eccentricity
%diameter:maximum eccentricity. shortest path length in Aging dots case

mean_eccentricity=mean(eccentricity);
std_eccentricity=std(eccentricity);

%% Centrality measurements
betweenness_centrality=betweenness_wei(weigth_graph);

mean_BC=mean(betweenness_centrality);
std_BC=std(betweenness_centrality);

%% ShortestPathLength measurements
shortestPathDist = graphallshortestpaths(sparse(weigth_graph), 'Directed', false);%sparse graph
auxAllShortestPath=shortestPathDist.*(triu(shortestPathDist)~=0);
meanAllShortestPath=mean(auxAllShortestPath(auxAllShortestPath~=0));
stdAllShortestPath=std(auxAllShortestPath(auxAllShortestPath~=0));

networkTableInfo = table(str2num(numCell), {classOfCell}, {serieOfCell}, mean_n_connections_per_node, std_n_connections_per_node, mean_strengths,std_strengths, assortativity_cc, density, mean_coef_cluster, std_coef_cluster, transitivity, mean_optime_structure, std_optime_structure,maximated_modularity,lambda,efficiency,mean_eccentricity,std_eccentricity,radius,diameter, mean_BC,std_BC,meanAllShortestPath,stdAllShortestPath);
networkTableInfo.Properties.VariableNames{1} = 'numCell';
networkTableInfo.Properties.VariableNames{2} = 'classOfCell';
networkTableInfo.Properties.VariableNames{3} = 'serieOfCell';