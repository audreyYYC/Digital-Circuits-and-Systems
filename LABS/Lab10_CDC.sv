`include "Handshake_syn.v"

module CDC(
    // Input signals
    clk_1,
    clk_2,
    rst_n,
    in_valid,
    in_data,
    // Output signals
    out_valid,
    out_data
);

// Port declarations
input  logic        clk_1;
input  logic        clk_2;         
input  logic        rst_n;
input  logic        in_valid;
input  logic [3:0]  in_data;

output logic        out_valid;
output logic [4:0]  out_data;            



logic sready, sidle, dbusy, dvalid;
logic [3:0] din, dout;

typedef enum logic [1:0] { 
    IDLE, WAIT, SEND
} src_state_t;
src_state_t src_state, src_next_state;

logic [3:0] data_1, data_2;
logic [1:0] count;

typedef enum logic [1:0] { 
    DST_IDLE, DST_RECV, DST_OUTPUT
} dst_state_t;
dst_state_t     dst_state;

logic [3:0]     recv_data1, recv_data2;
logic           prev_dvalid_state;


assign dbusy = 0;

always_ff @(posedge clk_1 or negedge rst_n) begin
    if (!rst_n) begin
        src_state  <= IDLE;
        data_1 <= 0;
        data_2 <= 0;
        count <= 0;
    end 
    else begin
        src_state <= src_next_state;
        
        if (src_state == IDLE && in_valid) 
            data_1 <= in_data; 
        else if (src_state == WAIT && in_valid) 
            data_2 <= in_data;
        
        if (src_state == SEND && sidle && count < 2) 
            count <= count + 1;
        
        if (count == 2) begin
            count <= 2'd0;
        end
    end
end

always_comb begin
    src_next_state = src_state;
    sready = 0;
    din = 0;
    
    case (src_state)
        IDLE: begin
            if (in_valid) 
                src_next_state = WAIT;
        end
        
        WAIT: begin
            if (in_valid) 
                src_next_state = SEND;
        end
        
        SEND: begin
            if (sidle) begin
                if (count == 0) begin
                    sready = 1;
                    din = data_1;
                end 
                else if (count == 1) begin
                    sready = 1'b1;
                    din = data_2;
                    src_next_state = IDLE;
                end
            end
        end
    endcase
end

//clk2
always_ff @(posedge clk_2 or negedge rst_n) begin
    if (!rst_n) 
        prev_dvalid_state <= 0;
    else 
        prev_dvalid_state <= dvalid;
end

always_ff @(posedge clk_2 or negedge rst_n) begin
    if (!rst_n) begin
        dst_state <= DST_IDLE;
        recv_data1 <= 0;
        recv_data2 <= 0;
        out_valid <= 0;
        out_data  <= 0;
    end
    else begin
        out_valid <= 1'b0;
        case (dst_state)
            DST_IDLE: begin
                if (dvalid && !prev_dvalid_state) begin
                    recv_data1 <= dout;
                    dst_state <= DST_RECV;
                end
            end
            DST_RECV: begin
                if (dvalid && !prev_dvalid_state) begin
                    recv_data2 <= dout;
                    dst_state <= DST_OUTPUT;
                end
            end
            DST_OUTPUT: begin
                out_data  <= recv_data1 + recv_data2;
                out_valid <= 1;
                dst_state <= DST_IDLE;
            end
        endcase
    end
end

Handshake_syn synchronizer (
    .sclk   (clk_1), 
    .dclk   (clk_2), 
    .rst_n  (rst_n),
    .sready (sready), 
    .din    (din), 
    .sidle  (sidle),
    .dbusy  (dbusy),
    .dvalid (dvalid),
    .dout   (dout)
);
endmodule