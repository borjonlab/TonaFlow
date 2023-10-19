function flag = isequaltol2(a,b,tol)
    % flag = [];
    % for i = 1:numel(a)
    %     if isequaltol(a(i),b,tol)
    %         flag(size(flag,1) + 1) = i;
    %     end
    % end

    flag = find((a>= b-tol) & (a <= b+tol));
end

