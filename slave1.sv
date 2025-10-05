module slave1(
    input logic clk,
    input logic rstn,

    input logic rx,
    output logic tx,

    input logic busy
    );

    logic [13:0] counter;
    logic [7:0] data;

    logic [2:0] state;
    localparam IDLE = 3'b000;
    localparam SLV_REQUESTED = 3'b001;
    localparam SLV_READY = 3'b010;
    localparam SLV_GRANTED = 3'b011;
    localparam DATA_TX = 3'b100;
    localparam DATA_READY = 3'b111;
    localparam DATA_RX = 3'b101;
    localparam SPLIT = 3'b110;

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
                        state <= SLV_READY;
                    end else begin
                        state <= SPLIT;
                    end
                end
                SLV_READY: state <= SLV_GRANTED;
                SLV_GRANTED: state <= DATA_TX;
                DATA_TX: state <= DATA_READY;
                DATA_READY: state <= DATA_RX;
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
                        state <= SLV_READY;
                    end
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule