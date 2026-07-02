/*
TEST3 resetamos y vamos seteando cada uno de los limites uno por uno, para cada uno medimos el tiempo que tarda en shiftear el led 
(cuanto tarda en contar de 0 al limite) 
deberian ser distintos, y deberian ser aproximadamente el doble del anterior, ya que los limites son el doble de cada uno.
Ademas lo comparamos con un modelo ideal, si en algun momento no coinciden, se termina la simulacion y da error.
*/
  
  reg [N_LED      - 1 : 0] prev_o_led    ; //para guardar el estado del led para poder ver cuando cambia para medir cant de ciclos de clock
  
  integer clock_counter = 0; //almacenara los ciclos de ciclos de clock
  integer valor_esperado = 0; //ciclos esperados para cada limite de cuenta.

  integer i=0; //para bucle
  integer j=0; //para bucle
  

  reg [NB_COUNTER - 1 : 0 ] current_limit;
  wire [N_LED - 1 : 0] leds_modelo;
  modelo_ideal #(
    .N_LEDS(N_LED),
    .NB_COUNTER(NB_COUNTER)
  ) u_modelo_ideal (
    .clock(clock),
    .i_reset(i_reset),
    .i_enable(i_sw[0]),
    .limit(current_limit),
    .leds_modelo(leds_modelo)
  );

  // --> Estamos paralelamente comparando el modelo con el diseño, si en algun momento no coinciden, se termina la simulacion y da error.
  always @(negedge clock) begin
    if (i_reset == 1'b1 && i_sw[0] == 1'b1) begin 
      if (leds_modelo !== o_led) begin
        $display("ERROR: El modelo y el diseño no coinciden.");
        $display("TEST FAILED");
        $finish(2);
      end
    end
  end


  //comprobamos que el contador cuente correctamente hasta el limite, para cada uno de los limites de cuenta, deberia tardar aproximadamente el doble que el anterior.
  initial
  begin
    
    //modificamos los limites del contador para que sean mas rapidos y podamos testearlo en menos tiempo  
    force u_top_leds.u_counter.limit_0   = 32'h0000_0010;
    force u_top_leds.u_counter.limit_1   = 32'h0000_0020;
    force u_top_leds.u_counter.limit_2   = 32'h0000_0040;
    force u_top_leds.u_counter.limit_3   = 32'h0000_0080;

    clock_en = 1'b1; // habilitamos el clock 


    //----> Corremos el test por 100 iteraciones
      
    for(i=0; i<100; i=i+1)
    begin
      
      //----> Inicializamos las variables

      clock_counter = 0;  //reseteamos el contador de ciclos de clock para la siguiente iteracion
      i_sw[2:1] =     0;  //arrancamos por el limite 0 
      i_sw[0]       = 'd0; 
      i_sw[3]   = $urandom_range(0,1);
      
      // ----> iteramos 4 veces, una por cada limite de cuenta
      for(j=0; j<4; j=j+1) 
      begin
        
        i_sw[2:1] = j; //seteamos el limite de cuenta a testear
        case(i_sw[2:1]) //dependiendo del limite de cuenta seleccionado, el valor esperado es distinto, ya que los limites son el doble de cada uno
            2'b00: begin
              current_limit = u_top_leds.u_counter.limit_0;
              valor_esperado = 17;
            end
            2'b01: begin
              current_limit = u_top_leds.u_counter.limit_1;
              valor_esperado = 33;
            end
            2'b10: begin
              current_limit = u_top_leds.u_counter.limit_2;
              valor_esperado = 65;
            end
            2'b11: begin
              current_limit = u_top_leds.u_counter.limit_3;
              valor_esperado = 129;
            end
        endcase

        reset();
        i_sw[0] = 'd1;

        //esperamos a un shift del led para empezar a contar los ciclos de clock que tarda en llegar al limite
        @(o_led);
        prev_o_led = o_led;

        // ----> empezamos a contar ahora cuantos ciclos le toma llegar al limite
        forever begin //mientras el valor del led no cambie, seguimos sumando 1 al contador de ciclos
          @(posedge clock);
          #1;
          clock_counter = clock_counter + 1; //contamos cuantos ciclos de clock pasaron hasta que cambio el led
          if(o_led !== prev_o_led) break;
        end

        if(clock_counter != valor_esperado) //comparamos el valor del contador con el valor esperado, deberian ser iguales
        begin
          $display("ERROR: El valor del contador no es el esperado.");
          $display("TEST FAILED");
          $finish(2);
        end
        else
          clock_counter = 0; //reseteamos el contador de ciclos de clock para la siguiente iteracion
   
      end

    end
    $display("TEST PASSED");
    $finish();
  end
