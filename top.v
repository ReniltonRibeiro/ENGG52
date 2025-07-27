module TOP (
    input wire Clock,
    input wire Reset,
    output wire [4:0] Address,
    output wire [15:0] DataIn,
    input wire [15:0] DataOut,
    output wire ReadEnable,
    output wire WriteEnable,
    output wire Ready
);

    // Sinais internos
    wire [15:0] acc_in;
    wire [15:0] acc_out;
    wire acc_enable;

    // Instanciação do Acumulador
    Acumulador acumulador_inst (
        .clk(Clock),
        .reset(Reset),
        .in_data(acc_in),
        .enable(acc_enable),
        .out_data(acc_out)
    );

    // Instanciação da FSM
    FSM fsm_inst (
        .clk(Clock),
        .reset(Reset),
        .data_out(DataOut),       // da memória para a FSM
        .acc_out(acc_out),        // soma final do acumulador
        .acc_in(acc_in),          // entrada atual do acumulador
        .acc_enable(acc_enable),  // habilita o acumulador
        .address(Address),
        .data_in(DataIn),
        .read_en(ReadEnable),
        .write_en(WriteEnable),
        .ready(Ready)
    );

endmodule
