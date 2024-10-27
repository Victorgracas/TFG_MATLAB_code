% graficador_2.m - Script para graficar probabilidades de lectura por antena y guardar gráficas

% Configuración de los rangos y parámetros
atenuaciones = 0:0.1:12; % Rango de atenuaciones de 0 a 10 dB con saltos de 0.2 dB
perdidas_k = 0:0.1:22;    % Rango de pérdidas k de 0 a 10 dB con saltos de 0.2 dB
probabilidad_minima = 0.8; % Umbral de probabilidad de lectura
num_iteraciones = 25; % Número de iteraciones para cada combinación de parámetros

% Parámetros fijos del lector y simulación
tipoAntenaLector = 'Compare Mode'; % 'FXR90', 'AN520' o 'Compare Mode'
graficas = false;

% Seleccionar las antenas según el modo de comparación
if strcmp(tipoAntenaLector, 'Compare Mode')
    antenasAUsar = {'FXR90', 'AN520'};
else
    antenasAUsar = {tipoAntenaLector}; % Sólo una antena
end

% Obtener el escenario común para todas las simulaciones
[maletas_pos, maletas_dim, tags_pos, reader_pos, vectors_dir] = nuevo_escenario(graficas);

% Inicializar una estructura de resultados para almacenar las probabilidades de lectura por antena
resultado_probabilidad_antenas = cell(length(antenasAUsar), 1);
for idx = 1:length(antenasAUsar)
    resultado_probabilidad_antenas{idx} = zeros(length(perdidas_k), length(atenuaciones));
end

% Iterar sobre los valores de atenuaciones y pérdidas
for i = 1:length(atenuaciones)
    Atenuacio_maleta = atenuaciones(i);

    for j = 1:length(perdidas_k)
        Perdues_k = perdidas_k(j);

        % Ejecutar múltiples iteraciones para promediar la probabilidad de lectura
        for antenaIdx = 1:length(antenasAUsar)
            tipoAntena = antenasAUsar{antenaIdx};
            probabilidad_acumulada = 0;

            for iter = 1:num_iteraciones
                % Ejecutar la simulación para cada tipo de antena y calcular la probabilidad de lectura
                link_budget_results = linkbudget(reader_pos, vectors_dir, maletas_pos, maletas_dim, tags_pos, Atenuacio_maleta, Perdues_k, tipoAntena);

                % Calcular la probabilidad de lectura para esta antena
                num_tags = size(link_budget_results, 1);
                tags_leidos = sum(link_budget_results(:, 3), 'all');
                probabilidad_lectura = tags_leidos / num_tags;

                % Acumular la probabilidad total de esta iteración
                probabilidad_acumulada = probabilidad_acumulada + probabilidad_lectura;
            end

            % Calcular la probabilidad promedio de lectura para esta combinación de atenuación y pérdida
            resultado_probabilidad_antenas{antenaIdx}(j, i) = probabilidad_acumulada / num_iteraciones;
        end
    end
end

% Crear carpeta para guardar las gráficas
output_folder = 'C:\Users\vgrac\OneDrive\Escritorio\UNI\TFG\Resultats\FadeMargin\Escenari1';
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

% Filtrar los puntos que cumplen con el umbral de probabilidad mínima y graficar para cada antena
[X, Y] = meshgrid(atenuaciones, perdidas_k);
for antenaIdx = 1:length(antenasAUsar)
    Z = resultado_probabilidad_antenas{antenaIdx};
    Z(Z < probabilidad_minima) = NaN; % Establecer los puntos que no cumplen con el umbral como NaN

    % Crear el gráfico 3D para cada antena
    figure;
    surf(X, Y, Z, 'EdgeColor', 'none'); % Gráfica de superficie sin bordes
    colorbar;
    colormap(jet); % Paleta de colores

    % Configuración de los ejes y título
    xlabel('Atenuació de la maleta (dB)');
    ylabel('Pèrdues Inespecífiques (dB)');
    zlabel('Probabilitat de Lectura');
    title(['Gràfic de Probabilitat de Lectura >= 0.8 - Antena: ' antenasAUsar{antenaIdx}]);
    view(3);
    grid on;

    % Guardar la gráfica en la carpeta especificada como .fig
    savefig(fullfile(output_folder, ['grafico_probabilidad_' antenasAUsar{antenaIdx} '.fig']));
    % Guardar también como imagen PNG
    saveas(gcf, fullfile(output_folder, ['grafico_probabilidad_' antenasAUsar{antenaIdx} '.png']));
    close(gcf);
end

% Nueva función para definir un escenario sin modificar las existentes
function [maletas_pos, maletas_dim, tags_pos, reader_pos, vectors_dir] = nuevo_escenario(graficas)
    % Parámetros de la caja (en metros)
    length_caja = 110 * 0.0254; % 110 pulgadas a metros
    width_caja = 50 * 0.0254;   % 50 pulgadas a metros
    height_caja = 54 * 0.0254;  % 54 pulgadas a metros

    % Definir las posiciones de las antenas
    num_antenna = 1; % Número de antenas por defecto
    reader_pos = [
        0, length_caja / 2, height_caja; % Primera antena ubicada en el centro de un lado
    ];

    % Generar posiciones de lectores y su dirección
    [antennas_pos, vectors_dir] = nuevo_calculate_antenna_vectors(num_antenna, reader_pos);
    % Generar posiciones de maletas y tags
    [maletas_pos, maletas_dim, tags_pos] = TAG_matrix('random', 'random', antennas_pos, vectors_dir, graficas, false);
end

% Nueva función para calcular las posiciones y direcciones de las antenas
function [antennas_pos, vectors_dir] = nuevo_calculate_antenna_vectors(num_antennas, reader_positions)
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
            vectors_dir(i, :) = [1, 0, 0]; % Apunta hacia el lado opuesto en el eje X positivo
        else
            % Si la posición no coincide con ningún caso estándar, dejar vector nulo
            vectors_dir(i, :) = [0, 0, -1]; % Por defecto, apunta hacia abajo en Z
        end
    end
end
