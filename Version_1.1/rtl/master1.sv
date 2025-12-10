module master1(
    input logic clk,
    input logic rstn,
    input logic rx,
    output logic tx,

    input logic data_ready,
    input logic rw, // 1:write 0:read

    output wire [7:0] rdata,
    output logic [2:0] state_o,
    output logic c0
    );

    logic [13:0] addr;
    logic [7:0] wdata;
    logic [13:0] counter;
    logic [7:0] rdata_reg;  

    logic [2:0] state;
    localparam IDLE = 3'b000;
    localparam REQ = 3'b001;
    localparam WAIT_AND_REQ_SLV = 3'b010;
    localparam WAIT_AND_TX_ADDR = 3'b011;
    localparam TX_DATA = 3'b100;
    localparam WAIT_RX_DATA = 3'b101;
    localparam RX_DATA = 3'b110;

    assign state_o = state;
    assign rdata = rdata_reg;

    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            state <= IDLE;
            tx <= 1'b1;
            counter <= 14'b0;
            rdata_reg <= '0;
            // addr <=14'h0AA8; // 00 1010 1010 1000
            // wdata <=8'hff; // 1010 1011
        end else begin
            case (state)
                IDLE: begin
                    tx <= '1;
                    if (data_ready) state <= REQ;
                end
                REQ: begin
                    tx <= '0;
                    counter <= 14'd12;
                    state <= WAIT_AND_REQ_SLV;
                end
                WAIT_AND_REQ_SLV: begin
                    if (rx === '0) begin
                        if (counter <= 13) begin
                            tx <= addr[counter];
                            counter <= 14'(counter+1);
                        end else begin
                            counter <= 14'd0;
                            tx <= '0;
                            state <= WAIT_AND_TX_ADDR;
                        end
                    end
                end
                WAIT_AND_TX_ADDR: begin
                    if (rx === '0) begin
                        if (counter <= 11) begin
                            tx <= addr[counter];
                            counter <= 14'(counter+1);
                        end else begin
                            tx <= rw ? '1 : '0;
                            counter <= 0;
                            state <= rw ? TX_DATA : WAIT_RX_DATA;
                        end
                    end
                end
                TX_DATA: begin
                    if (counter <= 7) begin
                        tx <= wdata[counter[7:0]];
                        counter <= 14'(counter+1);
                    end else begin
                        counter <= 0;
                        state <= IDLE;
                    end
                end
                WAIT_RX_DATA: begin
                    if (counter <= 2) begin
                        counter <= 14'(counter + 1);
                    end else begin
                        counter <= 14'b0;
                        state <= RX_DATA;
                    end
                end
                RX_DATA: begin
                    if (counter <= 7) begin
                        c0 <= counter[2];
                        rdata_reg[counter[7:0]] <= rx;
                        counter <= 14'(counter+1);
                    end else begin
                        counter <= 0;
                        state <= IDLE;
                    end
                end
                default: state <= IDLE;
            endcase
        end
    end

    always_ff @(posedge data_ready) begin
        addr <=14'h0AA8; // 00 1010 1010 1000
        wdata <=8'hff; // 1010 1011
    end

endmodule