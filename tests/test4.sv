
  /*
  Debemos cambiar el limite de cuenta en runtime, y checkear que el contador no se quede congelado
  para eso seleccionamos un limite al azar, lo cambiamos al azar, esperamos el tiempo del limite + limite/2 y checkeamos que el led haya cambiado
  eso lo hacemos 50 veces, y si en alguna de esas 50 veces el led no cambio, significa que el contador se quedo congelado y el test falla.
  sabemos que no va a dar la vuelta porque el tiempo esperado es el limite de cuenta + limite/2, no le alcanza nunca para dar la vuelta
  a su vez, estamos comparando el modelo ideal con el diseño, si en algun momento no coinciden, se termina la simulacion y se da error. */

  reg [N_LED      - 1 : 0] prev_o_led    ; //para guardar el estado del led para poder checkear si cambio o no en el tiempo que el contador esta deshabilitado
  

  integer i=0;
  integer j=0;
  
  //--> instanciamos el modelo ideal

  reg  [NB_COUNTER - 1 : 0] current_limit;
  wire [N_LED      - 1 : 0] leds_modelo;
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


  //--> Current_limit sigue a i_sw[2:1] en tiempo real 
  always @(*) begin
    case(i_sw[2:1])
      2'b00: current_limit = u_top_leds.u_counter.limit_0;
      2'b01: current_limit = u_top_leds.u_counter.limit_1;
      2'b10: current_limit = u_top_leds.u_counter.limit_2;
      2'b11: current_limit = u_top_leds.u_counter.limit_3;
    endcase
  end

  // --> Estamos paralelamente comparando el modelo con el diseño, si en algun momento no coinciden, se termina la simulacion y se da error.
  always @(negedge clock) begin
    if (i_reset == 1'b1 && i_sw[0] == 1'b1) begin
      if (leds_modelo !== o_led) begin
        $display("ERROR: El modelo y el diseño no coinciden.");
        $display("TEST FAILED");
        $finish(2);
      end
    end
  end
  
  initial
  begin
    //modificamos los limites del contador para que sean mas rapidos y podamos testearlo en menos tiempo
    clock_en = 1'b1; // habilitamos el clock 
    force u_top_leds.u_counter.limit_0   = 32'h0000_0010; // 17 ciclos de clock
    force u_top_leds.u_counter.limit_1   = 32'h0000_0020;
    force u_top_leds.u_counter.limit_2   = 32'h0000_0040;
    force u_top_leds.u_counter.limit_3   = 32'h0000_0080; // 129 ciclos de clock es el maximo

    //----> Corremos el test por 100 iteraciones
    
    
    for(i=0; i<100; i=i+1)
    begin

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
      #($urandom_range(50,2000) * 1ns); //entre 50 y 1000 ns (entre 5 y 200 ciclos de clock) para que el contador pueda contar un poco antes de cambiar el limite de cuenta

      i_sw[2:1]     = $urandom_range(0,3);
      #1; 

      for(j=0; j<50; j=j+1)
      begin
        prev_o_led = o_led;
        repeat(current_limit + current_limit/2) @(posedge clock); //esperamos el tiempo del limite + limite/2 por las dudas, para asegurarnos que si o si debe cambiar el led una sola vez
        if(prev_o_led == o_led)
        begin
          $display("ERROR: El valor del led NO cambio, quedo congelado.");
          $display("TEST FAILED");
          $finish(2);
        end
      end
     

    
    end
    $display("TEST PASSED");
    $finish();
  end


