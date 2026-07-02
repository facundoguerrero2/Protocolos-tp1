//----> TOP LEDS

module top_leds
  #(
    parameter N_SWITCH = 4                  ,
    parameter N_LED    = 4
  )
  (
  //----> Output
    
    output  wire [N_LED    - 1 : 0] o_led   ,
    output  wire [N_LED    - 1 : 0] o_led_b ,
    output  wire [N_LED    - 1 : 0] o_led_g ,
  //----> Inputs
    input   wire [N_SWITCH - 1 : 0] i_sw    ,
    input   wire                    i_reset ,
    input   wire                    clock
  );

  localparam   NB_SHIFT_REG = 4;

  wire                          shift         ; // conecta la salida del contador con la entrada del shifter
  wire [NB_SHIFT_REG - 1 : 0]   led_enable    ; // conecta la salida del shifter con la salida de los leds, es de 4 bits porque tenemos 4 leds

  counter
  u_counter
  (  //----> Output
    .o_shift                        (shift    ),
    //----> Inputs
    .i_enable                       (i_sw[0]  ),
    .i_sel_count_limit              (i_sw[2:1]),
    .i_reset                        (i_reset  ),
    .clock                          (clock    ) 
  )                                             ;          

  shift_reg
  u_shift_reg
  (
    //----> Outputs
    .o_led_enable                   (led_enable),
    //----> Inputs
    .i_shift                        (shift     ),
    .i_enable                       (i_sw[0]   ),
    .i_reset                        (i_reset   ), 
    .clock                          (clock     )
  )                                               ;


  //----> Outputs
  assign o_led    = led_enable;
  //elijo entre led blue o green con i_sw[3], y le cargo led_enable o 0 dependiendo de la seleccion
  assign o_led_b  = ( i_sw[3]) ? led_enable : 4'b0000   ; 
  assign o_led_g  = (!i_sw[3]) ? led_enable : 4'b0000   ; 



endmodule
