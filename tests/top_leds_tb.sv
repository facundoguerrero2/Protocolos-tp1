`default_nettype none
`timescale 1ns/1ns

module top_leds_tb();

  localparam N_SWITCH = 4 ;
  localparam N_LED    = 4 ;
  localparam PERIODO_CLK = 10;
  localparam NB_COUNTER = 32;

  wire [N_LED - 1 : 0] o_led  ;
  wire [N_LED - 1 : 0] o_led_b;
  wire [N_LED - 1 : 0] o_led_g;
  

  reg  [N_SWITCH - 1 : 0] i_sw;
  reg                     i_reset;
  reg                     clock;
  reg                     clock_en; //variable para TEST2 para poder testear que cuando el clock esta deshabilitado el contador no cambia su valor


  top_leds
  u_top_leds
  (
  //----> Output
    .o_led      (o_led),
    .o_led_b    (o_led_b),
    .o_led_g    (o_led_g),
  //----> Inputs
    .i_sw       (i_sw   ),
    .i_reset    (i_reset),
    .clock      (clock  )
  );


  //----> Generamos clock
  initial
  begin
    clock   <= 'd0;
  end
  always #(PERIODO_CLK/2) if(clock_en) clock = ~clock;


  //----> Task para el reset
  task reset ();
    time reset_time;
    begin
      //----> Reset en 0
      i_reset <= 'd0;

      //----> Randomizo duracion del reset
      reset_time = $urandom_range(1,100);
      #reset_time;

      //----> Levanto reset de manera sincronica
      @(posedge clock); // esta linea sirve para esperar a que el clock haga un flanco positivo y luego levantar el reset

      //----> Levanto reset
      i_reset <= 'd1; 
    end
  endtask


  `define TEST6

    
    `ifdef TEST1
        `include "./test1.sv"
    `endif
    
    `ifdef TEST2
        `include "./test2.sv"
    `endif
    
    `ifdef TEST3
        `include "./test3.sv"
    `endif
    
    `ifdef TEST4
        `include "./test4.sv"
    `endif
    
    `ifdef TEST5
        `include "./test5.sv"
    `endif
    
    `ifdef TEST6
        `include "./test6.sv"
    `endif

    


    
endmodule

