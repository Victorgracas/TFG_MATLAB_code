function plot_all_tags_with_read_status(link_budget_results, maletas_pos, maletas_dim, tags_pos, reader_pos, antenasAUsar)
    % Parámetros de la caja (en metros)
    length_caja = 110 * 0.0254; % 110 pulgadas a metros
    width_caja = 50 * 0.0254;   % 50 pulgadas a metros
    height_caja = 54 * 0.0254;  % 54 pulgadas a metros

    % Asegurarse de que antenasAUsar sea una celda de strings
    if ischar(antenasAUsar)
        antenasAUsar = {antenasAUsar}; % Convertir a celda si es un string
    end
    % Número de antenas a usar
    num_antenas = length(antenasAUsar);

    % Iterar sobre todas las antenas simuladas
    for antenaIdx = 1:num_antenas
        tipoAntena = antenasAUsar{antenaIdx};
        figure; % Crear una nueva figura para cada antena
        hold on;
        view(-40,19);
        
        num_tags = size(tags_pos, 1); % Número de tags

        % Dibujar las maletas
        for i = 1:size(maletas_pos, 1)
            % Obtener la posición y las dimensiones de cada maleta
            x = maletas_pos(i, 1);
            y = maletas_pos(i, 2);
            z = maletas_pos(i, 3);
            l = maletas_dim(i, 1);
            w = maletas_dim(i, 2);
            h = maletas_dim(i, 3);

            % Determinar el color de la maleta según los resultados del link budget
            if link_budget_results(i, 3) == 1 % Se leyó correctamente (valor en la tercera dimensión de los resultados)
                box_color = 'g'; % Verde para leído
            else
                box_color = 'r'; % Rojo para no leído
            end

            % Dibujar la maleta con el color correspondiente
            draw_box(x, y, z, l, w, h, box_color);

            % Dibujar el TAG como un punto negro
            plot3(tags_pos(i, 1), tags_pos(i, 2), tags_pos(i, 3), 'ko', 'MarkerSize', 5, 'MarkerFaceColor', 'k');
        end

        % Visualización de las antenas (lectores)
        for j = 1:size(reader_pos, 1)  % Iteramos por cada lector (antena)
            % Dibujar el punto del lector
            plot3(reader_pos(j, 1), reader_pos(j, 2), reader_pos(j, 3), 'go', 'MarkerSize', 10, 'MarkerFaceColor', 'b');
        end

        % Etiquetas y formato del gráfico
        xlabel('Amplada del carro (m)');
        ylabel('Llargada del carro (m)');
        zlabel('Alçada (m)');
        %title(['Distribució 3D de la lectura de TAGs - Antena: ', tipoAntena]);
        title('Distribució 3D de la lectura de TAGs');
        grid on;
        axis equal;

        % Dibujar las líneas del contorno del carro
        draw_cart_outline(width_caja, length_caja, height_caja);
        
        % Crear elementos ficticios para la leyenda que representen el estado de lectura
        h1 = plot(nan, nan, 's', 'MarkerEdgeColor', 'g', 'MarkerFaceColor', 'g', 'DisplayName', 'Etiqueta llegida correctament'); % Elemento verde para etiquetas leídas correctamente
        h2 = plot(nan, nan, 's', 'MarkerEdgeColor', 'r', 'MarkerFaceColor', 'r', 'DisplayName', 'Etiqueta fora de rang'); % Elemento rojo para etiquetas fuera de rango
        
        % Añadir una única leyenda con los colores especificados
        legend([h1, h2], 'Location', 'best');




        hold off;
    end
end

function draw_box(x, y, z, l, w, h, box_color)
    % Dibuja una caja 3D en las coordenadas (x, y, z) con dimensiones l, w, h en color variable
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

    patch('Vertices', vertices, 'Faces', faces, 'FaceColor', box_color, 'FaceAlpha', 0.5);
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
