%{

   -----------Distribucion termica del dinero en una sociedad v3.0------------
   --------------------Ricardo L�pez Rodr�guez A01066515---------------------------  
   
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
    entropyAnimation = false;
    objetivos = false ; %Calcular y graficar las funciones objetivo
    option = input("Distribucion inicial --- >   1. Delta    2. Uniforme");
    deltaMs = input("Ingresa un vector con las deltaM a visualizar");   % deltaM --> 0.05,0.5,0.8,1
    N = 1000; %500; %Numero de agentes
    M = 1000000;%2660500;%1000000;%5e5 ;%1000000 ; %5e4; %Cantidad total de dinero 1000000
    m = zeros(1,N);
    tMax = 30000;%1e5 ; %300000;%800000;% 50000 ; %10000;  % Numero maximo de iteraciones 100
    t_c = tMax - 5;
   
    te = 1 ;
%.............Detserminacion del total de clases......................
    totalClasses = 50;
    
    disp("Clases = " + totalClasses);    
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
   
    % Valores promedio de maximo y minimo despu�s de haber corrido varios
    %experimentos (Ayudan a fijar las clases)
    maxVal = 5322; %6000
    minVal = 1;    
    W = (maxVal - minVal)/totalClasses ;
    edgesMoney = 0:W:maxVal;
    
    centers = 0.5* (edgesMoney(1:end - 1) + edgesMoney(2:end));   % valor central
  
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
      %................................Objetivo...............................
            a  = .0000000000000000001;
            m_c = 1/a ;                     %Dinero que se necesita para estar bien
            disp("m_c = "+ m_c);
            suma_2 = 0;
            
            for k = 1 : totalClasses     
                n = Bins(k);
                obje2 = 1 - exp(-centers(k)/m_c);                        
                suma_2 = suma_2 + n * obje2;
            end
            
            objectivo_2(tRel_2) = suma_2;
            tRel_2 = tRel_2 + 1;
             
      %................Calculando las funciones objetivo...................
      %...........Considerando valores centrales para el dinero M_k........
            if objetivos == true   
                
                    sumatoria_1 = 0;
                    suma_2 = 0;            
                    a = 1;
                    % Calculando el dinero por clase M_k
% 
%                     for r = 1 : N                             % recorriendo cada agenete para sumar su dinero a la clase que pertenece
%                         dinero = m(r);
%                         [bin, ~] = histcounts(dinero,edgesMoney);
%                         indexBin = find(bin ~= 0);                  % Clase donde se encuentra clasificado el dinero
%                         Money(indexBin) = Money(indexBin) + dinero; % Dinero acumulado por clase
%                     end            
                    % Armando las funciones objetivo ....
                    obj_1 = a * edgesMoney(2:end);
                    obje2 = 1 - exp(-a.*edgesMoney(2:end));
                    
                    for k = 1 : totalClasses     
                        n = Bins(k);
    %                     obj_1 = a* Money(k);
    %                     obje2 = 1 - exp(-a*Money(k));                        
                        sumatoria_1 = sumatoria_1 + n*obj_1(k) ;
                        suma_2 = suma_2 + n*obje2(k);
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
    
    
    
    
    
    
    %Prueba .....
        T = 0 : 1 : size(objectivo_2,2) - 1;
        figure(30)
        plot(T,objectivo_2,'LineWidth', 1.5, "Color", 'r')
        axis auto
        grid on
        %ylim([0,4600])
        %xlim([0, 250000]
        title("Objetivo")
        xlabel("\textbf{t}")
        ylabel("\textbf{O}")
  
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
    showEntropy(entropy,deltaMs,entropyAnimation);
    showLogarithmicHistogram(histValues);
    
    
end
    

%Graficando la entropia
function showEntropy(matrix,deltaMs,entropyAnimation)

    for i = 1 : length(deltaMs)
        entropy = matrix(i,:);
        time = 0:1:size(entropy,2)-1;

        figure(3)
        plot(time,entropy(1,:),'LineWidth', 1.5, "Color", 'b')
        axis auto
        grid on
        %ylim([0,4600])
        %xlim([0, 250000])
        xlim([0,15000]);
        ylim([0,3500]);
        title("Entropia")
        xlabel("\textbf{t}")
        ylabel("\textbf{S}")
        %legend("\Delta m = 0.05", "\Delta m = 0.1", "\Delta m = 0.3","\Delta m = 0.5")
       % legend("Distribuci�n inicial M/N", "Distribuci�n inicial uniforme")
        hold on %.05
    end

   if entropyAnimation == true
        % Animation
        figure(8)
        an = animatedline;
        an.Color = "b";
        an.LineWidth = 2;
        axis([0,15000,0,3500])
        xlabel("\textbf{t}")
        ylabel("\textbf{S}")
        grid on

        for k = 1 : length(time)
            addpoints(an,time(k),entropy(k))
            title("Entropia en t = "+ k);
            drawnow        
        end
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


%{

    Valor esperado de la funcion del bienestar colectivo 


%}

close all
clear all
N = 1000;
M = 1000;
m_promedio = 1: 10 : 10000;
m_c = m_promedio;
[M_promedio, M_c] = meshgrid(m_promedio,m_c);
alpha = M_promedio./M_c ;
O_esp = zeros(length(m_c));
t = 1 : 100;

for i = 1 : length(m_promedio)
    
    for j = 1 : length(m_c)
           
        o_1 = 1 - exp(-alpha(i,j).*t);
       
        o_1_promedio = sum(o_1(end-(end-20):end))/length(o_1(end-(end-20):end));
        
        O_esp(i,j) = o_1_promedio;
               
    end   
    
end


for k = 1 : 5
    
    figure(2)
    plot(alpha(k,:),O_esp(k,:));
    hold on   
    
end