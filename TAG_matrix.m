function [maletas_pos, maletas_dim, tags_pos,rader_pos] = TAG_matrix(flag_tag_pos, flag_bag_rand, reader_pos, vectors_dir, graficas,compare_reader)
    % Parámetros de la caja (en metros)
    length_caja = 110 * 0.0254; % 110 pulgadas a metros
    width_caja = 50 * 0.0254;   % 50 pulgadas a metros
    height_caja = 54 * 0.0254;  % 54 pulgadas a metros

    % Parámetros de las maletas
    maleta_length_base = 0.69; % Longitud base de la maleta en metros (paralelo al ancho del carro)
    maleta_width_base = 0.46;  % Ancho base de la maleta en metros (paralelo al largo del carro)
    maleta_height_base = 0.26; % Altura base de la maleta en metros (paralelo a la altura del carro)
        
    % Número de filas y columnas de maletas
    rows = 3;    % 3 filas (una sobre otra)
    columns = 12; % 12 maletas (2 columnas de 6 por fila)

    % Inicialización de las posiciones y dimensiones de las maletas
    maletas_pos = zeros(rows * columns, 3); % Posiciones [x, y, z]
    maletas_dim = zeros(rows * columns, 3); % Dimensiones [l, w, h]
    tags_pos = zeros(rows * columns, 3);    % Posiciones de los TAGs [x, y, z]
    

    % Posición inicial del centro en x (ancho del carro)
    x_center = width_caja / 2;
    y_start = 0; % Empezar al principio del carro en la dirección del largo

    % Mantener el gráfico actual para dibujar múltiples elementos
    if graficas
        figure;
        hold on;
        view(-40,19);
    end

    % Generar la primera columna de maletas (alineada al centro y hacia un lado)
    contador = 1;
    y_pos = y_start; % Posición y inicial

    for j = 1:6
        if strcmp(flag_bag_rand, 'random')
            % Generar dimensiones aleatorias para la maleta
            factor_longitud = 0.8 + (1.2 - 0.8) * rand();  % Longitud paralelo al ancho del carro
            factor_ancho = 0.8 + (1.2 - 0.8) * rand();     % Ancho paralelo al largo del carro
            factor_altura = 0.8 + (1.2 - 0.8) * rand();    % Altura paralelo a la altura del carro
        else
            factor_longitud = 1;
            factor_ancho = 1;
            factor_altura = 1;
        end

        l = maleta_length_base * factor_longitud;  % Lado largo paralelo al ancho del carro
        w = maleta_width_base * factor_ancho;      % Lado corto paralelo al largo del carro
        h = maleta_height_base * factor_altura;    % Altura

        if (y_pos + w > length_caja)
            w = length_caja - y_pos;
        end

        % Posición de la maleta
        x = x_center - l/2; % Alineamos la maleta desde el centro hacia un lado (negativo)
        y = y_pos + w/2;    % Colocar la maleta empezando desde el principio del carro
        z = h/2;            % La primera fila está en el suelo, así que la altura es la mitad de la maleta

        % Actualizar la posición en y para la próxima maleta
        y_pos = y_pos + w;

        % Almacenar la posición y dimensiones de la maleta
        maletas_pos(contador, :) = [x, y, z];
        maletas_dim(contador, :) = [l, w, h];

        % Dibujar la maleta en color cyan solo si graficas == true
        if graficas
            draw_box(x, y, z, l, w, h);
        end

        % Determinar la posición del TAG
        tags_pos(contador, :) = calcular_tag_pos(x, y, z, l, w, h, flag_tag_pos, x <= x_center);

        % Dibujar el TAG como un pequeño punto solo si graficas == true
        if graficas
            plot3(tags_pos(contador, 1), tags_pos(contador, 2), tags_pos(contador, 3), 'ro', 'MarkerSize', 5, 'MarkerFaceColor', 'r');
        end

        contador = contador + 1;
    end

    % Generar la segunda columna enfrentada (alineada al centro y hacia el otro lado)
    y_pos = y_start; % Reiniciar y_pos para la segunda columna

    for j = 7:12
        if strcmp(flag_bag_rand, 'random')
            % Generar dimensiones aleatorias para la maleta
            factor_longitud = 0.8 + (1.2 - 0.8) * rand();  % Longitud paralelo al ancho del carro
            factor_ancho = 0.8 + (1.2 - 0.8) * rand();     % Ancho paralelo al largo del carro
            factor_altura = 0.8 + (1.2 - 0.8) * rand();    % Altura paralelo a la altura del carro
        else
            factor_longitud = 1;
            factor_ancho = 1;
            factor_altura = 1;
        end

        l = maleta_length_base * factor_longitud;  % Lado largo paralelo al ancho del carro
        w = maleta_width_base * factor_ancho;      % Lado corto paralelo al largo del carro
        h = maleta_height_base * factor_altura;    % Altura

        if (y_pos + w > length_caja)
            w = length_caja - y_pos;
        end

        % Posición de la maleta en la segunda columna
        x = x_center + l/2; % Alineamos la maleta desde el centro hacia el otro lado (positivo)
        y = y_pos + w/2;    % Colocar la maleta empezando desde el principio del carro
        z = h/2;            % La primera fila está en el suelo, así que la altura es la mitad de la maleta

        % Actualizar la posición en y para la próxima maleta
        y_pos = y_pos + w;

        % Almacenar la posición y dimensiones de la maleta
        maletas_pos(contador, :) = [x, y, z];
        maletas_dim(contador, :) = [l, w, h];

        % Dibujar la maleta en color cyan solo si graficas == true
        if graficas
            draw_box(x, y, z, l, w, h);
        end

        % Determinar la posición del TAG
        tags_pos(contador, :) = calcular_tag_pos(x, y, z, l, w, h, flag_tag_pos, x <= x_center);

        % Dibujar el TAG como un pequeño punto solo si graficas == true
        if graficas
            plot3(tags_pos(contador, 1), tags_pos(contador, 2), tags_pos(contador, 3), 'ro', 'MarkerSize', 5, 'MarkerFaceColor', 'r');
        end

        contador =  contador + 1;
    end

    % Generar la segunda y tercera fila de maletas
    for i = 2:rows
        y_pos = y_start; % Reiniciar y_pos para cada fila

        % Establecer el rango de índices para la fila inferior
        if i == 2
            start_idx = 1;
            end_idx = 12;
        elseif i == 3
            start_idx = 13;
            end_idx = 24;
        end

        for j = 1:6
            if strcmp(flag_bag_rand, 'random')
                % Generar dimensiones aleatorias para la maleta
                factor_longitud = 0.8 + (1.2 - 0.8) * rand();  % Longitud paralelo al ancho del carro
                factor_ancho = 0.8 + (1.2 - 0.8) * rand();     % Ancho paralelo al largo del carro
                factor_altura = 0.8 + (1.2 - 0.8) * rand();    % Altura paralelo a la altura del carro
            else
                factor_longitud = 1;
                factor_ancho = 1;
                factor_altura = 1;
            end

            l = maleta_length_base * factor_longitud;  % Lado largo paralelo al ancho del carro
            w = maleta_width_base * factor_ancho;      % Lado corto paralelo al largo del carro
            h = maleta_height_base * factor_altura;    % Altura

            if (y_pos + w > length_caja)
                w = length_caja - y_pos;
            end

            % Posición de la maleta
            x = x_center - l/2; % Alineamos la maleta desde el centro hacia un lado (negativo)
            y = y_pos + w/2;    % Colocar la maleta empezando desde el principio del carro

            % Calcular la altura z, considerando las maletas de la fila inferior
            z = calculate_z(maletas_pos, maletas_dim, l, w, x, y, start_idx, end_idx) + h/2;

            % Actualizar la posición en y para la próxima maleta
            y_pos = y_pos + w;

            % Almacenar la posición y dimensiones de la maleta
            maletas_pos(contador, :) = [x, y, z];
            maletas_dim(contador, :) = [l, w, h];

            % Dibujar la maleta en color cyan solo si graficas == true
            if graficas
                draw_box(x, y, z, l, w, h);
            end

            % Determinar la posición del TAG
            tags_pos(contador, :) = calcular_tag_pos(x, y, z, l, w, h, flag_tag_pos, x <= x_center);

            % Dibujar el TAG como un pequeño punto solo si graficas == true
            if graficas
                plot3(tags_pos(contador, 1), tags_pos(contador, 2), tags_pos(contador, 3), 'ro', 'MarkerSize', 5, 'MarkerFaceColor', 'r');
            end

            contador = contador + 1;
        end

        % Generar la segunda columna de la fila enfrentada
        y_pos = y_start; % Reiniciar y_pos para la segunda columna

        for j = 7:12
            if strcmp(flag_bag_rand, 'random')
                % Generar dimensiones aleatorias para la maleta
                factor_longitud = 0.8 + (1.2 - 0.8) * rand();  % Longitud paralelo al ancho del carro
                factor_ancho = 0.8 + (1.2 - 0.8) * rand();     % Ancho paralelo al largo del carro
                factor_altura = 0.8 + (1.2 - 0.8) * rand();    % Altura paralelo a la altura del carro
            else
                factor_longitud = 1;
                factor_ancho = 1;
                factor_altura = 1;
            end

            l = maleta_length_base * factor_longitud;  % Lado largo paralelo al ancho del carro
            w = maleta_width_base * factor_ancho;      % Lado corto paralelo al largo del carro
            h = maleta_height_base * factor_altura;    % Altura

            if (y_pos + w > length_caja)
                w = length_caja - y_pos;
            end

            % Posición de la maleta en la segunda columna
            x = x_center + l/2; % Alineamos la maleta desde el centro hacia el otro lado (positivo)
            y = y_pos + w/2;    % Colocar la maleta empezando desde el principio del carro

            % Calcular la altura z, considerando las maletas de la fila inferior
            z = calculate_z(maletas_pos, maletas_dim, l, w, x, y, start_idx, end_idx) + h/2;

            % Actualizar la posición en y para la próxima maleta
            y_pos = y_pos + w;

            % Almacenar la posición y dimensiones de la maleta
            maletas_pos(contador, :) = [x, y, z];
            maletas_dim(contador, :) = [l, w, h];

            % Dibujar la maleta en color cyan solo si graficas == true
            if graficas
                draw_box(x, y, z, l, w, h);
            end

            % Determinar la posición del TAG
            tags_pos(contador, :) = calcular_tag_pos(x, y, z, l, w, h, flag_tag_pos, x <= x_center);

            % Dibujar el TAG como un pequeño punto solo si graficas == true
            if graficas
                plot3(tags_pos(contador, 1), tags_pos(contador, 2), tags_pos(contador, 3), 'ro', 'MarkerSize', 5, 'MarkerFaceColor', 'r');
            end

            contador = contador + 1;
        end
    end
    
    if graficas
        % Visualización del lector solo si graficas == true
        plot3(0, 0, 0, 'rx', 'MarkerSize', 10, 'LineWidth', 2);
    
        % Definir los colores para las antenas si compare_reader == true
        colores = [
            0, 0.45, 0.79;  % Azul
            0.85, 0.33, 0.10; % Naranja
            0.93, 0.69, 0.13; % Amarillo
            0.49, 0.18, 0.56  % Morado
        ];
    
        for i = 1:size(reader_pos, 1)  % Iteramos por cada fila (cada antena)
            if compare_reader
                color_actual = colores(mod(i - 1, size(colores, 1)) + 1, :);  % Seleccionar un color cíclicamente
            else
                color_actual = [0, 1, 0];  % Verde si compare_reader es false
            end
    
            % Dibujar el punto del lector solo si graficas == true
            plot3(reader_pos(i, 1), reader_pos(i, 2), reader_pos(i, 3), 'o', 'MarkerSize', 10, 'MarkerFaceColor', color_actual, 'MarkerEdgeColor', color_actual);
    
            % Dibujar el vector de dirección desde la posición del lector solo si graficas == true
            quiver3(reader_pos(i, 1), reader_pos(i, 2), reader_pos(i, 3), ...
                    vectors_dir(i, 1), vectors_dir(i, 2), vectors_dir(i, 3), ...
                    0.5, 'Color', color_actual, 'LineWidth', 2, 'MaxHeadSize', 1);  % Escalado por 5 para hacer el vector más visible
    
            hold on;  % Mantener la gráfica para poder agregar más puntos
        end
    
        xlabel('Amplada del carro (m)');
        ylabel('Llargada del carro (m)');
        zlabel('Alçada (m)');
        title('Distribució 3D dels equipatges, etiquetes i lector(s)');
        grid on;
        axis equal;
    
        % Dibujar las líneas del contorno del carro solo si graficas == true
        draw_cart_outline(width_caja, length_caja, height_caja); % Dibuja el contorno con el ancho y largo intercambiados
    end

end

function draw_box(x, y, z, l, w, h)
    % Dibuja una caja 3D en las coordenadas (x, y, z) con dimensiones l, w, h en color cyan
    vertices = [
        x-l/2, y-w/2, z-h/2;
        x+l/2, y-w/2, z-h/2;
        x+l/2, y+w/2, z-h/2;
        x-l/2, y+w/2, z-h/2;
        x-l/2, y-w/2, z+h/2;
        x+l/2, y-w/2, z+h/2;
        x+l/2, y+w/2, z+h/2;
        x-l/2, y+w/2, z+h/2];
    
    faces = [
        1 2 3 4;
        5 6 7 8;
        1 2 6 5;
        2 3 7 6;
        3 4 8 7;
        4 1 5 8];
    
    patch('Vertices', vertices, 'Faces', faces, 'FaceColor', 'cyan', 'FaceAlpha', 0.5);
end

function z_max = calculate_z(maletas_pos, maletas_dim, l, w, x, y, start_idx, end_idx)
    % Calcula la altura máxima z considerando solo las maletas directamente debajo
    z_max = 0;
    for k = start_idx:end_idx
        % Verifica si la maleta debajo está en la misma área
        if abs(maletas_pos(k, 1) - x) < (maletas_dim(k, 1)/2 + l/2) && ...
           abs(maletas_pos(k, 2) - y) < (maletas_dim(k, 2)/2 + w/2)
            z_max = max(z_max, maletas_pos(k, 3) + maletas_dim(k, 3)/2);
        end
    end
end

function draw_cart_outline(width_caja, length_caja, height_caja)
    % Dibuja las líneas del contorno del carro/caja en 3D
    vertices = [
        0, 0, 0;
        0, length_caja, 0;
        width_caja, length_caja, 0;
        width_caja, 0, 0;
        0, 0, height_caja;
        0, length_caja, height_caja;
        width_caja, length_caja, height_caja;
        width_caja, 0, height_caja];
    
    edges = [
        1 2; 2 3; 3 4; 4 1;  % Base inferior
        5 6; 6 7; 7 8; 8 5;  % Base superior
        1 5; 2 6; 3 7; 4 8]; % Laterales
    
    for i = 1:size(edges, 1)
        plot3([vertices(edges(i, 1), 1), vertices(edges(i, 2), 1)], ...
              [vertices(edges(i, 1), 2), vertices(edges(i, 2), 2)], ...
              [vertices(edges(i, 1), 3), vertices(edges(i, 2), 3)], 'k-', 'LineWidth', 2);
    end
end

function tag_pos = calcular_tag_pos(x, y, z, l, w, h, flag_tag_pos, is_left_column)
    % Calcula la posición del TAG según el flag de configuración y la posición de la maleta
    if strcmp(flag_tag_pos, 'inside') % Todos los TAGs en las caras internas
        if is_left_column
            tag_x = x + l/2; % Cara derecha para la columna izquierda
        else
            tag_x = x - l/2; % Cara izquierda para la columna derecha
        end
    elseif strcmp(flag_tag_pos, 'outside') % Todos los TAGs en las caras externas
        if is_left_column
            tag_x = x - l/2; % Cara izquierda para la columna izquierda
        else
            tag_x = x + l/2; % Cara derecha para la columna derecha
        end
    else % TAGs en posiciones aleatorias (inside/outside)
        if rand() > 0.5
            tag_x = x + l/2;
        else
            tag_x = x - l/2;
        end
    end

    % La posición del TAG está centrada en la altura y el ancho
    tag_y = y;
    tag_z = z;

    tag_pos = [tag_x, tag_y, tag_z];
end
