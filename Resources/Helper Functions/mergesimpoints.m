function mergesimpoints(a,thresh)
    df = find(diff(a) > thresh);
end