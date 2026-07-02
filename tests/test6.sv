
  /*Debemos poner a andar el circuito, verificar que este funicionando,
  resetear y verificar que estan los valores en 0, luego habilitar y verificar que el contador sigue funcionando normalmente.*/
  integer i=0;
  reg [N_LED - 1 : 0] prev_o_led    ; 
  reg [31:0] current_limit;
  
  reg flag_fail = 0; 

always@(*) begin
    case(i_sw[2:1])
      2'b00: current_limit = u_top_leds.u_counter.limit_0;
      2'b01: current_limit = u_top_leds.u_counter.limit_1;
      2'b10: current_limit = u_top_leds.u_counter.limit_2;
      2'b11: current_limit = u_top_leds.u_counter.limit_3;
    endcase
  end

  initial
  begin

    //modificamos los limites del contador para que sean mas rapidos
    clock_en = 1'b1; 
    force u_top_leds.u_counter.limit_0   = 32'h0000_0010;
    force u_top_leds.u_counter.limit_1   = 32'h0000_0020;
    force u_top_leds.u_counter.limit_2   = 32'h0000_0040;
    force u_top_leds.u_counter.limit_3   = 32'h0000_0080;

    //----> Corremos el test por 100 iteraciones
    for(i=0; i<100; i=i+1)
    begin
      //----> Inicializamos variables
      i_sw[0]   = 1'b0; // Deshabilitado
      i_sw[2:1] = $urandom_range(0,3);
      i_sw[3]   = $urandom_range(0,1);

      //----> Reset
      reset();

      //----> habilitamos
      i_sw[0] = 1'b1;
      prev_o_led = o_led;

      //----> esperamos a que cambie el patron de leds una vez para asegurar que esta corriendo
      fork
        begin
          @(o_led);
        end
        begin
          //esperamos un tiempo mayor al limite maximo para que el led cambie para que no se trabe el test si el contador no esta funcionando correctamente
          #((u_top_leds.u_counter.limit_3 + 20) * PERIODO_CLK  ); 
          flag_fail = 1; //si pasa este tiempo y no cambio el led, significa que el contador no esta funcionando correctamente
        end
      join_any 
      disable fork;
      
      if(flag_fail == 1)
      begin
        $display("ERROR: El valor del led NO cambio, quedo congelado.");
        $display("TEST FAILED");
        $finish(2);
      end

      //----> verificamos los valores que sean distintos a los de reset
      if (prev_o_led == o_led)
      begin
        $display("TEST FAILED: El valor del led es el mismo al estado previo pese a haber esperado un flanco en la señal");
        $finish(2);
      end

      #($urandom_range(50,500) * 1ns); // Esperamos un momento random

      reset();

      if( o_led != 4'b1000 || u_top_leds.u_counter.counter != 32'b0)
      begin
        $display("TEST FAILED: Los valores no estan en 0 después del reset");
        $finish(2);
      end

      // --> habilitamos nuevamente
      i_sw[0] = 1'b1;

      #($urandom_range(50,500) * 1ns); // Esperamos un momento random
      prev_o_led = o_led;

      #((current_limit + current_limit/2) * PERIODO_CLK); //esperamos el tiempo suficiente para que cambie el led

      if (prev_o_led == o_led)
      begin
        $display("TEST FAILED: Los valores no cambiaron después de habilitar y esperar un tiempo random");
        $finish(2);
      end
    end

    $display("TEST PASSED");
    $finish();
  end



