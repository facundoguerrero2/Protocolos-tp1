module counter
    #(
        parameter NB_COUNT_LIMIT = 2
    )
    (
    // --> outputs
    output wire     o_shift,  //señal para que shiftee el shifter

    // --> inputs
    input wire      i_enable, 
    input wire [NB_COUNT_LIMIT - 1 : 0] i_sel_count_limit, //input con el limite de la cuenta
    input wire i_reset ,
    input wire clock
    );


localparam NB_COUNTER = 32      ; //limite del contador

reg  [NB_COUNTER - 1 : 0] counter                         ; //variable del contador
wire [NB_COUNTER - 1 : 0] counter_next                    ; //variable del contador siguiente
//esto es 

//definimos los limites de cada cuenta
//seran 4 limites de 32 bits seleccionables por el input i_sel_count_limit
reg  [NB_COUNTER - 1 : 0] limit_0                         ;
reg  [NB_COUNTER - 1 : 0] limit_1                         ;
reg  [NB_COUNTER - 1 : 0] limit_2                         ;
reg  [NB_COUNTER - 1 : 0] limit_3                         ;


always@(posedge clock or negedge i_reset)
begin
  if      (!i_reset ) //si se presiona el reset (activo por bajo) se reinician los limites a 0
  begin
    limit_0 <= 'd0 ;
    limit_1 <= 'd0 ;
    limit_2 <= 'd0 ;
    limit_3 <= 'd0 ;
  end
  else
  begin
    limit_0 <= 32'h0010_0000 ; // decimal 1048576 
    limit_1 <= 32'h0020_0000 ; // decimal 2097152 es el doble del limite 0
    limit_2 <= 32'h0040_0000 ; // decimal 4194304 es el doble del limite 1
    limit_3 <= 32'h0080_0000 ; // decimal 8388608 es el doble del limite 2
  end
end

//asignacion, asigna el siguiente valor del contador 
// a 0 si se supera el limite seleccionado 
// o a contador + 1 si no se supera el limite seleccionado
assign counter_next = ((i_sel_count_limit == 2'b00) && (counter >= limit_0)) ? 'd0 :
                      ((i_sel_count_limit == 2'b01) && (counter >= limit_1)) ? 'd0 :
                      ((i_sel_count_limit == 2'b10) && (counter >= limit_2)) ? 'd0 :
                      ((i_sel_count_limit == 2'b11) && (counter >= limit_3)) ? 'd0 :
                                                                                counter + 1'b1;

always@(posedge clock or negedge i_reset)
    begin
        if(!i_reset) //si se presiona el reset (activo por bajo) 
        begin
            counter <= 'd0;
        end
        else if (!i_enable) //si no esta habilitado el contador, se mantiene el valor actual (enable activo por alto)
        begin
            counter <= counter;
        end
        else 
        begin
            counter <= counter_next; //si esta habilitado el contador, se actualiza al siguiente valor
        end
    end

assign o_shift = (counter == 'd0);

endmodule
