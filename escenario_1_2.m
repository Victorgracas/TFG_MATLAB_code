%Comparación simple entre ambas antenas. Puedes hardcodear la posicion
graficas = false;

coste_FXR90 = 6729+1000+1000+2000+1.8; % Coste de un escenario utilizando la antena FXR90
coste_AN520 = 6729+250+250+2000+1.8; % Coste de un escenario utilizando la antena AN52

costos_antenas = [coste_FXR90, coste_AN520];

% Definir los parámetros de variación
atenuacion_min = 0;  % Valor mínimo de la atenuación de maletas
atenuacion_max = 10; % Valor máximo de la atenuación de maletas
atenuacion_step = 2; % Paso de variación de la atenuación de maletas

perdidas_min = 0;    % Valor mínimo de las pérdidas inespecíficas
perdidas_max = 5;  % Valor máximo de las pérdidas inespecíficas
perdidas_step = 0.5; % Paso de variación de las pérdidas inespecíficas

num_iteraciones = 20; % Número de iteraciones para cada configuración

tipoAntenaLector = 'Compare Mode'; % 'FXR90', 'AN520' o 'Compare Mode'

if strcmp(tipoAntenaLector, 'Compare Mode')
    antenasAUsar = {'FXR90', 'AN520'};
else
    antenasAUsar = {tipoAntenaLector}; % Sólo una antena
end

% Inicializar matriz para almacenar las probabilidades de lectura
atenuaciones = atenuacion_min:atenuacion_step:atenuacion_max;
perdidas = perdidas_min:perdidas_step:perdidas_max;

% Recorrer los valores de atenuación de las maletas utilizando parfor para paralelizar
parfor i = 1:length(atenuaciones)
    Atenuacio_maleta = atenuaciones(i); % Definir la atenuación actual

    % Inicializar matriz para almacenar resultados del percentil 95 de las iteraciones
    probabilidad_lectura_p95 = zeros(length(perdidas), length(antenasAUsar));

    % Recorrer los valores de pérdidas inespecíficas
    for j = 1:length(perdidas)
        Perdues_k = perdidas(j); % Definir las pérdidas actuales


        % Matriz temporal para almacenar probabilidades de lectura de cada iteración
        probabilidad_lectura_iteraciones = zeros(num_iteraciones, length(antenasAUsar));

        % Ejecutar múltiples iteraciones para cada tipo de antena (sin parfor anidado)
        for iter = 1:num_iteraciones
            % Obtener un nuevo escenario para cada iteración
            [maletas_pos, maletas_dim, tags_pos, reader_pos, vectors_dir] = escenario(graficas);

            for antenaIdx = 1:length(antenasAUsar)
                tipoAntena = antenasAUsar{antenaIdx};  % Obtener el tipo de antena actual
                [link_budget_results] = linkbudget(reader_pos, vectors_dir, maletas_pos, maletas_dim, tags_pos, Atenuacio_maleta, Perdues_k, tipoAntena);
                %plot_tags_with_read_status(link_budget_results, maletas_pos, maletas_dim, tags_pos, reader_pos, tipoAntena);

                % Calcular la probabilidad de lectura (número de tags leídos / total de tags)
                num_tags = size(link_budget_results, 1);
                tags_leidos = sum(link_budget_results(:, 3), 'all'); % Sumar los tags leídos en la antena actual
                probabilidad_lectura_iteraciones(iter, antenaIdx) = tags_leidos / num_tags; % Proporción de tags leídos
            end
        end

        % Calcular el percentil 95 de las probabilidades de lectura
        probabilidad_lectura_p95(j, :) = prctile(probabilidad_lectura_iteraciones, 95, 1);
    end

    % Crear la figura para la atenuación actual
    figure;
    hold on; % Mantener el gráfico para agregar múltiples líneas

    % Graficar la línea para cada tipo de antena con percentil 95
    for antenaIdx = 1:length(antenasAUsar)
        tipoAntena = antenasAUsar{antenaIdx};
        plot(perdidas, probabilidad_lectura_p95(:, antenaIdx), '-o', 'DisplayName', ['Antena: ', tipoAntena, ' (Percentil 95)'], 'LineWidth', 2);
    end

    % Configuración del gráfico en catalán
    xlabel('Pèrdues Inespecífiques (dB)');
    ylabel('Probabilitat de Lectura');
    title(['Probabilitat de Lectura per Atenuació de l''equipatge = ', num2str(Atenuacio_maleta), ' dB/m']);
    ylim([0, 1]); % Ajustar los límites del eje Y de 0 a 1
    legend show; % Mostrar la llegenda per diferenciar les línies
    grid on;
    hold off; % Alliberar el gràfic per a la següent iteració


    relacion_costo_beneficio_p95 = probabilidad_lectura_p95 ./ costos_antenas;

    % Crear la figura para la relación costo-beneficio con la atenuación actual
    figure;
    hold on; % Mantener el gráfico para agregar múltiples líneas

    % Graficar la línea para cada tipo de antena con percentil 95 (relación costo-beneficio)
    for antenaIdx = 1:length(antenasAUsar)
        tipoAntena = antenasAUsar{antenaIdx};
        plot(perdidas, relacion_costo_beneficio_p95(:, antenaIdx), '-o', 'DisplayName', ['Antena: ', tipoAntena, ' (Relació Cost-Benefici)'], 'LineWidth', 2);
    end

    % Configuración del gráfico en catalán para la relación costo-beneficio
    xlabel('Pèrdues Inespecífiques (dB)');
    ylabel('Relació Cost-Benefici (Probabilitat de Lectura per Euro)');
    title(['Relació Cost-Benefici per Atenuació de l''equipatge = ', num2str(Atenuacio_maleta), ' dB/m']);
    ylim([0, max(relacion_costo_beneficio_p95, [], 'all') * 1.1]); % Ajustar los límites del eje Y para la relación
    legend show; % Mostrar la llegenda per diferenciar les línies
    grid on;
    hold off; % Alliberar el gràfic per a la següent iteració

end