module FSM (
    input wire clk,
    input wire reset,
    input wire [15:0] data_out,        // dado lido da memória
    input wire [15:0] acc_out,         // valor acumulado atual

    output reg [15:0] acc_in,          // entrada do acumulador
    output reg acc_enable,            // ativa acumulador

    output reg [4:0] address,
    output reg [15:0] data_in,
    output reg read_en,
    output reg write_en,
    output reg ready
);

    reg [3:0] state;
    reg [3:0] count;
    reg [4:0] base_addr;
    reg [2:0] block_index;
    reg [15:0] total_sum;

    localparam IDLE = 0,
               LOAD = 1,
               WAIT_READ = 2,
               ACCUMULATE = 3,
               NEXT_ADDR = 4,
               WRITE_RESULT = 5,
               SUM_RESULTS = 6,
               NEXT_BLOCK = 7,
               FINAL_WRITE = 8,
               SIGNAL_READY1 = 9,
               SIGNAL_READY2 = 10,
               RESET_FSM = 11;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            address <= 0;
            acc_enable <= 0;
            read_en <= 0;
            write_en <= 0;
            ready <= 0;
            base_addr <= 0;
            block_index <= 0;
            count <= 0;
            total_sum <= 0;
        end else begin
            case (state)
                IDLE: begin
                    acc_enable <= 0;
                    ready <= 0;
                    base_addr <= 0;
                    block_index <= 0;
                    total_sum <= 0;
                    state <= LOAD;
                end

                LOAD: begin
                    address <= base_addr + count;
                    read_en <= 1;
                    state <= WAIT_READ;
                end

                WAIT_READ: begin
                    read_en <= 0;
                    acc_in <= data_out;
                    acc_enable <= 1;
                    state <= ACCUMULATE;
                end

                ACCUMULATE: begin
                    acc_enable <= 0;
                    count <= count + 1;
                    if (count == 3)
                        state <= WRITE_RESULT;
                    else
                        state <= LOAD;
                end

                WRITE_RESULT: begin
                    address <= base_addr + 4;  // próxima posição
                    data_in <= acc_out;
                    write_en <= 1;
                    state <= SUM_RESULTS;
                end

                SUM_RESULTS: begin
                    write_en <= 0;
                    total_sum <= total_sum + acc_out;
                    state <= NEXT_BLOCK;
                end

                NEXT_BLOCK: begin
                    count <= 0;
                    block_index <= block_index + 1;
                    case (block_index)
                        0: base_addr <= 5;
                        1: base_addr <= 10;
                        2: base_addr <= 15;
                        3: base_addr <= 20;
                        default: state <= FINAL_WRITE;
                    endcase
                    if (block_index < 4)
                        state <= LOAD;
                end

                FINAL_WRITE: begin
                    address <= 31;
                    data_in <= total_sum;
                    write_en <= 1;
                    state <= SIGNAL_READY1;
                end

                SIGNAL_READY1: begin
                    write_en <= 0;
                    ready <= 1;
                    state <= SIGNAL_READY2;
                end

                SIGNAL_READY2: begin
                    ready <= 1;
                    state <= RESET_FSM;
                end

                RESET_FSM: begin
                    ready <= 0;
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule
