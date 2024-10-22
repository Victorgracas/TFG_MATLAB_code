function antena_gain = Antenna_Gain(tipoAntena, angulo_ver, angulo_hor)
    % Cargar datos de radiación
    data = cargarDatosRadiacion();

    % Buscar los datos correspondientes al tipo de antena
    if isfield(data, tipoAntena)
        antenaData = data.(tipoAntena);
    else
        error('Tipo de antena no encontrada');
    end
    
    % Calcular la ganancia en función del tipo de antena
    if strcmp(tipoAntena, 'TAG')
        % Solo hay ganancia en el plano vertical para la antena TAG
        ganancia_ver = interp1(antenaData.angulos, antenaData.ganancia, angulo_ver, 'linear', 'extrap');
        antena_gain = ganancia_ver + antenaData.gananciaISO;
    else
        % Para las demás antenas, se considera tanto el plano horizontal como el vertical
        ganancia_hor = interp1(antenaData.angulos, antenaData.gananciahor, angulo_hor, 'linear', 'extrap');
        ganancia_ver = interp1(antenaData.angulos, antenaData.gananciaver, angulo_ver, 'linear', 'extrap');
        antena_gain = ganancia_hor + ganancia_ver + antenaData.gananciaISO;
    end
end

% Esta función carga los datos de radiación para varias antenas
function data = cargarDatosRadiacion()
    % Definir los datos de radiación para varias antenas
    % Diagrama de radiación del Zebra AN510
    data.FXR90.angulos = [0,15,30,45,60,75,90,105,120,135,150,165,180,195,210,225,240,255,270,285,300,315,330,345,360]; % en grados
    data.FXR90.gananciahor = [0, -0.5, -2.5, -5, -7.5, -12, -17, -200, -200, -200, -19, -17, -15, -15, -17, -18, -18, -17, -13.5, -11, -6.5, -4, -2, -0.001, 0]; % en dB
    data.FXR90.gananciaver = [0,-0.5,-3,-6,-11,-17,-21,-19,-18,-18,-18,-18,-18,-200,-21,-18.5,-18.5,-200,-17,-12.5,-7.5,-4,-1.5,0,0]; % en dB
    data.FXR90.gananciaISO = 7; % en dB

    data.AN520.angulos = 0:15:360; % en grados
    data.AN520.gananciahor = [0,0,-0.1,-0.5,-2,-3,-4,-5,-7,-9,-15,-25,-18,-25,-17,-10,-7,-5,-4,-2.5,-1.5,-0.5,-0.1,0,0]; % en dB
    data.AN520.gananciaver = [0,-0.1,-1,-2.5,-4,-6,-8,-14,-200,-200,-15,-11.5,-10,-12,-15,-200,-200,-12.5,-8,-6,-4,-2.5,-1,-0.1,0]; % en dB
    data.AN520.gananciaISO = 5.5; % en dB

    % Datos de radiación de la antena TAG (solo plano vertical)
    data.TAG.angulos = 0:10:360; % en grados
    data.TAG.distancia = [16, 15.5, 15, 14, 14.5, 14.5, 13, 12.5, 12, 12, 12.5, 12.5, 13.5, 14, 14, 15, 15, 15, 15, 15, 14, 13.5, 13.5, 12.5, 12, 12, 12, 12, 12.5, 13, 13.5, 14, 15, 15, 15, 16, 16]; % en metros
    distanciaMax = max(data.TAG.distancia);
    distancias_mod = data.TAG.distancia;
    distancias_mod(distancias_mod < 1e-10) = 1e-10;
    data.TAG.ganancia = 20 * log10(distancias_mod ./ distanciaMax); % en dB
    
    data.TAG.gananciaISO = 2.15; % en dB
end
