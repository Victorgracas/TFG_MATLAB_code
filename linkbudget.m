function [link_budget_results] = linkbudget(reader_pos, vectors_dir, maletas_pos, maletas_dim, tags_pos, Atenuacio_maleta,Perdues_k, tipoAntena)

    % Parámetros del lector (América)
    Pt = 33; % Potencia de transmisión del lector en dBm
    S_lectora = -92; % Sensibilidad del receptor del lector en dBm

    % Parámetros del tag
    Ganancia_TAG = 2.15;
    Coef_reflexion = 0.8;
    Sensibilidad_lectura_tag = -24; % Sensibilidad de lectura del tag en dBm
    Sensibilidad_escritura_tag = -21; % Sensibilidad de escritura del tag en dBm
    Max_potencia_rx = 20;
    Rango_Angulos_TAG = [0, 0]; % Rango de ángulos para el TAG en grados

% Inicializar matriz para almacenar resultados de link budget para cada antena
    num_tags = size(tags_pos, 1);
    link_budget_results = zeros(num_tags, 3); % [n_tags, n_antenas, 3 (Potencia ida, Potencia vuelta, Suficiencia)]

    % % Cálculo del link budget para cada antena del lector y cada etiqueta
    % for antenaIdx = 1:length(antenasAUsar)
    %     tipoAntena = antenasAUsar{antenaIdx};

    for i = 1:num_tags
        % Inicializar flag que indica si el tag ha sido leído por alguna antena
        tag_leido = false;

        % Para cada antena, evaluar si tiene suficiente potencia para leer el tag
        for antennaPosIdx = 1:size(reader_pos, 1)
            % Obtener la posición de la antena y su vector de dirección

            
            current_antenna_pos = reader_pos(antennaPosIdx, :);
            current_vector_dir = vectors_dir(antennaPosIdx, :);

            if current_vector_dir(3) == 0
                % La antena está orientada horizontalmente en el plano XY
            
                % Distancia entre la antena y el tag
                distancia = norm(tags_pos(i, :) - current_antenna_pos);
            
                % Vector que une la antena con el tag
                vector_lector_tag = tags_pos(i, :) - current_antenna_pos;
            
                % Proyección del vector lector-tag en el plano ortogonal a la dirección de la antena
                vector_proj = vector_lector_tag - dot(vector_lector_tag, current_vector_dir) * current_vector_dir / norm(current_vector_dir)^2;
            
                % Calcular el ángulo theta con respecto al eje Z usando la proyección
                theta = 180 - acosd(vector_proj(3) / norm(vector_proj)); % Ángulo en grados respecto al eje Z
            
                % Calcular el ángulo azimutal (phi) respecto al vector de dirección
                cos_phi = dot(vector_lector_tag(1:2), current_vector_dir(1:2)) / (norm(vector_lector_tag(1:2)) * norm(current_vector_dir(1:2)));
                phi = acosd(cos_phi); % Ángulo en grados
            
            elseif current_vector_dir(3) == -1 && current_vector_dir(1) == 0 && current_vector_dir(2) == 0
                % La antena está orientada completamente vertical (en el eje Z negativo)
                % θ = 0 está en el eje Z negativo, el plano que recorre θ es el plano YZ
                % φ = 0 está en el eje Z negativo, el plano que recorre φ es el plano XZ
            
                % Distancia entre la antena y el tag
                distancia = norm(tags_pos(i, :) - current_antenna_pos);
            
                % Vector que une la antena con el tag
                vector_lector_tag = tags_pos(i, :) - current_antenna_pos;
            
                % Calcular el ángulo theta con respecto al eje Z, en el plano YZ
                theta = atan2d(vector_lector_tag(2), -vector_lector_tag(3)); % Ángulo en grados respecto al eje Z en el plano YZ
            
                % Calcular el ángulo azimutal (phi) con respecto al eje Z, en el plano XZ
                phi = atan2d(vector_lector_tag(1), -vector_lector_tag(3)); % Ángulo en grados respecto al eje Z en el plano XZ
            elseif current_antenna_pos(1) == 0 && current_antenna_pos(2) == 0
                % Vector que une la antena con el tag
                vector_lector_tag = tags_pos(i, :) - current_antenna_pos;
                
                % Distancia total entre la antena y el tag
                distancia = norm(vector_lector_tag);
                
                % Proyección del vector lector-tag en el plano ortogonal a la dirección de la antena
                vector_proj = vector_lector_tag - dot(vector_lector_tag, current_vector_dir) * current_vector_dir / norm(current_vector_dir)^2;
                
                % Distancia en el eje X y Y entre la antena y el tag
                distancia_xy = sqrt((tags_pos(i, 1) - current_antenna_pos(1))^2 + (tags_pos(i, 2) - current_antenna_pos(2))^2);
            
                % Diferencia en el eje Z entre la antena y el tag
                diferencia_z = abs(tags_pos(i, 3) - current_antenna_pos(3));
            
                % Calcular la distancia total (Q), es decir, la hipotenusa usando XY y Z
                distancia_total = sqrt(distancia_xy^2 + diferencia_z^2);
            
                % Calcular el ángulo theta sin inclinación (utilizando el triángulo rectángulo)
                theta_sin_inclinacion = atand(distancia_xy / diferencia_z); % Ángulo en grados
            
                % Obtener la inclinación de la antena utilizando las medidas del carro
                inclinacion_antena = atand(abs(current_vector_dir(3)) / sqrt(current_vector_dir(1)^2 + current_vector_dir(2)^2));
            
                % Ajustar el ángulo theta para tener en cuenta la inclinación de la antena
                theta = theta_sin_inclinacion - inclinacion_antena;

                
                % Calcular el ángulo azimutal (phi) en el plano XY
                cos_phi = dot(vector_lector_tag(1:2), current_vector_dir(1:2)) / (norm(vector_lector_tag(1:2)) * norm(current_vector_dir(1:2)));
                phi = acosd(cos_phi); % Ángulo en grados respecto al plano XY
            else
                % Vector que une la antena con el tag
                vector_lector_tag = tags_pos(i, :) - current_antenna_pos;
                
                % Distancia total entre la antena y el tag
                distancia = norm(vector_lector_tag);
                
                % Proyección del vector lector-tag en el plano ortogonal a la dirección de la antena
                vector_proj = vector_lector_tag - dot(vector_lector_tag, current_vector_dir) * current_vector_dir / norm(current_vector_dir)^2;
                
                % Calcular el ángulo theta original (ángulo de elevación sin tener en cuenta la inclinación de la antena)
                theta_sin_inclinacion = acosd(abs(vector_lector_tag(3)) / distancia); % Ángulo en grados respecto al eje Z
                
                % La inclinación de la antena está determinada por el vector de dirección (su componente Z indica la inclinación)
                % Si la antena está inclinada hacia abajo, restamos el ángulo de inclinación de la antena
                inclinacion_antena = acosd(abs(current_vector_dir(3)) / norm(current_vector_dir)); % Este es el ángulo de inclinación de la antena
                
                % Ajustamos el ángulo theta para restar la inclinación de la antena
                theta = theta_sin_inclinacion - inclinacion_antena;
                
                % Calcular el ángulo azimutal (phi) en el plano XY
                cos_phi = dot(vector_lector_tag(1:2), current_vector_dir(1:2)) / (norm(vector_lector_tag(1:2)) * norm(current_vector_dir(1:2)));
                phi = acosd(cos_phi); % Ángulo en grados respecto al plano XY


            end





            % Calcular ganancia efectiva del lector en función de los ángulos
            G_eff_lector = Antenna_Gain(tipoAntena, phi, theta); % Considerar ambos planos

            % Calcular ángulo random entre el rango dado en los parámetros para el TAG
            angulo_TAG = 360 * rand();

            % Calcular ganancia efectiva del tag en función del ángulo combinado
            G_eff_tag = Antenna_Gain('TAG', angulo_TAG, 0); % Solo se usa el ángulo vertical para el TAG

            % Cálculo de la pérdida de propagación en espacio libre (Friis)
            %lambda = 3e8 / (868e6); % Longitud de onda en metros para 868 MHz
            lambda = 3e8 / (915e6); % Longitud de onda en metros para 868 MHz

            FSL = 20 * log10(4 * pi * distancia / lambda); % Pérdida de espacio libre en dB

            % Calcular la atenuación por maletas
            [num_maletas, atenuacion_maletas_db] = atenuacion_maletas(maletas_pos, maletas_dim, current_antenna_pos, tags_pos(i, :), Atenuacio_maleta);

            % Cálculo de la potencia recibida en el tag (Ida)
            Pr_tag = Pt + G_eff_lector - (Perdues_k + FSL + atenuacion_maletas_db) + G_eff_tag; % Potencia recibida en el tag en dBm

            % Verificar si es suficiente para leer el tag
            if Pr_tag >= Sensibilidad_lectura_tag
                % **Cálculo del link budget de vuelta** (desde el tag hacia el lector)
                % Potencia reflejada por el tag (coeficiente de reflexión aplicado)
                Pr_vuelta_tag = Pr_tag + 10 * log10(Coef_reflexion^2); % Potencia reflejada

                % Pérdidas de espacio libre para la señal de vuelta
                FSL_vuelta = FSL; % Igual que el FSL de ida

                % Potencia recibida por el lector (de vuelta)
                Pr_lector = Pr_vuelta_tag + G_eff_tag + G_eff_lector - FSL_vuelta - atenuacion_maletas_db - Perdues_k;

                % Verificar si la potencia de vuelta es suficiente para que el lector lea el tag
                if Pr_lector >= S_lectora
                    link_budget_results(i, 1) = Pr_tag; % Guardar la potencia de ida
                    link_budget_results(i, 2) = Pr_lector; % Guardar la potencia de vuelta
                    link_budget_results(i, 3) = 1; % Es suficiente para leer de vuelta
                    tag_leido = true; % El tag ha sido leído por esta antena
                else
                    link_budget_results(i, 1) = Pr_tag; % Guardar la potencia de ida
                    link_budget_results(i, 2) = Pr_lector; % Guardar la potencia de vuelta
                    link_budget_results(i, 3) = 0; % No es suficiente para leer de vuelta
                end

                break; % Salimos del bucle si el tag es leído por esta posición de antena
            else
                link_budget_results(i, 1) = Pr_tag; % Guardar la potencia de ida
                link_budget_results(i, 2) = 0; % Guardar la potencia de ida
                link_budget_results(i, 3) = 0; % No es suficiente para leer en ida
            end
        end

        % Si el tag ha sido leído, no se necesita evaluar más antenas en esta iteración
        if tag_leido
            %fprintf('Tag %d ha sido leído por la antena %s\n', i, tipoAntena);
        else
            %fprintf('Tag %d no ha sido leído por la antena %s\n', i, tipoAntena);
        end
    end
end