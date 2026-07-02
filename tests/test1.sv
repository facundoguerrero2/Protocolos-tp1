

  reg [N_LED      - 1 : 0] prev_o_led    ; //para guardar el estado del led para poder checkear si cambio o no en el tiempo que el contador esta deshabilitado
  reg [NB_COUNTER - 1 : 0] clock_counter ;

  
  integer i=0;
  integer j=0;
  initial
  begin
    //modificamos los limites del contador para que sean mas rapidos y podamos testearlo en menos tiempo
    clock_en = 1'b1; // habilitamos el clock 
    force u_top_leds.u_counter.limit_0   = 32'h0000_0010;
    force u_top_leds.u_counter.limit_1   = 32'h0000_0020;
    force u_top_leds.u_counter.limit_2   = 32'h0000_0040;
    force u_top_leds.u_counter.limit_3   = 32'h0000_0080;

    //----> Corremos el test por 100 iteraciones
    
    
    for(i=0; i<100; i=i+1)
    begin

      //----> Inicializamos las variables
      i_sw[0]       = 'd0;
      i_sw[2:1]     = $urandom_range(0,7); // randomizamos los switches 1,2 para que el contador seleccione distintos limites de cuenta 
      i_sw[3]   = $urandom_range(0,1);
      prev_o_led    = 'd0;
      clock_counter = 'd0;

      //----> Reset
      reset();

      //----> Habilitamos el contador
      i_sw[0] = 'd1;

      //----> Esperamos un momento random
      #($urandom_range(1,5) * 1000);

      //----> Deshabilitamos el contador y guardamos el valor del led en ese instante.
      i_sw[0]     = 'd0   ;
      prev_o_led  = o_led ;

      //----> Esperamos un momento random.
      clock_counter = $urandom_range(50,500);

      //----> Checkeamos funcionamiento.
      // este for es para checkearlo clock_counter veces o sea un numero random de veces.
      for(j=0; j<clock_counter; j=j+1)
      begin
        @(posedge clock);
        if(prev_o_led != o_led) 
        begin
          $display("ERROR: El valor del led cambio.");
          $display("TEST FAILED");
          $finish(2);
        end 
      end
    end

    $display("TEST PASSED");
    $finish();
  end
