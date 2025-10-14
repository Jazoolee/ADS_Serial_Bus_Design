module slave1(
    input logic clk,
    input logic rstn,

    input logic rx,
    output logic tx,

    input logic busy
    );

    logic [13:0] counter;
    logic [13:0] addr;
    logic [7:0] wdata;
    logic [7:0] rdata;

    logic [3:0] state;
    localparam IDLE = 4'b0000;
    localparam SLV_REQUESTED = 4'b0001;
    localparam SLV_READY = 4'b0010;
    localparam ADDR_RX = 4'b0011;
    localparam DATA_TX = 4'b0100;
    localparam DATA_RX = 4'b0101;
    localparam SPLIT = 4'b0110;

    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            state <= IDLE;
            tx <= '1;
            counter <= '0;
            addr[13:12] = 2'b00;
        end else begin
            case (state)
                IDLE: begin
                    counter <= '0;
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
                SLV_READY: begin
                    if (counter < 3) counter <= counter+1;
                    else begin
                        counter <= '0;
                        state <= ADDR_RX;
                    end
                end
                ADDR_RX: begin
                    if (counter <= 11) begin
                        addr[counter] <= rx;
                        counter <= counter + 1;
                    end else begin
                        counter <= 0;
                        state <= rx ? DATA_RX : DATA_TX;
                    end
                end
                DATA_RX: begin
                    if (counter <= 7) begin
                        wdata[counter] <= rx;
                        counter <= counter + 1;
                    end else begin
                        counter <= 0;
                        tx <= '1;
                        state <= IDLE;
                    end
                end
                DATA_TX: begin
                    if (counter <= 7) begin
                        tx <= rdata[counter];
                        counter <= counter + 1;
                    end else begin
                        counter <= 0;
                        tx <= '1;
                        state <= IDLE;
                    end
                end
                SPLIT: begin
                    if (!busy && !rx) begin
                        tx <= '0;
                        state <= SLV_READY;
                    end
                end
                default: state <= IDLE;
            endcase
        end
    end

    initial rdata = 8'hD3; //1101 0011
endmodule