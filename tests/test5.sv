
  /*Debemos seleccionar un color del led, cambiarlo
  y ver que el anterior seleccionado no cambia y el nuevo seleccionado es == o_led (salida del led general)*/
  
  integer i=0;

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

      //----> esperamos a que cambie el patron de leds una vez para asegurar que esta corriendo
      @(o_led);

      //----> Verificamos que el color seleccionado coincide con o_led y el otro es 0
      if (i_sw[3] == 1'b0)
      begin
        // verde seleccionado
        if (o_led_g !== o_led || o_led_b !== 4'b0000) begin
          $display("ERROR: i_sw[3]=0 pero o_led_g != o_led o o_led_b != 0");
          $display("o_led: %b, o_led_g: %b, o_led_b: %b", o_led, o_led_g, o_led_b);
          $display("TEST FAILED");
          $finish(2);
        end
      end 
      else
       begin
        // azul seleccionado
        if (o_led_b !== o_led || o_led_g !== 4'b0000)
        begin
          $display("ERROR: i_sw[3]=1 pero o_led_b != o_led o o_led_g != 0");
          $display("o_led: %b, o_led_g: %b, o_led_b: %b", o_led, o_led_g, o_led_b);
          $display("TEST FAILED");
          $finish(2);
        end
      end

      //----> cambiamos la seleccion de color en tiempo real
      i_sw[3] = ~i_sw[3];

      //----> Esperamos a que o_led cambie de nuevo para ver que el nuevo seleccionado cambia y el otro no
      @(o_led);
      
      #($urandom_range(1,5) * 1000); // Esperamos un momento random 

      if (i_sw[3] == 1'b0)
      begin
        if (o_led_g !== o_led || o_led_b !== 4'b0000) 
        begin
          $display("ERROR dinámico: i_sw[3]=0 pero o_led_g != o_led o o_led_b != 0");
          $finish(2);
        end
      end
      else 
      begin
        if (o_led_b !== o_led || o_led_g !== 4'b0000) 
        begin
          $display("ERROR: i_sw[3]=1 pero o_led_b != o_led o o_led_g != 0");
          $finish(2);                       
        end
      end
    end

    $display("TEST PASSED");
    $finish();
  end
