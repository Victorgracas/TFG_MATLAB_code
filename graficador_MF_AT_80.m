% %%%% ESCENARI 3 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % 
% % Definir los parámetros de la simulación
% num_iteraciones = 50; % Incrementar el número de iteraciones para obtener una media más precisa
% 
% length_caja = 110 * 0.0254; % 110 pulgadas a metros
% width_caja = 50 * 0.0254;   % 50 pulgadas a metros
% height_caja = 54 * 0.0254;  % 54 pulgadas a metros
% 
% coste_FXR90 = 6729 + 1000 + 2000 + 1.8; % Coste de un escenario utilizando la antena FXR90
% coste_AN520 = 6729 + 250 + 2000 + 1.8; % Coste de un escenario utilizando la antena AN520
% costos_antenas = [coste_FXR90, coste_AN520];
% 
% coste_2FXR90 = 6729 + 1000 + 1000 + 2000 + 1.8;
% coste_2AN520 = 6729 + 250 + 250 + 2000 + 1.8;
% costos_2antenas = [coste_2FXR90, coste_2AN520];
% 
% % Definir las posiciones de las antenas (tres posiciones posibles)
% num_antennas = 2;
% posiciones_lectores = [
%      0, length_caja/2, height_caja;
%      width_caja, length_caja/2, height_caja;
% ];
% 
% [maletas_pos, maletas_dim, tags_pos, reader_pos, vectors_dir] = escenario(posiciones_lectores, num_antennas, true);
% 
% % Definir los parámetros de variación
% atenuacion_min = 0;  % Valor mínimo de la atenuación de maletas
% atenuacion_max = 12; % Valor máximo de la atenuación de maletas
% atenuacion_step = 0.4; % Paso de variación de la atenuación de maletas
% 
% perdidas_min = 0;    % Valor mínimo de las pérdidas inespecíficas
% perdidas_max = 22;   % Valor máximo de las pérdidas inespecíficas
% perdidas_step = 0.4; % Paso de variación de las pérdidas inespecíficas
% 
% atenuaciones = atenuacion_min:atenuacion_step:atenuacion_max;
% perdidas = perdidas_min:perdidas_step:perdidas_max;
% 
% tipoAntenaLector = 'Compare Mode'; % 'FXR90', 'AN520' o 'Compare Mode'
% if strcmp(tipoAntenaLector, 'Compare Mode')
%     antenasAUsar = {'FXR90', 'AN520'};
% else
%     antenasAUsar = {tipoAntenaLector}; % Sólo una antena
% end
% 
% % Inicializar matrices para guardar los valores de atenuación y pérdidas específicas para el 80%
% resultados_80_1_antena = [];
% resultados_80_2_antenas = [];
% 
% % Recorrer los valores de atenuación de las maletas
% for i = 1:length(atenuaciones)
%     Atenuacio_maleta = atenuaciones(i); % Definir la atenuación actual
% 
%     % Inicializar vector para almacenar percentil 95 de las probabilidades de lectura
%     probabilidad_lectura_p95_1_antena = zeros(length(perdidas), length(antenasAUsar));
%     probabilidad_lectura_p95_2_antenas = zeros(length(perdidas), length(antenasAUsar));
% 
%     % Recorrer los valores de pérdidas inespecíficas
%     for j = 1:length(perdidas)
%         Perdues_k = perdidas(j); % Definir las pérdidas actuales
% 
%         % Matriz temporal para almacenar probabilidades de lectura de cada iteración
%         probabilidad_lectura_iteraciones_1_antena = zeros(num_iteraciones, length(antenasAUsar));
%         probabilidad_lectura_iteraciones_2_antenas = zeros(num_iteraciones, length(antenasAUsar));
% 
%         % Ejecutar múltiples iteraciones para cada tipo de antena
%         for iter = 1:num_iteraciones
%             % Obtener un nuevo escenario para cada iteración con una antena
%             [maletas_pos, maletas_dim, tags_pos, reader_pos, vectors_dir] = escenario(posiciones_lectores, num_antennas, false);
%             reader_pos_1 = reader_pos(1, :); % Utilizar solo la primera antena
%             vectors_dir_1 = vectors_dir(1, :);
% 
%             % Iteración para una antena
%             for antenaIdx = 1:length(antenasAUsar)
%                 tipoAntena = antenasAUsar{antenaIdx};  % Obtener el tipo de antena actual
%                 [link_budget_results_1] = linkbudget(reader_pos_1, vectors_dir_1, maletas_pos, maletas_dim, tags_pos, Atenuacio_maleta, Perdues_k, tipoAntena);
% 
%                 % Calcular la probabilidad de lectura (número de tags leídos / total de tags)
%                 num_tags = size(link_budget_results_1, 1);
%                 tags_leidos_1 = sum(link_budget_results_1(:, 3), 'all'); % Sumar los tags leídos en la antena actual
%                 probabilidad_lectura_iteraciones_1_antena(iter, antenaIdx) = tags_leidos_1 / num_tags; % Proporción de tags leídos
%             end
% 
%             % Iteración para ambas antenas
%             for antenaIdx = 1:length(antenasAUsar)
%                 tipoAntena = antenasAUsar{antenaIdx};
%                 [link_budget_results_2] = linkbudget(reader_pos, vectors_dir, maletas_pos, maletas_dim, tags_pos, Atenuacio_maleta, Perdues_k, tipoAntena);
% 
%                 num_tags = size(link_budget_results_2, 1);
%                 tags_leidos_2 = sum(link_budget_results_2(:, 3), 'all');
%                 probabilidad_lectura_iteraciones_2_antenas(iter, antenaIdx) = tags_leidos_2 / num_tags;
%             end
%         end
% 
%         % Calcular el percentil 95 de las probabilidades de lectura
%         probabilidad_lectura_p95_1_antena(j, :) = prctile(probabilidad_lectura_iteraciones_1_antena, 95, 1);
%         probabilidad_lectura_p95_2_antenas(j, :) = prctile(probabilidad_lectura_iteraciones_2_antenas, 95, 1);
%     end
% 
%     % Seleccionar la pérdida más cercana a 80% para cada antena y configuración (1 o 2 antenas)
%     for antenaIdx = 1:length(antenasAUsar)
%         % Una antena
%         indices_validos_1 = find(probabilidad_lectura_p95_1_antena(:, antenaIdx) >= 0.80);
%         if ~isempty(indices_validos_1)
%             [~, idx_relativo] = min(probabilidad_lectura_p95_1_antena(indices_validos_1, antenaIdx) - 0.80);
%             idx_p80 = indices_validos_1(idx_relativo);
%             Perdues_optima = perdidas(idx_p80);
%             probabilidad_optima = probabilidad_lectura_p95_1_antena(idx_p80, antenaIdx);
%             resultados_80_1_antena = [resultados_80_1_antena; Atenuacio_maleta, Perdues_optima, probabilidad_optima, antenaIdx];
%         end
% 
%         % Dos antenas
%         indices_validos_2 = find(probabilidad_lectura_p95_2_antenas(:, antenaIdx) >= 0.80);
%         if ~isempty(indices_validos_2)
%             [~, idx_relativo] = min(probabilidad_lectura_p95_2_antenas(indices_validos_2, antenaIdx) - 0.80);
%             idx_p80 = indices_validos_2(idx_relativo);
%             Perdues_optima = perdidas(idx_p80);
%             probabilidad_optima = probabilidad_lectura_p95_2_antenas(idx_p80, antenaIdx);
%             resultados_80_2_antenas = [resultados_80_2_antenas; Atenuacio_maleta, Perdues_optima, probabilidad_optima, antenaIdx];
%         end
%     end
% end
% 
% % Convertir las matrices de resultados en tablas para generar los gráficos
% resultados_tabla_80_1_antena = array2table(resultados_80_1_antena, 'VariableNames', {'Atenuacio', 'Perdues', 'Probabilitat', 'Antena'});
% resultados_tabla_80_2_antenas = array2table(resultados_80_2_antenas, 'VariableNames', {'Atenuacio', 'Perdues', 'Probabilitat', 'Antena'});
% 
% % Generar los gráficos de Pérdidas vs Atenuación para probabilidades cercanas a 80%
% for antenaIdx = 1:length(antenasAUsar)
%     % Filtrar los datos para la antena actual
%     datos_antena_1 = resultados_tabla_80_1_antena(resultados_tabla_80_1_antena.Antena == antenaIdx, :);
%     datos_antena_2 = resultados_tabla_80_2_antenas(resultados_tabla_80_2_antenas.Antena == antenaIdx, :);
% 
%     % Crear el gráfico
%     figure;
%     hold on;
%     plot(datos_antena_1.Atenuacio, datos_antena_1.Perdues, '-', 'DisplayName', ['1 Antena ', antenasAUsar{antenaIdx}], 'LineWidth', 2);
%     plot(datos_antena_2.Atenuacio, datos_antena_2.Perdues, '-', 'DisplayName', ['2 Antenas ', antenasAUsar{antenaIdx}], 'LineWidth', 2);
% 
%     % Configuración del gráfico
%     xlabel('Atenuació de l''equipatge (dB/m)');
%     ylabel('Pèrdudes Inespecífiques (dB)');
%     title(['Pèrdudes vs Atenuació per una Probabilitat ≥ 80% - Antena: ', antenasAUsar{antenaIdx}]);
%     legend show; % Mostrar la leyenda
%     grid on;
%     hold off;
% end


%%%% ESCENARI 4 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Definir los parámetros de la simulación
num_iteraciones = 50; % Incrementar el número de iteraciones para obtener una media más precisa

length_caja = 110 * 0.0254; % 110 pulgadas a metros
width_caja = 50 * 0.0254;   % 50 pulgadas a metros
height_caja = 54 * 0.0254;  % 54 pulgadas a metros

coste_FXR90 = 6729 + 1000 + 2000 + 1.8; % Coste de un escenario utilizando la antena FXR90
coste_AN520 = 6729 + 250 + 2000 + 1.8; % Coste de un escenario utilizando la antena AN520
costos_antenas = [coste_FXR90, coste_AN520];

% Definir las posiciones de las antenas (cuatro posiciones posibles)
num_antennas = 4;
posiciones_lectores = [
     0, length_caja/2, height_caja; % Primera antena
     width_caja/2, length_caja/2, height_caja;
     width_caja/2, length_caja, height_caja;
     0, 0, height_caja;
];

[antennas_pos, vectors_dir] = calculate_antenna_vectors(num_antennas, posiciones_lectores);
[maletas_pos, maletas_dim, tags_pos] = TAG_matrix('random', 'random', antennas_pos, vectors_dir, true, true);

% Definir los parámetros de variación
atenuacion_min = 0;  % Valor mínimo de la atenuación de maletas
atenuacion_max = 12; % Valor máximo de la atenuación de maletas
atenuacion_step = 0.4; % Paso de variación de la atenuación de maletas

perdidas_min = 0;    % Valor mínimo de las pérdidas inespecíficas
perdidas_max = 30;   % Valor máximo de las pérdidas inespecíficas
perdidas_step = 0.6; % Paso de variación de las pérdidas inespecíficas

atenuaciones = atenuacion_min:atenuacion_step:atenuacion_max;
perdidas = perdidas_min:perdidas_step:perdidas_max;

tipoAntenaLector = 'Compare Mode'; % 'FXR90', 'AN520' o 'Compare Mode'
if strcmp(tipoAntenaLector, 'Compare Mode')
    antenasAUsar = {'FXR90', 'AN520'};
else
    antenasAUsar = {tipoAntenaLector}; % Sólo una antena
end

% Inicializar matrices para guardar los valores de atenuación y pérdidas específicas para el 80%
resultados_80_posiciones = [];

% Recorrer los valores de atenuación de las maletas
for i = 1:length(atenuaciones)
    Atenuacio_maleta = atenuaciones(i); % Definir la atenuación actual

    % Inicializar vector para almacenar percentil 95 de las probabilidades de lectura
    probabilidad_lectura_p95_posiciones = zeros(length(perdidas), length(antenasAUsar), size(posiciones_lectores, 1));

    % Recorrer las posiciones de los lectores
    for posIdx = 1:size(posiciones_lectores, 1)
        reader_pos = posiciones_lectores(posIdx, :); % Obtener la posición actual de la antena

        % Recorrer los valores de pérdidas inespecíficas
        for j = 1:length(perdidas)
            Perdues_k = perdidas(j); % Definir las pérdidas actuales

            % Matriz temporal para almacenar probabilidades de lectura de cada iteración
            probabilidad_lectura_iteraciones = zeros(num_iteraciones, length(antenasAUsar));

            % Ejecutar múltiples iteraciones para cada tipo de antena
            for iter = 1:num_iteraciones
                % Obtener un nuevo escenario para cada iteración
                [maletas_pos, maletas_dim, tags_pos, antennas_pos, vectors_dir] = escenario(reader_pos, 1,false);

                for antenaIdx = 1:length(antenasAUsar)
                    tipoAntena = antenasAUsar{antenaIdx};  % Obtener el tipo de antena actual
                    [link_budget_results] = linkbudget(reader_pos, vectors_dir, maletas_pos, maletas_dim, tags_pos, Atenuacio_maleta, Perdues_k, tipoAntena);

                    % Calcular la probabilidad de lectura (número de tags leídos / total de tags)
                    num_tags = size(link_budget_results, 1);
                    tags_leidos = sum(link_budget_results(:, 3), 'all'); % Sumar los tags leídos en la antena actual
                    probabilidad_lectura_iteraciones(iter, antenaIdx) = tags_leidos / num_tags; % Proporción de tags leídos
                end
            end

            % Calcular el percentil 95 de las probabilidades de lectura para cada antena y posición
            probabilidad_lectura_p95_posiciones(j, :, posIdx) = prctile(probabilidad_lectura_iteraciones, 95, 1);
        end
    end

    % Seleccionar la pérdida más cercana a 80% para cada antena y posición
    for antenaIdx = 1:length(antenasAUsar)
        for posIdx = 1:size(posiciones_lectores, 1)
            % Filtrar los índices donde la probabilidad de lectura es mayor o igual al 80%
            indices_validos = find(probabilidad_lectura_p95_posiciones(:, antenaIdx, posIdx) >= 0.80);

            if ~isempty(indices_validos)
                % Seleccionar el índice con la menor diferencia respecto al 80%
                [~, idx_relativo] = min(probabilidad_lectura_p95_posiciones(indices_validos, antenaIdx, posIdx) - 0.80);
                idx_p80 = indices_validos(idx_relativo);

                % Guardar el valor óptimo de pérdida y la probabilidad correspondiente
                Perdues_optima = perdidas(idx_p80);
                probabilidad_optima = probabilidad_lectura_p95_posiciones(idx_p80, antenaIdx, posIdx);
                resultados_80_posiciones = [resultados_80_posiciones; Atenuacio_maleta, Perdues_optima, probabilidad_optima, antenaIdx, posIdx];
            end
        end
    end
end

% Convertir la matriz de resultados en una tabla para generar el gráfico
resultados_tabla_80_posiciones = array2table(resultados_80_posiciones, 'VariableNames', {'Atenuacio', 'Perdues', 'Probabilitat', 'Antena', 'Posicion'});

% Generar los gráficos de Pérdidas vs Atenuación para probabilidades cercanas a 80%
for antenaIdx = 1:length(antenasAUsar)
    % Crear el gráfico para cada antena
    figure;
    hold on;
    for posIdx = 1:size(posiciones_lectores, 1)
        % Filtrar los datos para la antena y posición actual
        datos_antena_pos = resultados_tabla_80_posiciones(resultados_tabla_80_posiciones.Antena == antenaIdx & resultados_tabla_80_posiciones.Posicion == posIdx, :);
        plot(datos_antena_pos.Atenuacio, datos_antena_pos.Perdues, '-', 'DisplayName', ['Posición ', num2str(posIdx)], 'LineWidth', 2);
    end

    % Configuración del gráfico
    xlabel('Atenuació de l''equipatge (dB/m)');
    ylabel('Pèrdudes Inespecífiques (dB)');
    title(['Pèrdudes vs Atenuació per una Probabilitat ≥ 80% - Antena: ', antenasAUsar{antenaIdx}]);
    legend show; % Mostrar la leyenda
    grid on;
    hold off;
end
