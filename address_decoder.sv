module address_decoder(
    input logic clk,
    input logic rstn,

    input logic m1_tx,
    input logic m2_tx,

    input logic s1_tx,
    input logic s2_tx,
    input logic s3_tx,

    output logic s1_rx,
    output logic s2_rx,
    output logic s3_rx,

    input logic [13:0] addr,
    input logic addr_rdy,
    input logic m1,
    input logic m2,
    output logic slv_ready
    );

    logic [13:0] counter;
    logic s1_splitted; 

    logic [2:0] state;
    localparam IDLE = 3'b000;
    localparam SLV_REQUESTED = 3'b001;
    localparam SLV_WAIT = 3'b010;
    localparam SLV_GRANTED = 3'b110;
    localparam DATA_TX = 3'b011;
    localparam DATA_RX = 3'b100;
    localparam SPLIT = 3'b101;

    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            state <= IDLE;
            s1_rx <= '1;
            s2_rx <= '1;
            s3_rx <= '1;
            slv_ready <= '0;
            s1_splitted <= '0;
            counter <= 0;
        end else begin
            case (state)
                IDLE: begin
                    slv_ready <= '0;
                    counter <= 0;
                    if (addr_rdy) state <= SLV_REQUESTED;
                    else if (s1_splitted && !s1_tx) begin
                        slv_ready <= '1;
                        s1_rx <= '1;
                        state <= SLV_GRANTED;
                    end
                end
                SLV_REQUESTED: begin
                    case (addr[13:12])
                        2'b00: s1_rx <= '0;
                        2'b01: s2_rx <= '0;
                        2'b10: s3_rx <= '0;
                    endcase
                    state <= SLV_WAIT;
                end
                SLV_WAIT: begin
                    if (!s1_tx || !s2_tx || !s3_tx) begin
                        slv_ready <= '1;
                        s1_rx <= '1;
                        s2_rx <= '1;
                        s3_rx <= '1;
                        state <= SLV_GRANTED;
                    end else begin
                        slv_ready <= '0;
                        state <= SPLIT;
                    end
                end
                SLV_GRANTED: state <= DATA_TX;
                DATA_TX: state <= DATA_RX;
                DATA_RX: begin
                    if (counter <= 7) begin
                        if (!s1_tx) begin
                            s1_rx <= m1? m1_tx : m2_tx;
                            if (s1_splitted) s1_splitted <= '0;
                        end
                        if (!s2_tx) s2_rx <= m1? m1_tx : m2_tx;
                        counter <= counter + 1;
                    end else begin
                        counter <= 0;
                        state <= IDLE;
                    end
                end
                SPLIT: begin
                    s1_splitted <= '1;
                    state <= IDLE;
                end
                default: state <= IDLE;
            endcase
        end
    end

endmodule