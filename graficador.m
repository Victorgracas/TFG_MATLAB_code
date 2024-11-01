% Atenuacio_maleta = 3;
% Perdues_k = 2;
% graficas = true;
% 
% [link_budget_results, maletas_pos, maletas_dim, tags_pos, antennas_pos, antenasAUsar] = main(Atenuacio_maleta,Perdues_k,graficas);
% 
% 
% plot_tags_with_read_status(link_budget_results, maletas_pos, maletas_dim, tags_pos, antennas_pos, antenasAUsar);

%----------------------------------------------------------------------------------------------------------------------------

% graficas = true;
% 
% % Definir los parámetros de variación
% atenuacion_min = 1;  % Valor mínimo de la atenuación de maletas
% atenuacion_max = 15; % Valor máximo de la atenuación de maletas
% atenuacion_step = 2; % Paso de variación de la atenuación de maletas
% 
% perdidas_min = 0;    % Valor mínimo de las pérdidas inespecíficas
% perdidas_max = 10;  % Valor máximo de las pérdidas inespecíficas
% perdidas_step = 0.5; % Paso de variación de las pérdidas inespecíficas
% 
% tipoAntenaLector = 'Compare Mode'; % 'FXR90', 'AN520' o 'Compare Mode'
% 
% if strcmp(tipoAntenaLector, 'Compare Mode')
%     antenasAUsar = {'FXR90', 'AN520'};
% else
%     antenasAUsar = {tipoAntenaLector}; % Sólo una antena
% end
% 
% % Inicializar matriz para almacenar las probabilidades de lectura
% atenuaciones = atenuacion_min:atenuacion_step:atenuacion_max;
% perdidas = perdidas_min:perdidas_step:perdidas_max;
% 
% % Obtener el escenario común para todas las simulaciones
% [maletas_pos, maletas_dim, tags_pos, reader_pos, vectors_dir] = escenario(graficas);
% 
% % Recorrer los valores de atenuación de las maletas
% for i = 1:length(atenuaciones)
%     Atenuacio_maleta = atenuaciones(i); % Definir la atenuación actual
% 
%     % Crear la figura para la atenuación actual
%     figure;
%     hold on; % Mantener el gráfico para agregar múltiples líneas
% 
%     % Inicializar la matriz para probabilidades de lectura
%     probabilidad_lectura = zeros(length(perdidas), length(antenasAUsar));
% 
%     % Recorrer los valores de pérdidas inespecíficas
%     for j = 1:length(perdidas)
%         Perdues_k = perdidas(j); % Definir las pérdidas actuales
% 
%         % Ejecutar la simulación para cada tipo de antena
%         for antenaIdx = 1:length(antenasAUsar)
%             tipoAntena = antenasAUsar{antenaIdx};  % Obtener el tipo de antena actual
%             [link_budget_results] = linkbudget(reader_pos, vectors_dir, maletas_pos, maletas_dim, tags_pos, Atenuacio_maleta, Perdues_k, tipoAntena);
% 
%             % Calcular la probabilidad de lectura (número de tags leídos / total de tags)
%             num_tags = size(link_budget_results, 1);
%             tags_leidos = sum(link_budget_results(:, 3), 'all'); % Sumar los tags leídos en la antena actual
%             probabilidad_lectura(j, antenaIdx) = tags_leidos / num_tags; % Proporción de tags leídos
% 
%             % Graficar los tags con estado de lectura si se requiere
%             %plot_tags_with_read_status(link_budget_results, maletas_pos, maletas_dim, tags_pos, reader_pos, tipoAntena);
%         end
%     end
% 
%     % Graficar la línea para cada tipo de antena
%     for antenaIdx = 1:length(antenasAUsar)
%         tipoAntena = antenasAUsar{antenaIdx};
%         plot(perdidas, probabilidad_lectura(:, antenaIdx), '-o', 'DisplayName', ['Antena: ', tipoAntena], 'LineWidth', 2);
%     end
% 
%     % Configuración del gráfico en catalán
%     xlabel('Pèrdues Inespecífiques (dB)');
%     ylabel('Probabilitat de Lectura');
%     title(['Probabilitat de Lectura per Atenuació de l''equipatge = ', num2str(Atenuacio_maleta), ' dB/m']);
%     legend show; % Mostrar la llegenda per diferenciar les línies
%     grid on;
%     hold off; % Alliberar el gràfic per a la següent iteració
% 
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Comparación simple entre ambas antenas. Puedes hardcodear la posicion
% graficas = false;
% 
% coste_FXR90 = 6729+1000+1000+2000+1.8; % Coste de un escenario utilizando la antena FXR90
% coste_AN520 = 6729+250+250+2000+1.8; % Coste de un escenario utilizando la antena AN52
% 
% costos_antenas = [coste_FXR90, coste_AN520];
% 
% % Definir los parámetros de variación
% atenuacion_min = 5;  % Valor mínimo de la atenuación de maletas
% atenuacion_max = 5; % Valor máximo de la atenuación de maletas
% atenuacion_step = 2; % Paso de variación de la atenuación de maletas
% 
% perdidas_min = 2;    % Valor mínimo de las pérdidas inespecíficas
% perdidas_max = 2;  % Valor máximo de las pérdidas inespecíficas
% perdidas_step = 0.5; % Paso de variación de las pérdidas inespecíficas
% 
% num_iteraciones = 2; % Número de iteraciones para cada configuración
% 
% tipoAntenaLector = 'Compare Mode'; % 'FXR90', 'AN520' o 'Compare Mode'
% 
% if strcmp(tipoAntenaLector, 'Compare Mode')
%     antenasAUsar = {'FXR90', 'AN520'};
% else
%     antenasAUsar = {tipoAntenaLector}; % Sólo una antena
% end
% 
% % Inicializar matriz para almacenar las probabilidades de lectura
% atenuaciones = atenuacion_min:atenuacion_step:atenuacion_max;
% perdidas = perdidas_min:perdidas_step:perdidas_max;
% 
% % Recorrer los valores de atenuación de las maletas utilizando parfor para paralelizar
% for i = 1:length(atenuaciones)
%     Atenuacio_maleta = atenuaciones(i); % Definir la atenuación actual
% 
%     % Inicializar matriz para almacenar resultados del percentil 95 de las iteraciones
%     probabilidad_lectura_p95 = zeros(length(perdidas), length(antenasAUsar));
% 
%     % Recorrer los valores de pérdidas inespecíficas
%     for j = 1:length(perdidas)
%         Perdues_k = perdidas(j); % Definir las pérdidas actuales
% 
% 
%         % Matriz temporal para almacenar probabilidades de lectura de cada iteración
%         probabilidad_lectura_iteraciones = zeros(num_iteraciones, length(antenasAUsar));
% 
%         % Ejecutar múltiples iteraciones para cada tipo de antena (sin parfor anidado)
%         for iter = 1:num_iteraciones
%             % Obtener un nuevo escenario para cada iteración
%             [maletas_pos, maletas_dim, tags_pos, reader_pos, vectors_dir] = escenario(graficas);
% 
%             for antenaIdx = 1:length(antenasAUsar)
%                 tipoAntena = antenasAUsar{antenaIdx};  % Obtener el tipo de antena actual
%                 [link_budget_results] = linkbudget(reader_pos, vectors_dir, maletas_pos, maletas_dim, tags_pos, Atenuacio_maleta, Perdues_k, tipoAntena);
%                 plot_tags_with_read_status(link_budget_results, maletas_pos, maletas_dim, tags_pos, reader_pos, tipoAntena);
% 
%                 % Calcular la probabilidad de lectura (número de tags leídos / total de tags)
%                 num_tags = size(link_budget_results, 1);
%                 tags_leidos = sum(link_budget_results(:, 3), 'all'); % Sumar los tags leídos en la antena actual
%                 probabilidad_lectura_iteraciones(iter, antenaIdx) = tags_leidos / num_tags; % Proporción de tags leídos
%             end
%         end
% 
%         % Calcular el percentil 95 de las probabilidades de lectura
%         probabilidad_lectura_p95(j, :) = prctile(probabilidad_lectura_iteraciones, 95, 1);
%     end
% 
%     % Crear la figura para la atenuación actual
%     figure;
%     hold on; % Mantener el gráfico para agregar múltiples líneas
% 
%     % Graficar la línea para cada tipo de antena con percentil 95
%     for antenaIdx = 1:length(antenasAUsar)
%         tipoAntena = antenasAUsar{antenaIdx};
%         plot(perdidas, probabilidad_lectura_p95(:, antenaIdx), '-o', 'DisplayName', ['Antena: ', tipoAntena, ' (Percentil 95)'], 'LineWidth', 2);
%     end
% 
%     % Configuración del gráfico en catalán
%     xlabel('Pèrdues Inespecífiques (dB)');
%     ylabel('Probabilitat de Lectura');
%     title(['Probabilitat de Lectura per Atenuació de l''equipatge = ', num2str(Atenuacio_maleta), ' dB/m']);
%     ylim([0, 1]); % Ajustar los límites del eje Y de 0 a 1
%     legend show; % Mostrar la llegenda per diferenciar les línies
%     grid on;
%     hold off; % Alliberar el gràfic per a la següent iteració
% 
% 
%     relacion_costo_beneficio_p95 = probabilidad_lectura_p95 ./ costos_antenas;
% 
%     % Crear la figura para la relación costo-beneficio con la atenuación actual
%     figure;
%     hold on; % Mantener el gráfico para agregar múltiples líneas
% 
%     % Graficar la línea para cada tipo de antena con percentil 95 (relación costo-beneficio)
%     for antenaIdx = 1:length(antenasAUsar)
%         tipoAntena = antenasAUsar{antenaIdx};
%         plot(perdidas, relacion_costo_beneficio_p95(:, antenaIdx), '-o', 'DisplayName', ['Antena: ', tipoAntena, ' (Relació Cost-Benefici)'], 'LineWidth', 2);
%     end
% 
%     % Configuración del gráfico en catalán para la relación costo-beneficio
%     xlabel('Pèrdues Inespecífiques (dB)');
%     ylabel('Relació Cost-Benefici (Probabilitat de Lectura per Euro)');
%     title(['Relació Cost-Benefici per Atenuació de l''equipatge = ', num2str(Atenuacio_maleta), ' dB/m']);
%     ylim([0, max(relacion_costo_beneficio_p95, [], 'all') * 1.1]); % Ajustar los límites del eje Y para la relación
%     legend show; % Mostrar la llegenda per diferenciar les línies
%     grid on;
%     hold off; % Alliberar el gràfic per a la següent iteració
% 
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %Escenari 3 - Comparar 1 o dos antenas
% graficas = false;
% 
% coste_FXR90 = 6729+1000+2000+1.8; % Coste de un escenario utilizando la antena FXR90
% coste_AN520 = 6729+250+2000+1.8; % Coste de un escenario utilizando la antena AN520
% costos_antenas = [coste_FXR90, coste_AN520];
% 
% coste_2FXR90 = 6729+1000+1000+2000+1.8; % Coste de un escenario utilizando la antena FXR90
% coste_2AN520 = 6729+250+250+2000+1.8; % Coste de un escenario utilizando la antena AN520
% costos_2antenas = [coste_2FXR90, coste_2AN520];
% 
% % Definir los parámetros de variación
% atenuacion_min = 0;  % Valor mínimo de la atenuación de maletas
% atenuacion_max = 10; % Valor máximo de la atenuación de maletas
% atenuacion_step = 2; % Paso de variación de la atenuación de maletas
% 
% perdidas_min = 0;    % Valor mínimo de las pérdidas inespecíficas
% perdidas_max = 5;  % Valor máximo de las pérdidas inespecíficas
% perdidas_step = 0.5; % Paso de variación de las pérdidas inespecíficas
% 
% num_iteraciones = 300; % Número de iteraciones para cada configuración
% 
% tipoAntenaLector = 'Compare Mode'; % 'FXR90', 'AN520' o 'Compare Mode'
% 
% if strcmp(tipoAntenaLector, 'Compare Mode')
%     antenasAUsar = {'FXR90', 'AN520'};
% else
%     antenasAUsar = {tipoAntenaLector}; % Sólo una antena
% end
% 
% % Inicializar matriz para almacenar las probabilidades de lectura
% atenuaciones = atenuacion_min:atenuacion_step:atenuacion_max;
% perdidas = perdidas_min:perdidas_step:perdidas_max;
% 
% % Recorrer los valores de atenuación de las maletas utilizando parfor para paralelizar
% for i = 1:length(atenuaciones)
%     Atenuacio_maleta = atenuaciones(i); % Definir la atenuación actual
% 
%     % Inicializar matriz para almacenar resultados del percentil 95 de las iteraciones
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
%         % Ejecutar múltiples iteraciones para cada tipo de antena (sin parfor anidado)
%         for iter = 1:num_iteraciones
%             % Obtener un nuevo escenario para cada iteración con una antena
%             [maletas_pos, maletas_dim, tags_pos, reader_pos, vectors_dir] = escenario(graficas);
%             reader_pos_1 = reader_pos(1, :); % Utilizar solo la primera antena
%             vectors_dir_1 = vectors_dir(1,:);
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
%     % Crear la figura para la atenuación actual - comparación de una antena vs dos antenas
%     for antenaIdx = 1:length(antenasAUsar)
%         tipoAntena = antenasAUsar{antenaIdx};
% 
%         % Gráfico de Probabilidad de Lectura
%         figure;
%         hold on;
%         plot(perdidas, probabilidad_lectura_p95_1_antena(:, antenaIdx), '-o', 'DisplayName', ['1 Antena: ', tipoAntena, ' (Percentil 95)'], 'LineWidth', 2);
%         plot(perdidas, probabilidad_lectura_p95_2_antenas(:, antenaIdx), '-o', 'DisplayName', ['2 Antenas: ', tipoAntena, ' (Percentil 95)'], 'LineWidth', 2);
% 
%         % Configuración del gráfico en catalán
%         xlabel('Pèrdues Inespecífiques (dB)');
%         ylabel('Probabilitat de Lectura');
%         title(['Probabilitat de Lectura per Atenuació de l''equipatge = ', num2str(Atenuacio_maleta), ' dB/m - Antena: ', tipoAntena]);
%         ylim([0, 1]); % Ajustar los límites del eje Y de 0 a 1
%         legend show; % Mostrar la llegenda per diferenciar les línies
%         grid on;
%         hold off;
% 
%         % Gráfico de Relación Coste-Beneficio
%         relacion_costo_beneficio_p95_1_antena = probabilidad_lectura_p95_1_antena(:, antenaIdx) / costos_antenas(antenaIdx);
%         relacion_costo_beneficio_p95_2_antenas = probabilidad_lectura_p95_2_antenas(:, antenaIdx) / costos_2antenas(antenaIdx);
% 
%         figure;
%         hold on;
%         plot(perdidas, relacion_costo_beneficio_p95_1_antena, '-o', 'DisplayName', ['1 Antena: ', tipoAntena, ' (Relació Cost-Benefici)'], 'LineWidth', 2);
%         plot(perdidas, relacion_costo_beneficio_p95_2_antenas, '-o', 'DisplayName', ['2 Antenas: ', tipoAntena, ' (Relació Cost-Benefici)'], 'LineWidth', 2);
% 
%         % Configuración del gráfico en catalán para la relación costo-beneficio
%         xlabel('Pèrdues Inespecífiques (dB)');
%         ylabel('Relació Cost-Benefici (Probabilitat de Lectura per Euro)');
%         title(['Relació Cost-Benefici per Atenuació de l''equipatge = ', num2str(Atenuacio_maleta), ' dB/m - Antena: ', tipoAntena]);
%         ylim([0, max([relacion_costo_beneficio_p95_1_antena; relacion_costo_beneficio_p95_2_antenas]) * 1.1]); % Ajustar los límites del eje Y para la relación
%         legend show; % Mostrar la llegenda per diferenciar les línies
%         grid on;
%         hold off;
%     end
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %Escenari 4 - Comparar posiciones
% % Definir los parámetros de la simulación
% num_iteraciones = 300; % Número de iteraciones para cada configuración
% 
% length_caja = 110 * 0.0254; % 110 pulgadas a metros
% width_caja = 50 * 0.0254;   % 50 pulgadas a metros
% height_caja = 54 * 0.0254;  % 54 pulgadas a metros
% 
% graficas = false;
% coste_FXR90 = 6729 + 1000 + 2000 + 1.8; % Coste de un escenario utilizando la antena FXR90
% coste_AN520 = 6729 + 250 + 2000 + 1.8; % Coste de un escenario utilizando la antena AN520
% costos_antenas = [coste_FXR90, coste_AN520];
% 
% % Definir las posiciones de las antenas (cuatro posiciones posibles)
% posiciones_lectores = [
%      0, length_caja/2, height_caja; % Primera antena
%      width_caja/2, length_caja/2, height_caja;
%      width_caja/2, length_caja, height_caja
%      0, 0, height_caja;
% ];
% num_antennas = 4;
% [antennas_pos, vectors_dir] = calculate_antenna_vectors(num_antennas, posiciones_lectores);
% [maletas_pos, maletas_dim, tags_pos] = TAG_matrix('random', 'random', antennas_pos, vectors_dir, true,true);
% 
% % Definir los parámetros de variación
% atenuacion_min = 0;  % Valor mínimo de la atenuación de maletas
% atenuacion_max = 10; % Valor máximo de la atenuación de maletas
% atenuacion_step = 2; % Paso de variación de la atenuación de maletas
% 
% perdidas_min = 0;    % Valor mínimo de las pérdidas inespecíficas
% perdidas_max = 5;  % Valor máximo de las pérdidas inespecíficas
% perdidas_step = 0.5; % Paso de variación de las pérdidas inespecíficas
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
% % Recorrer los valores de atenuación de las maletas
% for i = 1:length(atenuaciones)
%     Atenuacio_maleta = atenuaciones(i); % Definir la atenuación actual
% 
%     % Inicializar matriz para almacenar resultados del percentil 95 de las iteraciones
%     probabilidad_lectura_p95_posiciones = zeros(length(perdidas), length(antenasAUsar), length(posiciones_lectores));
% 
%     % Recorrer las posiciones de los lectores
%     % Recorrer las posiciones de los lectores
% 
%     for posIdx = 1:size(posiciones_lectores, 1) 
%         reader_pos = posiciones_lectores(posIdx, :); 
% 
%         % Recorrer los valores de pérdidas inespecíficas
%         for j = 1:length(perdidas)
%             Perdues_k = perdidas(j); % Definir las pérdidas actuales
% 
%             % Matriz temporal para almacenar probabilidades de lectura de cada iteración
%             probabilidad_lectura_iteraciones = zeros(num_iteraciones, length(antenasAUsar));
% 
%             % Ejecutar múltiples iteraciones para cada tipo de antena (sin parfor anidado)
%             for iter = 1:num_iteraciones
%                 % Obtener un nuevo escenario para cada iteración
%                 [maletas_pos, maletas_dim, tags_pos, antennas_pos, vectors_dir] = escenario(reader_pos, graficas);
% 
%                 for antenaIdx = 1:length(antenasAUsar)
%                     tipoAntena = antenasAUsar{antenaIdx};  % Obtener el tipo de antena actual
%                     [link_budget_results] = linkbudget(reader_pos, vectors_dir, maletas_pos, maletas_dim, tags_pos, Atenuacio_maleta, Perdues_k, tipoAntena);
% 
%                     % Calcular la probabilidad de lectura (número de tags leídos / total de tags)
%                     num_tags = size(link_budget_results, 1);
%                     tags_leidos = sum(link_budget_results(:, 3), 'all'); % Sumar los tags leídos en la antena actual
%                     probabilidad_lectura_iteraciones(iter, antenaIdx) = tags_leidos / num_tags; % Proporción de tags leídos
%                 end
%             end
% 
%             % Calcular el percentil 95 de las probabilidades de lectura
%             probabilidad_lectura_p95_posiciones(j, :, posIdx) = prctile(probabilidad_lectura_iteraciones, 95, 1);
%         end
%     end
% 
%     % Crear gráficos para la atenuación actual - comparación de las cuatro posiciones
%     for antenaIdx = 1:length(antenasAUsar)
%         tipoAntena = antenasAUsar{antenaIdx};
% 
%         % Gráfico de Probabilidad de Lectura para las cuatro posiciones
%         figure;
%         hold on;
%         for posIdx = 1:length(posiciones_lectores)
%             plot(perdidas, probabilidad_lectura_p95_posiciones(:, antenaIdx, posIdx), '-o', 'DisplayName', ['Posición ', num2str(posIdx), ' (Percentil 95)'], 'LineWidth', 2);
%         end
% 
%         % Configuración del gráfico en catalán
%         xlabel('Pèrdues Inespecífiques (dB)');
%         ylabel('Probabilitat de Lectura');
%         title(['Probabilitat de Lectura per Atenuació de l''equipatge = ', num2str(Atenuacio_maleta), ' dB/m - Antena: ', tipoAntena]);
%         ylim([0, 1]); % Ajustar los límites del eje Y de 0 a 1
%         legend show; % Mostrar la llegenda per diferenciar les línies
%         grid on;
%         hold off;
%     end
%     % Gráfico de Relación Coste-Beneficio - Comparación específica para las tres posiciones en el mismo gráfico
%     figure;
%     hold on;
%     max_relacion_costo_beneficio = 0;
%     for antenaIdx = 1:length(antenasAUsar)
%         tipoAntena = antenasAUsar{antenaIdx};
%         for posIdx = [1, 2, 4] % Posiciones a comparar (1 de AN520 y 2, 4 de FXR90)
%             if strcmp(tipoAntena, 'AN520') && posIdx == 1
%                 relacion_costo_beneficio = probabilidad_lectura_p95_posiciones(:, antenaIdx, posIdx) / costos_antenas(antenaIdx);
%                 plot(perdidas, relacion_costo_beneficio, '-o', 'DisplayName', ['Antena AN520 - Posició ', num2str(posIdx), ' (Relació Cost-Benefici)'], 'LineWidth', 2);
%             elseif strcmp(tipoAntena, 'FXR90') && (posIdx == 2 || posIdx == 4)
%                 relacion_costo_beneficio = probabilidad_lectura_p95_posiciones(:, antenaIdx, posIdx) / costos_antenas(antenaIdx);
%                 plot(perdidas, relacion_costo_beneficio, '-o', 'DisplayName', ['Antena FXR90 - Posició ', num2str(posIdx), ' (Relació Cost-Benefici)'], 'LineWidth', 2);
%             end
%             max_relacion_costo_beneficio = max(max_relacion_costo_beneficio, max(relacion_costo_beneficio));
%         end
%     end
% 
%     % Configuración del gráfico en catalán para la relación costo-beneficio
%     xlabel('Pèrdues Inespecífiques (dB)');
%     ylabel('Relació Cost-Benefici (Probabilitat de Lectura per Euro)');
%     title(['Relació Cost-Benefici per Atenuació de l''equipatge = ', num2str(Atenuacio_maleta), ' dB/m']);
%     ylim([0, max_relacion_costo_beneficio * 1.1]); % Ajustar los límites del eje Y para la relación
%     legend show; % Mostrar la llegenda per diferenciar les línies
%     grid on;
%     hold off;
% 
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Escenari 5 - Comparar inclinaciones (Modificado para estilo de gráfica)
% Definir los parámetros de la simulación
num_iteraciones = 1; % Número de iteraciones para cada configuración

length_caja = 110 * 0.0254; % 110 pulgadas a metros
width_caja = 50 * 0.0254;   % 50 pulgadas a metros
height_caja = 54 * 0.0254;  % 54 pulgadas a metros

graficas = false;
coste_FXR90 = 6729 + 1000 + 2000 + 1.8; % Coste de un escenario utilizando la antena FXR90
coste_AN520 = 6729 + 250 + 2000 + 1.8; % Coste de un escenario utilizando la antena AN520
costos_antenas = [coste_FXR90, coste_AN520];

% Definir las posiciones de las antenas (cuatro posiciones posibles)
posiciones_lectores = [
     0, length_caja/2, height_caja; % Primera antena
     width_caja/2, length_caja/2, height_caja;
     0, 0, height_caja;
];
vectors_dir_1 = [
    width_caja/height_caja, 0, -height_caja/height_caja;
    0, 0, -1;
    width_caja/length_caja, length_caja/length_caja, -height_caja/length_caja;
];
%num_antennas = 3;
%[antennas_pos, vectors_dir] = calculate_antenna_vectors(num_antennas, posiciones_lectores);
[maletas_pos, maletas_dim, tags_pos] = TAG_matrix('random', 'random', posiciones_lectores, vectors_dir_1, true,true);

% Definir los parámetros de variación
atenuacion_min = 0;  % Valor mínimo de la atenuación de maletas
atenuacion_max = 10; % Valor máximo de la atenuación de maletas
atenuacion_step = 2; % Paso de variación de la atenuación de maletas

perdidas_min = 0;    % Valor mínimo de las pérdidas inespecíficas
perdidas_max = 5;  % Valor máximo de las pérdidas inespecíficas
perdidas_step = 0.5; % Paso de variación de las pérdidas inespecíficas

atenuaciones = atenuacion_min:atenuacion_step:atenuacion_max;
perdidas = perdidas_min:perdidas_step:perdidas_max;

tipoAntenaLector = 'Compare Mode'; % 'FXR90', 'AN520' o 'Compare Mode'
if strcmp(tipoAntenaLector, 'Compare Mode')
    antenasAUsar = {'FXR90', 'AN520'};
else
    antenasAUsar = {tipoAntenaLector}; % Sólo una antena
end

% Recorrer los valores de atenuación de las maletas
for i = 1:length(atenuaciones)
    Atenuacio_maleta = atenuaciones(i); % Definir la atenuación actual

    % Inicializar matriz para almacenar resultados del percentil 95 de las iteraciones
    probabilidad_lectura_p95_posiciones = zeros(length(perdidas), length(antenasAUsar), length(posiciones_lectores));

    % Recorrer las posiciones de los lectores
    % Recorrer las posiciones de los lectores

    for posIdx = 1:size(posiciones_lectores, 1) 
        reader_pos = posiciones_lectores(posIdx, :);
        vector_dir_actual = vectors_dir_1(posIdx, :); % Utilizar el vector de dirección correspondiente a la antena actual


        % Recorrer los valores de pérdidas inespecíficas
        for j = 1:length(perdidas)
            Perdues_k = perdidas(j); % Definir las pérdidas actuales

            % Matriz temporal para almacenar probabilidades de lectura de cada iteración
            probabilidad_lectura_iteraciones = zeros(num_iteraciones, length(antenasAUsar));

            % Ejecutar múltiples iteraciones para cada tipo de antena (sin parfor anidado)
            for iter = 1:num_iteraciones
                % Obtener un nuevo escenario para cada iteración
                [maletas_pos, maletas_dim, tags_pos, antennas_pos, vectors_dir] = escenario(reader_pos, graficas);

                for antenaIdx = 1:length(antenasAUsar)
                    tipoAntena = antenasAUsar{antenaIdx};  % Obtener el tipo de antena actual
                    [link_budget_results] = linkbudget(reader_pos, vector_dir_actual, maletas_pos, maletas_dim, tags_pos, Atenuacio_maleta, Perdues_k, tipoAntena);
                    %if posIdx ==3 && i == 5
                        %plot_tags_with_read_status(link_budget_results, maletas_pos, maletas_dim, tags_pos, reader_pos, tipoAntena);
                    %end
                    % Calcular la probabilidad de lectura (número de tags leídos / total de tags)
                    num_tags = size(link_budget_results, 1);
                    tags_leidos = sum(link_budget_results(:, 3), 'all'); % Sumar los tags leídos en la antena actual
                    probabilidad_lectura_iteraciones(iter, antenaIdx) = tags_leidos / num_tags; % Proporción de tags leídos
                end
            end

            % Calcular el percentil 95 de las probabilidades de lectura
            probabilidad_lectura_p95_posiciones(j, :, posIdx) = prctile(probabilidad_lectura_iteraciones, 95, 1);
        end
    end

    % Crear gráficos para la atenuación actual - comparación de las cuatro posiciones
    for antenaIdx = 1:length(antenasAUsar)
        tipoAntena = antenasAUsar{antenaIdx};

        % Gráfico de Probabilidad de Lectura para las cuatro posiciones
        figure;
        hold on;
        for posIdx = 1:length(posiciones_lectores)
            plot(perdidas, probabilidad_lectura_p95_posiciones(:, antenaIdx, posIdx), '-o', 'DisplayName', ['Posición ', num2str(posIdx), ' (Percentil 95)'], 'LineWidth', 2);
        end

        % Configuración del gráfico en catalán
        xlabel('Pèrdues Inespecífiques (dB)');
        ylabel('Probabilitat de Lectura');
        title(['Probabilitat de Lectura per Atenuació de l''equipatge = ', num2str(Atenuacio_maleta), ' dB/m - Antena: ', tipoAntena]);
        ylim([0, 1]); % Ajustar los límites del eje Y de 0 a 1
        legend show; % Mostrar la llegenda per diferenciar les línies
        grid on;
        hold off;
    end
    % % Gráfico de Relación Coste-Beneficio - Comparación específica para las tres posiciones en el mismo gráfico
    % figure;
    % hold on;
    % max_relacion_costo_beneficio = 0;
    % for antenaIdx = 1:length(antenasAUsar)
    %     tipoAntena = antenasAUsar{antenaIdx};
    %     for posIdx = [1, 2, 4] % Posiciones a comparar (1 de AN520 y 2, 4 de FXR90)
    %         if strcmp(tipoAntena, 'AN520') && posIdx == 1
    %             relacion_costo_beneficio = probabilidad_lectura_p95_posiciones(:, antenaIdx, posIdx) / costos_antenas(antenaIdx);
    %             plot(perdidas, relacion_costo_beneficio, '-o', 'DisplayName', ['Antena AN520 - Posició ', num2str(posIdx), ' (Relació Cost-Benefici)'], 'LineWidth', 2);
    %         elseif strcmp(tipoAntena, 'FXR90') && (posIdx == 2 || posIdx == 4)
    %             relacion_costo_beneficio = probabilidad_lectura_p95_posiciones(:, antenaIdx, posIdx) / costos_antenas(antenaIdx);
    %             plot(perdidas, relacion_costo_beneficio, '-o', 'DisplayName', ['Antena FXR90 - Posició ', num2str(posIdx), ' (Relació Cost-Benefici)'], 'LineWidth', 2);
    %         end
    %         max_relacion_costo_beneficio = max(max_relacion_costo_beneficio, max(relacion_costo_beneficio));
    %     end
    % end
    % 
    % % Configuración del gráfico en catalán para la relación costo-beneficio
    % xlabel('Pèrdues Inespecífiques (dB)');
    % ylabel('Relació Cost-Benefici (Probabilitat de Lectura per Euro)');
    % title(['Relació Cost-Benefici per Atenuació de l''equipatge = ', num2str(Atenuacio_maleta), ' dB/m']);
    % ylim([0, max_relacion_costo_beneficio * 1.1]); % Ajustar los límites del eje Y para la relación
    % legend show; % Mostrar la llegenda per diferenciar les línies
    % grid on;
    % hold off;

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%55
%Escenari 5b - Comparar inclinaciones
% Definir los parámetros de la simulación
% num_iteraciones = 300; % Número de iteraciones para cada configuración
% 
% length_caja = 110 * 0.0254; % 110 pulgadas a metros
% width_caja = 50 * 0.0254;   % 50 pulgadas a metros
% height_caja = 54 * 0.0254;  % 54 pulgadas a metros
% 
% graficas = false;
% coste_FXR90 = 6729 + 1000 + 2000 + 1.8; % Coste de un escenario utilizando la antena FXR90
% coste_AN520 = 6729 + 250 + 2000 + 1.8; % Coste de un escenario utilizando la antena AN520
% costos_antenas = [coste_FXR90, coste_AN520];
% 
% % Definir las posiciones de las antenas (una posición posible)
% posiciones_lectores = [
%      0, length_caja/2, height_caja; % Primera antena
% ];
% 
% % Vectores de dirección hardcodeados para la primera antena
% vectors_dir_1 = [
%     width_caja/height_caja, 0, -height_caja/height_caja;
% ];
% 
% num_antennas = 1;
% [calculated_antennas_pos, calculated_vectors_dir] = calculate_antenna_vectors(num_antennas, posiciones_lectores);
% 
% % Definir los parámetros de variación
% atenuacion_min = 0;  % Valor mínimo de la atenuación de maletas
% atenuacion_max = 10; % Valor máximo de la atenuación de maletas
% atenuacion_step = 2; % Paso de variación de la atenuación de maletas
% 
% perdidas_min = 0;    % Valor mínimo de las pérdidas inespecíficas
% perdidas_max = 5;  % Valor máximo de las pérdidas inespecíficas
% perdidas_step = 0.5; % Paso de variación de las pérdidas inespecíficas
% 
% atenuaciones = atenuacion_min:atenuacion_step:atenuacion_max;
% perdidas = perdidas_min:perdidas_step:perdidas_max;
% 
% tipoAntenaLector = 'AN520'; % 'FXR90', 'AN520' o 'Compare Mode'
% if strcmp(tipoAntenaLector, 'Compare Mode')
%     antenasAUsar = {'FXR90', 'AN520'};
% else
%     antenasAUsar = {tipoAntenaLector}; % Sólo una antena
% end
% 
% % Recorrer los valores de atenuación de las maletas
% for i = 1:length(atenuaciones)
%     Atenuacio_maleta = atenuaciones(i); % Definir la atenuación actual
% 
%     % Inicializar matriz para almacenar resultados del percentil 95 de las iteraciones
%     probabilidad_lectura_p95_posiciones = zeros(length(perdidas), length(antenasAUsar), 2); % Añadimos dimensión para las dos orientaciones
% 
%     % Recorrer los valores de pérdidas inespecíficas
%     for j = 1:length(perdidas)
%         Perdues_k = perdidas(j); % Definir las pérdidas actuales
% 
%         % Matriz temporal para almacenar probabilidades de lectura de cada iteración
%         probabilidad_lectura_iteraciones = zeros(num_iteraciones, length(antenasAUsar), 2);
% 
%         % Ejecutar múltiples iteraciones para cada tipo de antena (sin parfor anidado)
%         for iter = 1:num_iteraciones
%             % Obtener un nuevo escenario para cada iteración
%             [maletas_pos, maletas_dim, tags_pos, antennas_pos, ~] = escenario(posiciones_lectores(1, :), graficas);
% 
%             for antenaIdx = 1:length(antenasAUsar)
%                 tipoAntena = antenasAUsar{antenaIdx};  % Obtener el tipo de antena actual
% 
%                 % Comparar para las dos orientaciones: hardcodeado y calculado
%                 for orientacionIdx = 1:2
%                     if orientacionIdx == 1
%                         vector_dir = vectors_dir_1;
%                     else
%                         vector_dir = calculated_vectors_dir;
%                     end
% 
%                     [link_budget_results] = linkbudget(antennas_pos, vector_dir, maletas_pos, maletas_dim, tags_pos, Atenuacio_maleta, Perdues_k, tipoAntena);
% 
%                     % Calcular la probabilidad de lectura (número de tags leídos / total de tags)
%                     num_tags = size(link_budget_results, 1);
%                     tags_leidos = sum(link_budget_results(:, 3), 'all'); % Sumar los tags leídos en la antena actual
%                     probabilidad_lectura_iteraciones(iter, antenaIdx, orientacionIdx) = tags_leidos / num_tags; % Proporción de tags leídos
%                 end
%             end
%         end
% 
%         % Calcular el percentil 95 de las probabilidades de lectura
%         probabilidad_lectura_p95_posiciones(j, :, :) = prctile(probabilidad_lectura_iteraciones, 95, 1);
%     end
% 
%     % Crear gráficos para la atenuación actual - comparación de las dos orientaciones
%     for antenaIdx = 1:length(antenasAUsar)
%         tipoAntena = antenasAUsar{antenaIdx};
% 
%         % Gráfico de Probabilidad de Lectura para las dos orientaciones
%         figure;
%         hold on;
%         plot(perdidas, probabilidad_lectura_p95_posiciones(:, antenaIdx, 1), '-o', 'DisplayName', ['Orientación Diagonal (Percentil 95)'], 'LineWidth', 2);
%         plot(perdidas, probabilidad_lectura_p95_posiciones(:, antenaIdx, 2), '-o', 'DisplayName', ['Orientación Horitzontal (Percentil 95)'], 'LineWidth', 2);
% 
%         % Configuración del gráfico en catalán
%         xlabel('Pèrdues Inespecífiques (dB)');
%         ylabel('Probabilitat de Lectura');
%         title(['Probabilitat de Lectura per Atenuació de l''equipatge = ', num2str(Atenuacio_maleta), ' dB/m - Antena: ', tipoAntena]);
%         ylim([0, 1]); % Ajustar los límites del eje Y de 0 a 1
%         legend show; % Mostrar la llegenda per diferenciar les línies
%         grid on;
%         hold off;
%     end
% 
% end
