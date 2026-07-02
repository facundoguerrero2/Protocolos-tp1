 
 /* Debemos checkear que cae el clock y el diseño queda estático
  para eso la logica sera parar el clock, y checkear que el valor del led no cambia.
  ademas debemos checkear que cuando se reactiva el clock, el led sigue shifteando.
  para eso la logica sera iterar una comparacion PREV_CHECKS veces, 
  si uno es igual al anterior se resta 1 a la variable
  si llega a 0, significa que PREV_CHECKS veces el led no cambio, por lo tanto fallo el test.
  Lo de PREV_CHECKS es porque al probarse cada tiempo random podria caer el mismo valor de shifteo que antes
  pero si pasa 100 veces ya significa que hay una falla*/

  localparam PREV_CHECKS = 100;

  reg [N_LED      - 1 : 0] prev_o_led    ; //para guardar el estado del contador para poder checkear si cambio o no en el tiempo que el contador esta deshabilitado

  integer equal_counter = PREV_CHECKS; //variable para checkear que el contador cambio despues de reactivar el clock
  
  integer i=0; //para bucle
  integer j=0; //para bucle
  

 

  reg [7:0] iter_dbg;
  initial
  begin

    clock_en = 1'b1; // habilitamos clock
    
    //modificamos los limites del contador para que sean mas rapidos y podamos testearlo en menos tiempo
    force u_top_leds.u_counter.limit_0   = 32'h0000_0010;
    force u_top_leds.u_counter.limit_1   = 32'h0000_0020;
    force u_top_leds.u_counter.limit_2   = 32'h0000_0040;
    force u_top_leds.u_counter.limit_3   = 32'h0000_0080;

    //----> Corremos el test por 100 iteraciones
    for(i=0; i<100; i=i+1)
    begin
      iter_dbg = i;
      //----> Inicializamos las variables
      i_sw[0]       = 'd0;
      i_sw[2:1]     = $urandom_range(0,3); // randomizamos los switches 1,2 para que el contador seleccione distintos limites de cuenta 
      i_sw[3]   = $urandom_range(0,1);
            
      prev_o_led    = 'd0;

      //----> Reset
      reset();

      //----> Habilitamos el contador
      i_sw[0] = 'd1;

      //----> Esperamos un momento random
      #($urandom_range(50,500) * 1ns); // 1000 es 1us

      //----> Deshabilitamos el clock y guardamos el valor del contador en ese instante.
      clock_en = 1'b0; 
      prev_o_led  = o_led ; 

      //----> Esperamos un momento random.
      #($urandom_range(50,500) * 1ns);

      //----> Checkeamos si los valores son iguales, deberian serlo ya que el clock esta deshabilitado.
    
      for(j=0; j<50; j=j+1)
      begin
        #($urandom_range(50,500) * 1ns); // esperamos 10ns entre cada checkeo, no es necesario esperar al clock porque el clock esta deshabilitado, pero lo hacemos para simular el paso del tiempo.
        if(prev_o_led != o_led) 
        begin
          $display("ERROR: El valor del led cambio.");
          $display("TEST FAILED");
          $finish(2);
        end 
      end

      //----> Reactivamos el clock y checkeamos que el contador sigue funcionando normalmente.
      clock_en = 1'b1;
      @(posedge clock); 
      
      //iteramos PREV_CHECKS (100) VECES, esperamos un momento random y comparamos
      for(j=0; j<PREV_CHECKS; j=j+1)
      begin
        #($urandom_range(50,500) * 1ns); // esperamos un momento random 
        if(prev_o_led == o_led)
          equal_counter = equal_counter - 1;
      end

      if(equal_counter == 0) //si entramos significa que cayo igual al valor previo 100 veces, por lo tanto nunca cambio, fallo el test.
      begin
        $display("ERROR: El led no cambio despues de reactivar el clock.");
        $display("TEST FAILED");
        $finish(2);
      end
      else
        equal_counter = PREV_CHECKS; // reseteamos el contador de iguales para la siguiente iteracion

    end

    $display("TEST PASSED");
    $finish();
  end
