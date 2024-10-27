function [maletas_pos, maletas_dim, tags_pos, antennas_pos, vectors_dir] = escenario(reader_pos, num_antenna, graficas)
    % Parámetros de la caja (en metros)
    length_caja = 110 * 0.0254; % 110 pulgadas a metros
    width_caja = 50 * 0.0254;   % 50 pulgadas a metros
    height_caja = 54 * 0.0254;  % 54 pulgadas a metros

    % Parámetros de simulación
    %Atenuacio_maleta = 3; % Atenuación por maleta en dB
    %Perdues_k = 2; % Pérdidas inespecíficas en dB
    Posicio_TAG = 'random'; % Posición del TAG: 'inside', 'outside' o 'random'
    Dimensions_maletes = 'random'; % Dimensiones de las maletas: 'random' o 'std'
    %k_perdidas = 2; % Pérdidas inespecíficas


    % Posiciones de las antenas en el lector (agregamos una antena)
    %num_antenna = 2;
    % reader_pos = [
    %      0, length_caja/2, height_caja; % Primera antena
    %      %width_caja, length_caja/2, height_caja;
    %      width_caja/2, length_caja/2, height_caja;
    %      width_caja/2, length_caja, height_caja
    %      0, 0, height_caja;
    % ];

    % tipoAntenaLector = 'FXR90'; % 'FXR90', 'AN520' o 'Compare Mode'

    % Generar posiciones de lectores y su dirección
    [antennas_pos, vectors_dir] = calculate_antenna_vectors(num_antenna, reader_pos);
    % Generar posiciones de maletas y tags
    [maletas_pos, maletas_dim, tags_pos] = TAG_matrix(Posicio_TAG, Dimensions_maletes, antennas_pos, vectors_dir, graficas,false);

    % % Selección de antenas según el modo
    % if strcmp(tipoAntenaLector, 'Compare Mode')
    %     antenasAUsar = {'FXR90', 'AN520'};
    % else
    %     antenasAUsar = {tipoAntenaLector}; % Sólo una antena
    % end    
   
end
