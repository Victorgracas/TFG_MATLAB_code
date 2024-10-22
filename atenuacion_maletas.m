function [distancia_total, atenuacion_total] = atenuacion_maletas(maletas_pos, maletas_dim, pos_lector, pos_tag, Atenuacio_maleta)
    distancia_total = 0;  % Inicializar la distancia total cruzada por maletas
    atenuacion_total = 0;  % Atenuación total

    % Iterar sobre cada maleta
    for i = 1:size(maletas_pos, 1)
        % Obtener la posición y las dimensiones de la maleta actual
        maleta_centro = maletas_pos(i, :);
        maleta_dim = maletas_dim(i, :);

        % Crear un vector con las esquinas de la maleta (considerando un cubo)
        maleta_min = maleta_centro - maleta_dim / 2;
        maleta_max = maleta_centro + maleta_dim / 2;

        % Comprobar si el vector lector-tag atraviesa la maleta
        [intersecta, t_min, t_max] = intersecta_maleta(pos_lector, pos_tag, maleta_min, maleta_max);

        if intersecta
            % Calcular la distancia que el vector cruza dentro de la maleta
            direc_vector = pos_tag - pos_lector;  % Vector que conecta la antena con el tag
            distancia_cruzada = norm(direc_vector) * (t_max - t_min);  % Longitud del segmento que cruza la maleta
            distancia_total = distancia_total + distancia_cruzada;  % Sumar la distancia cruzada a la distancia total

            % Sumar la atenuación correspondiente
            atenuacion_total = atenuacion_total + (Atenuacio_maleta*distancia_total);
        end
    end
end

function [intersecta, t_min, t_max] = intersecta_maleta(pos_lector, pos_tag, maleta_min, maleta_max)
    % Comprobar si el vector intersecta con la caja de la maleta usando un test de intersección
    % Convertimos el problema de intersección de un segmento de línea con un cubo a un rango de t en [0, 1]
    
    direc_vector = pos_tag - pos_lector;

    % Eje X
    if direc_vector(1) ~= 0
        t_min_x = (maleta_min(1) - pos_lector(1)) / direc_vector(1);
        t_max_x = (maleta_max(1) - pos_lector(1)) / direc_vector(1);
        if t_min_x > t_max_x
            [t_min_x, t_max_x] = deal(t_max_x, t_min_x);
        end
    else
        t_min_x = -inf;
        t_max_x = inf;
    end

    % Eje Y
    if direc_vector(2) ~= 0
        t_min_y = (maleta_min(2) - pos_lector(2)) / direc_vector(2);
        t_max_y = (maleta_max(2) - pos_lector(2)) / direc_vector(2);
        if t_min_y > t_max_y
            [t_min_y, t_max_y] = deal(t_max_y, t_min_y);
        end
    else
        t_min_y = -inf;
        t_max_y = inf;
    end

    % Eje Z
    if direc_vector(3) ~= 0
        t_min_z = (maleta_min(3) - pos_lector(3)) / direc_vector(3);
        t_max_z = (maleta_max(3) - pos_lector(3)) / direc_vector(3);
        if t_min_z > t_max_z
            [t_min_z, t_max_z] = deal(t_max_z, t_min_z);
        end
    else
        t_min_z = -inf;
        t_max_z = inf;
    end

    % Encontrar el máximo del mínimo y el mínimo del máximo para determinar si hay intersección
    t_min = max([t_min_x, t_min_y, t_min_z]);
    t_max = min([t_max_x, t_max_y, t_max_z]);

    % Si el máximo del mínimo es menor que el mínimo del máximo, hay intersección
    intersecta = t_min <= t_max && t_max >= 0 && t_min <= 1;
end
