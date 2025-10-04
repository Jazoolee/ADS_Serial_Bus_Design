module master2(
    input logic clk,
    input logic rstn,
    input logic rx,
    output logic tx,

    input logic data_ready
    );

    logic [13:0] addr;
    logic [7:0] data;
    logic [13:0] counter;  

    logic [2:0] state;
    localparam IDLE = 3'b000;
    localparam REQ = 3'b001;
    localparam ARB_WAIT = 3'b010;
    localparam ADDR_TX = 3'b011;
    localparam SLV_WAIT = 3'b100;
    localparam DATA_TX = 3'b101;

    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            state <= IDLE;
            tx <= '1;
            counter <= '0;
        end else begin
            case (state)
                IDLE: begin
                    tx <= '1;
                    if (data_ready) state <= REQ;
                end
                REQ: begin
                    tx <= '0;
                    state <= ARB_WAIT;
                end
                ARB_WAIT: begin
                    if (rx === '0) state <= ADDR_TX;
                end
                ADDR_TX: begin
                    if (counter <= 13) begin
                        tx <= addr[counter];
                        counter <= counter+1;
                    end else begin
                        counter <= 0;
                        tx <= '0;
                        state <= SLV_WAIT;
                    end
                end
                SLV_WAIT: begin
                    if (rx === '0) state <= DATA_TX;
                end
                DATA_TX: begin
                    if (counter <= 7) begin
                        tx <= data[counter];
                        counter <= counter+1;
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
        addr <=14'h2000;
        data <=8'b1;
    end

endmodule