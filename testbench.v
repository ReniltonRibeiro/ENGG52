`timescale 1ns/1ps

module testbench;

    reg clk = 0;
    reg reset = 0;

    wire [4:0] address;
    wire [15:0] data_in;
    wire [15:0] data_out;
    wire read_en;
    wire write_en;
    wire ready;

    reg [15:0] mem [0:31];  // Memória simulada

    assign data_out = (read_en) ? mem[address] : 16'hZZZZ;

    // Simulação da escrita
    always @(posedge clk) begin
        if (write_en)
            mem[address] <= data_in;
    end

    // Gera clock
    always #5 clk = ~clk;

    // Instancia o módulo TOP
    TOP uut (
        .Clock(clk),
        .Reset(reset),
        .Address(address),
        .DataIn(data_in),
        .DataOut(data_out),
        .ReadEnable(read_en),
        .WriteEnable(write_en),
        .Ready(ready)
    );

    initial begin
        $display("Iniciando simulação...");
        $dumpfile("testbench.vcd");
        $dumpvars(0, testbench);

        // Inicializa memória com valores conhecidos
        mem[0] = 1; mem[1] = 2; mem[2] = 3; mem[3] = 4;     // soma = 10 → em 4
        mem[5] = 5; mem[6] = 5; mem[7] = 5; mem[8] = 5;     // soma = 20 → em 9
        mem[10] = 6; mem[11] = 6; mem[12] = 6; mem[13] = 6; // soma = 24 → em 14
        mem[15] = 7; mem[16] = 7; mem[17] = 7; mem[18] = 7; // soma = 28 → em 19
        mem[20] = 8; mem[21] = 8; mem[22] = 8; mem[23] = 8; // soma = 32 → em 24

        // Reset
        reset = 1;
        #10;
        reset = 0;

        // Espera suficiente para todas as operações (ajustar conforme FSM)
        #1000;

        // Verifica se resultados esperados estão corretos
        $display("Resultado em 4  = %d (esperado 10)", mem[4]);
        $display("Resultado em 9  = %d (esperado 20)", mem[9]);
        $display("Resultado em 14 = %d (esperado 24)", mem[14]);
        $display("Resultado em 19 = %d (esperado 28)", mem[19]);
        $display("Resultado em 24 = %d (esperado 32)", mem[24]);
        $display("Soma total em 31 = %d (esperado 10+20+24+28+32 = 114)", mem[31]);

        // Encerrar simulação
        $finish;
    end

endmodule
