module Acumulador (
    input wire clk,
    input wire reset,
    input wire enable,
    input wire [15:0] in_data,
    output reg [15:0] out_data
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            out_data <= 16'b0;
        end else if (enable) begin
            out_data <= out_data + in_data;
        end
    end

endmodule
