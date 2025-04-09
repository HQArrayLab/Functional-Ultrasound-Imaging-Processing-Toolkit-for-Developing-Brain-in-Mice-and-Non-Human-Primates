function h = addLines(LL, ip, rx, ry,X,Z,xk,xb,yk,yb)
    L = LL{ip};
    hold on;
    nb = length(L);
    h = gobjects(nb, 1);

    for ib = 3:nb
        x = L{ib};
        xx=x(:, 2)*0.1./rx+X(1);
        yy=x(:, 1)./ry*0.075+Z(1);
        xx=xx.*xk+xb;
        yy=yy.*yk+yb;
%         h(ib) = plot(xx,yy, 'k:','MarkerSize',30);   %截图
       h(ib) = plot(xx,yy, 'w:','MarkerSize',30);   %video
    end

    hold off
end