`timescale 1ns/1ns


module modelo_ideal #(
    parameter int N_LEDS = 4,
    parameter int NB_COUNTER = 32
)(
    input  wire clock,         
    input  wire i_reset,
    input  wire i_enable,
    input  wire [NB_COUNTER-1:0] limit,
    output reg  [N_LEDS-1:0] leds_modelo
);

    localparam [N_LEDS-1:0] valor_reset = {1'b1, {(N_LEDS-1){1'b0}}};
    reg [NB_COUNTER-1:0] count; // variable para llevar la cuenta del contador, cuando count llega a limit, se hace el shift y se reinicia count a 0

    always @(posedge clock or negedge i_reset) begin
        if (!i_reset) begin
            count <= 0;
            leds_modelo <= valor_reset;
        end else if (i_enable) begin
            // si el count esta en 0 significa que alcanzamos el limite de cuenta en el ciclo anterior, por lo tanto hacemos el shift circular a la derecha
            if (count == 0) begin
                leds_modelo <= {leds_modelo[0], leds_modelo[N_LEDS-1:1]};
            end
            
            // si el count es mayor o igual al limite, reiniciamos count a 0, sino incrementamos count en 1
            // en el proximo ciclo de clock, se hara el shifteo
            if (count >= limit) begin
                count <= 0; 
            end else begin //si no esta en 0 ni es mayor o igual al limite, incrementamos count en 1
                count <= count + 1; 
            end
            
        end
    end

endmodule
