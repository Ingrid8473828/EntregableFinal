clc; clear; close all;

v = 0.5;
dx = -0.5;
dy = 0;
dz = 0;
largo_rojo = 4;
largo_azul=largo_rojo/4;
ancho = -0.2;
max_iter=5000;
iter=0;

x_roja = dx;
x_azul = dx + 1;

figure;
hold on;
axis equal;
grid on;

n_cargas = 500; % cantidad de cargas
ys_rojo = linspace(-largo_rojo/2, largo_rojo/2, n_cargas);
ys_azul = linspace(-largo_azul/2, largo_azul/2, n_cargas);

[x,y] = meshgrid(-10:0.05:10, -10:0.05:10);
Ex = zeros(size(x));
Ey = zeros(size(y));
V = zeros(size(x));

num_globulos = 30; 
dt = 0.02;         
espacio_x_final = 2.5; 

for i = 1:n_cargas
    
    % placa roja (+)
    xr = x_roja;
    yr = ys_rojo(i);
    
    rx = x - xr;
    ry = y - yr;
    r = sqrt(rx.^2 + ry.^2 + 0.01);
    
    Ex = Ex + rx ./ r.^3;
    Ey = Ey+ ry ./ r.^3;
    V = V + 1 ./ r;
    
    
    % placa azul (-)
    xb = x_azul;
    yb = ys_azul(i);
    
    rx = x - xb;
    ry = y - yb;
    r = sqrt(rx.^2 + ry.^2 + 0.01);
    
    Ex = Ex - rx ./ r.^3;
    Ey = Ey - ry ./ r.^3;
    V = V - 1 ./ r;

end

%rnp=sqrt((xe-(dx+1)-xr(k))^2+(ye-yr(k))^2);
%rnn=sqrt((xe-(dx+1)-xb(k))^2+(ye-yb(k))^2);

%rpp=sqrt((xe+(dx+1)-xr(k))^2+(ye-yr(k))^2);
%rpn=sqrt((xe+(dx+1)-xb(k))^2+(ye-yb(k))^2);


pcolor(x,y,V);
contourf(x, y, V, 40,'-w', 'LineWidth', 0.5);
colormap bone;
shading interp;
colorbar;
sx = linspace(-3, 3, 13);
sy = linspace(-3, 3, 13);
[SX, SY] = meshgrid(sx, sy);

streamline(x, y, Ex, Ey, SX, SY);

filename = 'resultados.csv';
fid = fopen(filename, 'w');
fprintf(fid, 'id,pos_x,pos_y,iter,clasificacion\n');

for g = 1:num_globulos
    
    % Posicion
    pos_x = x_roja+0.5;
    pos_y = (rand() - 0.5) * 2;
    
    % Propiedades físicas
    if rand() > 0.5
        clase=0;
        color_trazo="g";
        q = 0.8e-6;
        m = 1.0;
        estado_final="Sana";
    else
        clase=1;
        color_trazo="r";
        q = 1.4e-6;
        vol_parasito=0.1+rand()*0.8;
        m = 1.0+(vol_parasito*0.2);
        estado_final="Parasitada";
    end
    
    trayectoria_x = pos_x;
    trayectoria_y = pos_y;

    iter = 0;
    
    vx = 0; 
    vy = -0.7;

    ke = 9e9;        % constante de Coulomb
    dqn = -1e-5;     % carga elemental placa azul
    dqn_i=dqn/n_cargas;

    while pos_x < espacio_x_final && abs(pos_y) < 2 && iter < max_iter
        iter = iter + 1;
      
        Fx = 0; 
        Fy = 0;
    
        for k = 1:n_cargas
            rx = pos_x - x_azul;
            ry = pos_y - ys_azul(k);
            r = sqrt(rx^2 + ry^2 + 0.01);
        
            Fx = Fx + (ke * dqn_i * q * rx / r^3);
            Fy = Fy + (ke * dqn_i * q * ry / r^3);
        end
        
        %for k = 1:n_cargas
          %  rx = pos_x - x_roja;
           % ry = pos_y - ys_rojo(k);
            %r = sqrt(rx^2 + ry^2 + 0.01);
        
       %     Fx = Fx + (ke * dqp_i * q * rx / r^3);
        %    Fy = Fy + (ke * dqp_i * q * ry / r^3);
        %end
    
        ax = (Fx) / m;
        ay = (Fy) / m;
    
        vx = vx + ax * dt;
        vy = vy + ay * dt;
        %vx=vx+0.01;
    
        pos_x = pos_x + vx * dt;
        pos_y = pos_y + vy * dt;
    
        trayectoria_x(end+1) = pos_x;
        trayectoria_y(end+1) = pos_y;
    end
    
    % Clasificación
    %if pos_x > 1.5 && abs(pos_y) < 0.5
      %  estado_final = 'Sana';
     %   color_trazo = 'g';
    %else
      %  estado_final = 'Parasitada';
     %   color_trazo = 'r';
    %end
    
    % CSV
    fprintf(fid, '%d,%.4f,%.4f,%d,%f\n', g, pos_x, pos_y, iter, clase);
    
    plot(trayectoria_x, trayectoria_y, 'Color', color_trazo);

    drawnow;
    
    fprintf('Glóbulo %d → (%.2f, %.2f) → %s\n', g, pos_x, pos_y, estado_final);
end

fclose(fid);

function vertices = crear_placa(xc, yc, ancho, largo, v)

    vertices = [
        -v*ancho+xc, -v*largo+yc;
        -v*ancho+xc,  v*largo+yc;
        v*ancho+xc,  v*largo+yc;
        v*ancho+xc, -v*largo+yc
    ];

end

vertices_roja = crear_placa(x_roja, dy, ancho, largo_rojo, v);
vertices_azul = crear_placa(x_azul, dy, ancho*0.5, largo_azul, v);

fill(vertices_roja(:,1), vertices_roja(:,2), 'r', 'FaceAlpha', 0.7, 'EdgeColor', 'r');
fill(vertices_azul(:,1), vertices_azul(:,2), 'b', 'FaceAlpha', 0.7, 'EdgeColor', 'b');

xlim([-3 3]);
ylim([-3 3]);
xlabel('Posición X (mm)');
ylabel('Posición Y (mm)');
title('Potencial Eléctrico y Líneas de Campo');