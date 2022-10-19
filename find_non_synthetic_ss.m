% Small script that searches the 
% https://suitesparse-collection-website.herokuapp.com/ database of Sparse
% Matrices, and finds the non-random ones (ie real world problem ones)
% The function can take up to 3 arguments: write_to_file, 
% is_symmetric, load_mat, in that order
% Defaults to finding only symmetric matrices, writing their names to a
% file, and not loading them into the workspace
%
% @args:
% write_to_file => if 1, it writes the name of the matrices that fit the
%                  query in a txt file
%
% is_symmetric  => if 1, it searches only for symmetric matrices. 
%                  Otherwise, non-symmetric matrices will be included
%
% load_mat      => if 1, it loads the matrices to the workspace, in a 
%                  cell array that holds the Problem struct for each matrix

function [problems] = find_non_synthetic_ss(varargin)

    % Handle input args
    write_to_file = 1; is_symmetric = 1; load_mat = 0;
    switch nargin
        case 1
           write_to_file = varargin{1};
        case 2
           write_to_file = varargin{1};
           is_symmetric = varargin{2};
        case 3
           write_to_file = varargin{1};
           is_symmetric = varargin{2};
           load_mat = varargin{3};
    end
    
    % Open file if needed
    if write_to_file
        fid = fopen("sparse_mat_query.txt", "w");
    end

    % Get index of the SuiteSparse Matrix Collection
    index = ssget ;           
    
    % Find which matrices are symmetric, if needed
    if is_symmetric
        ids = find (index.numerical_symmetry == 1);
    end

    % Sort by increasing size as measured by nnz(A): 
    [~, i] = sort (index.nnz (ids)) ;
    ids = ids (i) ;

    % Load kind of problem each matrix tackles
    kinds = sskinds ;
    t = zeros (1, length (kinds)) ;
    
    % And keep only the non-random ones
    for id = ids
       t (id) = isempty (strfind (kinds {id}, 'random')) ;
    end
    t = find (t) ;
    
    % Empty array to be returned if matrices not loaded in the ws
    problems = [];
    
    i = 1;
    for id = t
        
        % Load mat in the problems cell array if needed
        if load_mat
            Problem = ssget (id);
            problems{i} = Problem;
            i = i + 1;
        end
       
        % Write mat's name to a file if needed
        if write_to_file
            group = index.Group{id};
            name = index.Name{id};

            fullname = group + "\" + name;
            
            fprintf(fid, '%s \n', fullname);
        end
    end
    
    if write_to_file
        fclose(fid);
    end
end