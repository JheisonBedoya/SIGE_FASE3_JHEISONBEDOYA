

% ==========================================================
% RETO 3 - SISTEMA INTELIGENTE DE GESTION ENERGETICA (SIGE)
% PASO 2: PROGRAMACION Y SIMULACION EN MATLAB
% CONTROL AUTOMATICO DE MICRO-RED DURANTE 24 HORAS
% ==========================================================

% ETAPA 1: CONFIGURACION INICIAL

clc;                          % Limpiar ventana de comandos
clear;                        % Limpiar variables anteriores
close all;                    % Cerrar ventanas graficas

% Definir vector de generacion solar en kW
solar = [0 0 0 0 0 2 5 9 13 17 21 25 ...
         23 20 17 13 9 5 2 0 0 0 0 0];

% Definir vector de generacion eolica en kW
eolica = [7 9 6 11 8 10 12 9 7 13 11 8 ...
          10 14 12 9 11 7 10 13 8 6 9 7];

% Definir vector de demanda total en kW
demanda = [3 3 2 4 3 7 7 8 8 9 9 10 ...
           9 8 8 9 10 15 15 15 15 4 3 3];

% Calcular generacion hibrida total
Egen = solar + eolica;

% Definir demanda energetica total
Edem = demanda;

% Definir capacidad de la bateria en kWh
Capacidadbat = 100;

% Definir estado inicial de carga
SOC = 50;

% Definir duracion del intervalo en horas
dt = 1;

% Definir numero total de horas
N = 24;

% ETAPA 2: CREACION DE VECTORES DE RESULTADOS

% Crear vector para almacenar SOC
SOC_historial = zeros(N,1);

% Crear vector para almacenar balance energetico
balance_historial = zeros(N,1);

% Crear vector para almacenar energia excedente
Excedente_historial = zeros(N,1);

% Crear vector para almacenar energia faltante
Faltante_historial = zeros(N,1);

% Crear vector para almacenar estado energetico
Estado_Energetico = strings(N,1);

% Crear vector para almacenar estado de escuela
Estado_Escuela = strings(N,1);

% Crear vector para almacenar estado de bombeo
Estado_Bombeo = strings(N,1);

% Crear vector para almacenar estado de alumbrado
Estado_Alumbrado = strings(N,1);

% ETAPA 3: INICIO DE SIMULACION

% Mostrar encabezado del sistema
fprintf('\n========================================\n');
fprintf(' SISTEMA INTELIGENTE DE GESTION ENERGETICA\n');
fprintf(' SIMULACION DE MICRO-RED - 24 HORAS\n');
fprintf('========================================\n');

% Iniciar ciclo de 24 horas
for t = 1:N

    % Calcular balance de potencia de la hora
    balance = Egen(t) - Edem(t);

    % Calcular energia del intervalo en kWh
    energia_balance = balance * dt;

    % Inicializar servicios activos
    escuela = 'ACTIVA';
    bombeo = 'ACTIVO';
    alumbrado = 'ACTIVO';

    % Inicializar excedente y faltante
    excedente = 0;
    faltante = 0;

    % ETAPA 4: LOGICA DE CONTROL

    % Verificar si existe superavit energetico
    if balance >= 0

        % Calcular energia excedente
        excedente = energia_balance;

        % Actualizar estado de carga
        SOC = SOC + (excedente/Capacidadbat)*100;

        % Evitar sobrecarga de bateria
        SOC = min(SOC,100);

        % Registrar condicion energetica
        estado = 'SUPERAVIT';

    else

        % Calcular energia faltante
        faltante = abs(energia_balance);

        % Descargar energia de bateria
        SOC = SOC - (faltante/Capacidadbat)*100;

        % Evitar descarga inferior a cero
        SOC = max(SOC,0);

        % Registrar condicion energetica
        estado = 'DEFICIT';

        % ETAPA 5: DESCONEXION DE CARGAS

        % Ruta segura: SOC mayor al 40%
        if SOC > 40

            % Mantener todos los servicios activos
            escuela = 'ACTIVA';
            bombeo = 'ACTIVO';
            alumbrado = 'ACTIVO';

        % Ruta de alerta: SOC mayor al 20%
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

    % ETAPA 6: ALMACENAMIENTO DE RESULTADOS

    % Guardar estado de carga de bateria
    SOC_historial(t) = SOC;

    % Guardar balance energetico
    balance_historial(t) = balance;

    % Guardar energia excedente
    Excedente_historial(t) = excedente;

    % Guardar energia faltante
    Faltante_historial(t) = faltante;

    % Guardar estado energetico
    Estado_Energetico(t) = string(estado);

    % Guardar estado de escuela
    Estado_Escuela(t) = string(escuela);

    % Guardar estado de bombeo
    Estado_Bombeo(t) = string(bombeo);

    % Guardar estado de alumbrado
    Estado_Alumbrado(t) = string(alumbrado);

    % ETAPA 7: REPORTE POR CONSOLA

    % Mostrar separador
    fprintf('\n-----------------------------------\n');

    % Mostrar hora actual
    fprintf('HORA: %d\n',t);

    % Mostrar condicion energetica
    fprintf('ESTADO: %s\n',estado);

    % Mostrar generacion solar
    fprintf('Generacion solar: %.2f kW\n',solar(t));

    % Mostrar generacion eolica
    fprintf('Generacion eolica: %.2f kW\n',eolica(t));

    % Mostrar generacion hibrida
    fprintf('Generacion total: %.2f kW\n',Egen(t));

    % Mostrar demanda energetica
    fprintf('Demanda total: %.2f kW\n',Edem(t));

    % Mostrar balance energetico
    fprintf('Balance: %.2f kW\n',balance);

    % Mostrar excedente energetico
    fprintf('Excedente: %.2f kWh\n',excedente);

    % Mostrar faltante energetico
    fprintf('Faltante: %.2f kWh\n',faltante);

    % Mostrar SOC de bateria
    fprintf('SOC bateria: %.2f %%\n',SOC);

    % Mostrar estado de escuela
    fprintf('Escuela rural: %s\n',escuela);

    % Mostrar estado de bombeo
    fprintf('Bombeo agricola: %s\n',bombeo);

    % Mostrar estado de alumbrado
    fprintf('Alumbrado publico: %s\n',alumbrado);

end

% ETAPA 8: CREACION DE TABLA GENERAL

% Crear vector de horas
Hora = (1:N)';

% Organizar generacion solar
Generacion_Solar = solar(:);

% Organizar generacion eolica
Generacion_Eolica = eolica(:);

% Organizar generacion total
Generacion_Total = Egen(:);

% Organizar demanda total
Demanda_Total = Edem(:);

% Organizar balance energetico
Balance_Energetico = balance_historial;

% Organizar excedente energetico
Energia_Excedente = Excedente_historial;

% Organizar faltante energetico
Energia_Faltante = Faltante_historial;

% Organizar SOC de bateria
SOC_Bateria = SOC_historial;

% Crear tabla completa con resultados
Tabla_SIGE = table(Hora, Generacion_Solar, ...
    Generacion_Eolica, Generacion_Total, ...
    Demanda_Total, Balance_Energetico, ...
    Energia_Excedente, Energia_Faltante, ...
    SOC_Bateria, Estado_Energetico, ...
    Estado_Escuela, Estado_Bombeo, ...
    Estado_Alumbrado);

% Mostrar encabezado de tabla
fprintf('\n========================================\n');
fprintf(' TABLA GENERAL DE RESULTADOS DEL SIGE\n');
fprintf('========================================\n');

% Mostrar tabla en ventana de comandos
disp(Tabla_SIGE);

% ETAPA 9: EXPORTACION A EXCEL

% Definir nombre del archivo Excel
nombre_archivo = 'Resultados_SIGE.xlsx';

% Exportar tabla completa a Excel
writetable(Tabla_SIGE,nombre_archivo);

% Mostrar confirmacion de exportacion
fprintf('\nArchivo Excel generado correctamente.\n');
fprintf('Nombre: %s\n',nombre_archivo);

% ETAPA 10: VISUALIZACION GRAFICA

% Crear vector de horas
horas = 1:N;

% Crear ventana de graficas
figure;

% GRAFICA 1: GENERACION Y DEMANDA

% Crear primera grafica
subplot(2,1,1);

% Graficar generacion hibrida
plot(horas,Egen,'b-o','LineWidth',1.5);

% Mantener grafica activa
hold on;

% Graficar demanda de comunidad
plot(horas,Edem,'r-s','LineWidth',1.5);

% Agregar titulo
title('Generacion hibrida y demanda energetica');

% Etiqueta eje horizontal
xlabel('Hora');

% Etiqueta eje vertical
ylabel('Potencia (kW)');

% Agregar leyenda
legend('Generacion hibrida','Demanda');

% Activar cuadricula
grid on;

% GRAFICA 2: ESTADO DE CARGA

% Crear segunda grafica
subplot(2,1,2);

% Graficar SOC
plot(horas,SOC_historial,'k-o','LineWidth',1.5);

% Mantener grafica activa
hold on;

% Dibujar umbral de alerta
yline(40,'--','Umbral de alerta 40%');

% Dibujar umbral de emergencia
yline(20,'--','Umbral de emergencia 20%');

% Agregar titulo
title('Evolucion del estado de carga de bateria');

% Etiqueta eje horizontal
xlabel('Hora');

% Etiqueta eje vertical
ylabel('SOC (%)');

% Limitar eje vertical
ylim([0 100]);

% Activar cuadricula
grid on;

% ETAPA 11: RESUMEN FINAL

% Mostrar separador
fprintf('\n========================================\n');

% Mostrar finalizacion de simulacion
fprintf(' SIMULACION FINALIZADA\n');

% Mostrar SOC final
fprintf('SOC final de bateria: %.2f %%\n',SOC);

% Mostrar total de horas simuladas
fprintf('Total de horas simuladas: %d\n',N);

% Mostrar mensaje final
fprintf('Resultados almacenados en Excel.\n');

% Mostrar separador final
fprintf('========================================\n');
