module shift_reg
#(
  parameter   NB_SHIFT_REG = 4
)
(
  //----> Outputs
    output wire [NB_SHIFT_REG - 1 : 0]  o_led_enable , //es el led que se ira shifteando
  //----> Inputs
    input  wire                         i_shift      , //señal que viene desde el contador para hacer el shift
    input  wire                         i_enable     , 
    input  wire                         i_reset      , 
    input  wire                         clock 
);


//----> Shift register
reg  [NB_SHIFT_REG - 1 : 0] shift_register; //registro de desplazamiento que se va a ir shifteando

always@(posedge clock or negedge i_reset) 
begin
  if      (!i_reset)
  begin
    shift_register <= 4'b1000; //inicializamos el registro de desplazamiento con un 1 el bit mas a la izquierda
  end
  else if (i_shift && i_enable)
  begin
    shift_register <= {shift_register[0],shift_register[NB_SHIFT_REG-1:1]}; //shifteo circular a la derecha
  end
end

assign o_led_enable = shift_register; //asignamos el valor del registro de desplazamiento a la salida o_led_enable

endmodule

