module arbiter(
    input logic clk,
    input logic rstn,

    input logic m1_tx,
    output logic m1_rx,

    input logic m2_tx,
    output logic m2_rx,

    output logic [13:0] addr,
    output logic addr_rdy,
    output logic m1,
    output logic m2,
    input logic slv_ready,
    input logic slv_responded
	 );

    logic m1_queued;
    logic m2_queued;
    logic m1_splitted;
    logic m2_splitted;
    logic [13:0] counter; 
    logic m_rx;
    
    logic [4:0] state;
    localparam IDLE = 4'b0000;
    localparam BUS_REQUESTED = 4'b0001;   
    localparam BUS_GRANTED = 4'b0010; 
    localparam WAIT_FOR_ADDR = 4'b0011;    
    localparam ADDR_TX = 4'b0100;
    localparam ADDR_RX = 4'b0101;
    localparam SLV_WAIT = 4'b0110;
    localparam DATA_TX = 4'b0111;
    localparam SPLIT = 4'b1000;

    assign m1 = (m1_queued && !m1_splitted);
    assign m2 = (m2_queued && !m2_splitted);

    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            state <= IDLE;
            m1_rx <= '1;
            m2_rx <= '1;
            counter <= '0;
            m1_queued <= '0;
            m2_queued <= '0;
            m1_splitted <= '0;
            m2_splitted <= '0;
            addr_rdy <= '0;
        end else begin
            case (state)
                IDLE: begin
                    m1_rx <= '1;
                    m2_rx <= '1;
                    counter <= '0;
                    addr_rdy <= '0;
                    if (!m1_tx || !m2_tx) begin
                        state <= BUS_REQUESTED;
                    end
                end
                BUS_REQUESTED: begin
                    if ((!m1_tx && !m1_splitted) && (!m2_tx && !m2_splitted)) begin
                        m1_queued <= '1;
                        m2_queued <= '0;
                    end else if ((!m1_tx && m1_splitted) && (!m2_tx && !m2_splitted)) begin
                        m1_queued <= '0;
                        m2_queued <= '1;
                    end else if ((!m1_tx && !m1_splitted) && (!m2_tx && m2_splitted)) begin
                        m1_queued <= '1;
                        m2_queued <= '0;
                    end else if (!m1_tx) begin
                        m1_queued <= '1;
                        m2_queued <= '0;
                    end else if (!m2_tx) begin
                        m1_queued <= '0;
                        m2_queued <= '1;
                    end
                    state <= BUS_GRANTED;
                end
                BUS_GRANTED: begin
                    if (m1_queued && !m1_splitted) m1_rx <= '0;
                    if (m2_queued && !m2_splitted) m2_rx <= '0;
                    state <= ADDR_TX;
                end
                ADDR_TX: state <= ADDR_RX;
                ADDR_RX: begin
                    if (counter <= 13) begin
                        if (m1_queued && !m1_splitted) begin
                            addr[counter] <= m1_tx;
                            if (counter == 13) m1_rx <= '1;
                        end
                        if (m2_queued && !m2_splitted) begin
                            addr[counter] <= m2_tx;  
                            if (counter == 13) m2_rx <= '1;                          
                        end
                        counter <= counter + 1;
                    end else begin
                        addr_rdy <= '1;                        
                        counter <= 0;
                        state <= SLV_WAIT;
                    end
                end
                SLV_WAIT: begin
                    addr_rdy <= '0;
                    if (slv_ready) begin
                        if (m1_queued && !m1_splitted) m1_rx <= '0;
                        if (m2_queued && !m2_splitted) m2_rx <= '0;
                        state <= DATA_TX; 
                    end else if (!slv_ready && slv_responded) begin                        
                        if ((m1_queued && !m2_tx) || (m2_queued && !m1_tx)) state <= SPLIT;
                    end
                end
                DATA_TX: begin
                    if (counter <= 7) begin
                        counter <= counter + 1;
                    end else begin
                        counter <= 0;
                        if (m1_splitted) begin
                            m1_queued <= '1;
                            m1_splitted <= '0;
                            m2_queued <= '0;
                            state <= SLV_WAIT;
                        end else if (m2_splitted) begin
                            m1_queued <= '0;
                            m2_queued <= '1;
                            m2_splitted <= '0;
                            state <= SLV_WAIT;
                        end else state <= IDLE;
                    end
                end
                SPLIT: begin
                    if (m1_queued && !m2_tx) m1_splitted <= '1; 
                    if (m2_queued && !m1_tx) m2_splitted <= '1;
                    state <= BUS_REQUESTED; 
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule