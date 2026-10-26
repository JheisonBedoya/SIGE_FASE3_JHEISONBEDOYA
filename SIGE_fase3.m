
% RETO 3 - SISTEMA INTELIGENTE DE GESTION ENERGETICA
% PASO 2: PROGRAMACION Y SIMULACION EN MATLAB
% Control automatico de una micro-red durante 24 horas

clc;                         % Limpiar ventana de comandos
clear;                       % Eliminar variables anteriores
close all;                   % Cerrar graficas anteriores

% ETAPA 1: CONFIGURACION INICIAL

% Vector de generacion solar en kW
solar = [0 0 0 0 0 2 5 9 13 17 21 25 ...
         23 20 17 13 9 5 2 0 0 0 0 0];

% Vector de generacion eolica en kW
eolica = [7 9 6 11 8 10 12 9 7 13 11 8 ...
          10 14 12 9 11 7 10 13 8 6 9 7];

% Vector de demanda total en kW
demanda = [3 3 2 4 3 7 7 8 8 9 9 10 ...
           9 8 8 9 10 15 15 15 15 4 3 3];

% Calcular generacion hibrida total
Egen = solar + eolica;

% Definir demanda energetica
Edem = demanda;

% Capacidad total de bateria en kWh
Capacidadbat = 100;

% Estado inicial de carga en porcentaje
SOC = 50;

% Duracion de cada intervalo en horas
dt = 1;

% Crear vectores para guardar resultados
SOC_historial = zeros(1,24);
balance_historial = zeros(1,24);

% ETAPA 2: SIMULACION DE 24 HORAS

% Mostrar encabezado del reporte
fprintf('\n SISTEMA INTELIGENTE DE GESTION ENERGETICA\n');
fprintf(' SIMULACION DE MICRO-RED - 24 HORAS\n');

% Iniciar ciclo de simulacion
for t = 1:24

    % Calcular balance de potencia
    balance = Egen(t) - Edem(t);

    % Calcular energia del intervalo
    energia_balance = balance * dt;

    % Inicializar servicios como activos
    escuela = 'ACTIVA';
    bombeo = 'ACTIVO';
    alumbrado = 'ACTIVO';

    % ETAPA 3: LOGICA DE DECISION

    % Verificar si existe superavit
    if balance >= 0

        % Calcular energia excedente
        excedente = energia_balance;

        % Actualizar SOC por carga
        SOC = SOC + (excedente/Capacidadbat)*100;

        % Limitar carga maxima al 100%
        SOC = min(SOC,100);

        % Identificar estado de superavit
        estado = 'SUPERAVIT';

    else

        % Calcular energia faltante
        faltante = abs(energia_balance);

        % Actualizar SOC por descarga
        SOC = SOC - (faltante/Capacidadbat)*100;

        % Evitar SOC negativo
        SOC = max(SOC,0);

        % Identificar estado de deficit
        estado = 'DEFICIT';

        % ETAPA 4: DESCONEXION DE CARGAS

        % Ruta segura: SOC mayor al 40%
        if SOC > 40

            % Mantener todos los servicios activos
            escuela = 'ACTIVA';
            bombeo = 'ACTIVO';
            alumbrado = 'ACTIVO';

        % Ruta de alerta: SOC entre 20% y 40%
        elseif SOC > 20

            % Mantener escuela activa
            escuela = 'ACTIVA';

            % Mantener bombeo activo
            bombeo = 'ACTIVO';

            % Desconectar alumbrado publico
            alumbrado = 'SUSPENDIDO';

        % Ruta de emergencia: SOC menor o igual a 20%
        else

            % Priorizar escuela rural
            escuela = 'ACTIVA';

            % Desconectar bombeo agricola
            bombeo = 'SUSPENDIDO';

            % Desconectar alumbrado publico
            alumbrado = 'SUSPENDIDO';

        end
    end

    % ETAPA 5: ALMACENAR RESULTADOS

    % Guardar SOC de cada hora
    SOC_historial(t) = SOC;

    % Guardar balance energetico
    balance_historial(t) = balance;

    % ETAPA 6: REPORTE POR CONSOLA

    % Mostrar separador
    fprintf('\n-----------------------------\n');

    % Mostrar hora de simulacion
    fprintf('HORA: %d\n',t);

    % Mostrar estado energetico
    fprintf('ESTADO: %s\n',estado);

    % Mostrar generacion total
    fprintf('Generacion: %.2f kW\n',Egen(t));

    % Mostrar demanda total
    fprintf('Demanda: %.2f kW\n',Edem(t));

    % Mostrar balance de potencia
    fprintf('Balance: %.2f kW\n',balance);

    % Mostrar estado de carga
    fprintf('SOC bateria: %.2f %%\n',SOC);

    % Mostrar estado de la escuela
    fprintf('Escuela: %s\n',escuela);

    % Mostrar estado del bombeo
    fprintf('Bombeo: %s\n',bombeo);

    % Mostrar estado del alumbrado
    fprintf('Alumbrado: %s\n',alumbrado);

end

% ETAPA 7: FINALIZACION

% Mostrar finalizacion
fprintf('\n SIMULACION FINALIZADA\n');

% Mostrar SOC final
fprintf('SOC final: %.2f %%\n',SOC);

% ETAPA 8: GRAFICAS DE RESULTADOS

% Crear vector de horas
horas = 1:24;

% Crear ventana de graficas
figure;

% Primera grafica: generacion y demanda
subplot(2,1,1);

% Graficar generacion hibrida
plot(horas,Egen,'b-o','LineWidth',1.5);

% Mantener grafica
hold on;

% Graficar demanda energetica
plot(horas,Edem,'r-s','LineWidth',1.5);

% Agregar titulo
title('Generacion hibrida y demanda');

% Etiqueta horizontal
xlabel('Hora');

% Etiqueta vertical
ylabel('Potencia (kW)');

% Agregar leyenda
legend('Generacion','Demanda');

% Activar cuadricula
grid on;

% Segunda grafica: estado de bateria
subplot(2,1,2);

% Graficar SOC durante 24 horas
plot(horas,SOC_historial,'k-o','LineWidth',1.5);

% Mantener grafica
hold on;

% Mostrar umbral de alerta
yline(40,'--','Umbral de alerta 40%');

% Mostrar umbral de emergencia
yline(20,'--','Umbral de emergencia 20%');

% Agregar titulo
title('Estado de carga de la bateria');

% Etiqueta horizontal
xlabel('Hora');

% Etiqueta vertical
ylabel('SOC (%)');

% Establecer limites del SOC
ylim([0 100]);

% Activar cuadricula
grid on;
