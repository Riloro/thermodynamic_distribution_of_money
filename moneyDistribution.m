%{

   -----------Distribucion termica del dinero en una sociedad v3.0------------
   --------------------Ricardo López Rodríguez A01066515---------------------------  
   
    El siguiente codigo simula transacciones entre una sociedad de N
    agentes, la reestriccion del sistema es la consevarcion del dinero M.
    La simulacion muestra como sin importar la distribucion inicial del
    dinero la distribucion final siempre sera una exponencial negativa, la
    cual maximiza la entropia 
%}


function moneyDistribution()

    close all
    clear all
    set(0,'defaultTextInterpreter','latex');
    
    animacion = false;
    objetivos = false ; %Calcular y graficar las funciones objetivo
    option = input("Distribucion inicial --- >   1. Delta    2. Uniforme");
    deltaMs = input("Ingresa un vector con las deltaM a visualizar");   % deltaM --> 0.05,0.5,0.8,1
    N = 1000; %500; %Numero de agentes
    M = 2660500;%1000000;%5e5 ;%1000000 ; %5e4; %Cantidad total de dinero 1000000
    m = zeros(1,N);
    tMax = 1e5 ; %300000;%800000;% 50000 ; %10000;  % Numero maximo de iteraciones 100
    t_c = tMax - 50;
   
    
%.............Detserminacion del total de clases......................
    totalClasses = 50;
    disp("Calses = " + totalClasses);    
    range = M/totalClasses;
    
    
%.............Generando las clases...........................
    classes = zeros(totalClasses + 1,2);

    value = range - 1;
    classes(1,1) = 0 ;
    classes(1,2) =  value;

    for i = 2 : totalClasses + 1 

        prevVal = value;             
        classes(i,1) = prevVal + 1;
        value = (range * i) - 1 ;
        classes(i,2) = value;              

    end          
   
    % Valores promedio de maximo y minimo después de haber corrido varios
    %experimentos (Ayudan a fijar las clases)
    maxVal = 5322; %6000
    minVal = 1;    
    W = (maxVal - minVal)/totalClasses ;
    edgesMoney = 0:W:maxVal;
    
    centers = 0.5* (edgesMoney(1:end - 1) + edgesMoney(2:end));   % valor central
    supLim = edgesMoney(2:end);
    infLim = edgesMoney(1:end - 1);
    Money = zeros(1,totalClasses);
    
    for contador = 1 : length(deltaMs)
        
        switch option
            case 1
                m(1,:) = M/N; %Distribucion incial dada del dinero
            case 2             
                % Contruyendo una distribucion uniforme ....
                c = totalClasses;  
                nm=ones(c,N/c);
                x= 0:W/2:maxVal;
                
                for k = 1:c
                    nm(k,:) = nm(k,:)*x(2*k);
                end
                
                m = nm(1,:);
                for i = 2 : c 
                    m = [m , nm(i,:)];
                end
              
            otherwise
                disp("Distribucion inicial no elegida :(")        
        end
        
        tRel = 1;  
        tRel_2 = 1;
        
        for t = 1 : tMax
            
            f = [1,-1];
            s = f(randi([1,2]));    % variable aleatoria que toma los valores +1 o -1    
            l = randi([1,N]);       % Agente aleatorio L

            % Interaciones entre los N agentes...
            for k = 1 : N            

                % En caso de que l = k se genera un nuevo numero aleatorio l
                while l == k
                    l = randi([1,N]); 
                end    

    % -------Interaccion entre el agente k  y l-----------% 

                kMoney = m(k) + deltaMs(contador) * s;
                lMoney = m(l) - deltaMs(contador) * s;    

                %Los agentes no pueden contraer deuda......            
                if kMoney > 0 && lMoney > 0    
                    m(k) = kMoney;
                    m(l) = lMoney;
                end      
            end

     %.............Calculando la entropia  para cada tiempo t..............
             [Bins,~] = histcounts(m,edgesMoney);
             suma = 0;
             for i = 1 : totalClasses
                 if Bins(i) > 0
                    suma = suma + Bins(i) * log(Bins(i));
                 end
             end
             entropy(contador,tRel) = N*log(N) - suma;    % Entropia de la distribucion
             tRel = tRel + 1;     
             
             entropy(contador,1) = 0;
      %................Calculando las funciones objetivo...................
      %...........Considerando valores centrales para el dinero M_k........
            if objetivos == true   
                
                    sumatoria_1 = 0;
                    suma_2 = 0;            
                    a = 1;
                    % Calculando el dinero por clase M_k

                    for r = 1 : N                             % recorriendo cada agenete para sumar su dinero a la clase que pertenece
                        dinero = m(r);
                        [bin, ~] = histcounts(dinero,edgesMoney);
                        indexBin = find(bin ~= 0);                  % Clase donde se encuentra clasificado el dinero
                        Money(indexBin) = Money(indexBin) + dinero; % Dinero acumulado por clase
                    end            
                    % Armando las funciones objetivo ....
                    for k = 1 : totalClasses          

                        n = Bins(k);
                        obj_1 = a* Money(k);
                        obje2 = 1 - exp(-a*Money(k));

                        sumatoria_1 = sumatoria_1 + n*obj_1 ;
                        suma_2 = suma_2 + n*obje2;
                    end

                    objective_1(tRel_2) = sumatoria_1;
                    objectivo_2(tRel_2) = suma_2;
                    tRel_2 = tRel_2 + 1;
            end
            %Buscando el minimo y maximo de nuestros datos cuando t =30 para
            %generar obtener el ancho de nuestras clases

            if t == t_c
                w = (max(m) - min(m))/totalClasses ;
                maximum = ceil(max(m));
                width = ceil(w);
    %             edges = 0:width:maximum;
    %             hist = histogram(m,edges);
                disp("mMax ="+ max(m));
                disp("mMin = "+ min(m));
            end

            if t > t_c

                figure(1)
                h = histogram(m,edgesMoney);
                %h.NumBins = totalClasses;            
                h. BinWidth = W;
                %h.BinLimits = [0,maximum]; 
                histValues = h.Values;
                h.FaceColor = "#99d066";
                h.EdgeColor = [0,0,0];
                xlabel("Dinero")
                ylabel("Numero de personas")
                %ylim([0,210])
                xlim([0,7000])
                title("Distribucion termodinamica del dinero t =" + t)  
                legend("\Delta m = " + deltaMs(contador))
                if animacion == true
                    pause(.01)  ;       % "Animacion" :)
                end
            end
        end    
    end
  
    if objetivos == true 
        T = 0:1:size(objective_1,2) - 1;

        figure(5)
        plot(T,objective_1,'Color','b','LineWidth', 1.1)
        axis auto
        grid on
    %     ylim([0,4000])
    %     xlim([0, 5e4])
        title("Funcion objetivo con  o(M) = aM")
        xlabel("\textbf{t}")
        ylabel("\textbf{O(n,...,c)}")


        T_2 = 0:1:size(objectivo_2,2) - 1;

        figure(6)
        plot(T_2,objectivo_2,'Color','b','LineWidth', 1.2)
        axis auto
        grid on
    %     ylim([0,4000])
    %     xlim([0, 5e4])
        title("Funcion objetivo con  o(M) = 1 - exp(-aM)")
        xlabel("\textbf{t}")
        ylabel("\textbf{O(n,...,c)}")
        ylim([0,1005])
    end
    showEntropy(entropy,deltaMs);
    showLogarithmicHistogram(histValues);
    
end
    

%Graficando la entropia
function showEntropy(matrix,deltaMs)

    for i = 1 : length(deltaMs)
        entropy = matrix(i,:);
        time = 0:1:size(entropy,2)-1;
        disp("t len -> "+length(time));
        disp("s -> "+ length(entropy));

        figure(3)
        plot(time,entropy(1,:),'LineWidth', 1.1)
        axis auto
        grid on
        ylim([0,4600])
        xlim([0, 250000])
        title("Entropia")
        xlabel("\textbf{t}")
        ylabel("\textbf{S}")
        %legend("\Delta m = 0.05", "\Delta m = 0.1", "\Delta m = 0.3","\Delta m = 0.5")
       % legend("Distribución inicial M/N", "Distribución inicial uniforme")
        hold on %.05
    end


end



%Contruyendo el histograma ....
function showLogarithmicHistogram(values)
    
    histValues = log(values);
    figure(2)
    bar(histValues,'FaceColor',"#00897b" )%'#1e88e5');     
    title("Distribucion del dinero en una Sociedad")
    xlabel("Dinero");
    ylabel("Numero de personas en escala logaritmica"); 

end
