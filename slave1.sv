module slave1(
    input logic clk,
    input logic rstn,

    input rx,
    output tx,

    input busy
    );

    logic [13:0] counter;
    logic [7:0] data;

    logic [2:0] state;
    localparam IDLE = 3'b000;
    localparam SLV_REQUESTED = 3'b001;
    localparam DATA_RX = 3'b011;
    localparam SPLIT = 3'b100;

    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            state <= IDLE;
            tx <= '1;
            counter <= '0;
        end else begin
            case (state)
                IDLE: begin
                    if (!rx) state <= SLV_REQUESTED;
                end
                SLV_REQUESTED: begin
                    if (!busy) begin
                        tx <= '0;
                        state <= DATA_RX;
                    end else begin
                        state <= SPLIT;
                    end
                end
                DATA_RX: begin
                    if (counter <= 7) begin
                        data[counter] <= rx;
                        counter <= counter + 1;
                    end else begin
                        tx <= '1;
                        counter <= 0;
                        state <= IDLE;
                    end
                end
                SPLIT: begin
                    if (!busy) begin
                        tx <= '0;
                        state <= DATA_RX;
                    end
                end
            endcase
        end
    end
endmodule