function [antennas_pos, vectors_dir] = calculate_antenna_vectors(num_antennas, reader_positions)
    % Calcula la posición y el vector de dirección para cada antena

    % Inicialización de las salidas
    antennas_pos = zeros(num_antennas, 3);  % Posiciones de las antenas
    vectors_dir = zeros(num_antennas, 3);   % Vectores de dirección de las antenas

    % Parámetros de la caja (en metros)
    length_caja = 110 * 0.0254; % 110 pulgadas a metros
    width_caja = 50 * 0.0254;   % 50 pulgadas a metros
    height_caja = 54 * 0.0254;  % 54 pulgadas a metros (la altura siempre será la misma)

    % Recorrer cada antena y calcular su vector de dirección
    for i = 1:num_antennas
        % Obtener la posición del lector actual
        reader_pos = reader_positions(i, :);
        antennas_pos(i, :) = reader_pos; % Guardar la posición de la antena

        % Cálculo del vector de dirección para cada antena basado en la posición
        if reader_pos(1) == 0 && reader_pos(2) == length_caja / 2
            % Si el lector está en el centro de un lado longitudinal
            vectors_dir(i, :) = [1, 0, 0]; % Apunta hacia el lado opuesto en el eje Y negativo
        elseif reader_pos(1) == width_caja / 2 && reader_pos(2) == 0
            % Si el lector está en el centro de un lado del ancho
            vectors_dir(i, :) = [0, 1, 0]; % Apunta hacia el eje Y positivo
        elseif reader_pos(1) == width_caja && reader_pos(2) == length_caja / 2
            % Si el lector está en el otro extremo (ancho máximo)
            vectors_dir(i, :) = [-1, 0, 0]; % Apunta en el eje X negativo
        elseif reader_pos(1) == width_caja / 2 && reader_pos(2) == length_caja
            % Si el lector está en el centro del otro lado longitudinal
            vectors_dir(i, :) = [0, -1, 0]; % Apunta en el eje Y hacia el lado opuesto
        elseif reader_pos(1) == width_caja / 2 && reader_pos(2) == length_caja / 2
            vectors_dir(i, :) = [0, 0, -1];
        elseif reader_pos(1) == 0 && reader_pos(2) == 0
            vectors_dir(i, :) = [width_caja/length_caja, length_caja/length_caja, 0];

        else
            % Si la posición no coincide con ningún caso estándar, dejar vector nulo
            vectors_dir(i, :) = [0, 0, 0];
        end
    end
end
