module TA(
    clk,
    rst_n,
    // input
    i_valid,
    i_length,
    m_ready,
    // virtual memory
    m_data,
    m_read,
    m_addr,
    // output
    o_valid,
    o_data
);
//---------------------------------------------------------------------
// INPUT AND OUTPUT DECLARATION
//---------------------------------------------------------------------
input clk, rst_n;
// input
input i_valid;
input [1:0] i_length;
input m_ready;
// virtual memory
input [31:0] m_data;
output logic m_read;
output logic [5:0] m_addr;
// output
output logic o_valid;
output logic [40:0] o_data;

//---------------------------------------------------------------------
// PARAMETER AND TYPE DECLARATION
//---------------------------------------------------------------------
typedef enum logic [3:0] {
    IDLE, WAIT_M_READY,
    READ_INPUT_RAT,
    MM_Q1, MM_Q2,
    MM_K1, MM_K2, MM_K3,
    MM_T1, MM_T2,
    MM_V1, MM_V2,
    MM_S1, MM_S2,
    OUT
} state_t;

//---------------------------------------------------------------------
// REGISTER AND WIRE DECLARATION
//---------------------------------------------------------------------
state_t state, next_state;

logic [2:0] l;
logic [5:0] L; // 4, 8, 16, 32

// Memory management
logic [5:0] mem_counter, next_mem_counter;

// Input token matrix storage with pipelined RAT
logic [3:0] i_token [0:31][0:7];

// RAT pipeline registers
logic [3:0] previous_row_avg, next_previous_row_avg;
logic rat_update_enable;
logic [6:0] temp_sum;

// MM
logic [10:0] q[0:31][0:7], k[0:31][0:7];
logic [14:0] t[0:4];
logic [13:0] sum_00, sum_01, sum_10, sum_11, sum_20, sum_21, sum_30, sum_31;

logic [5:0] ptr, next_ptr, ptrt, next_ptrt, ptr_1, next_ptr_1, ptr_2, next_ptr_2;
logic [6:0] a, b, c, d, e, f;
logic [3:0] temp_col [0:7];
logic [11:0] product_0[0:7], product_1[0:7], product_2[0:7], product_3[0:7];
logic product_sum_q, next_product_sum_q, product_sum_k, next_product_sum_k;
logic product_sum_t1, next_product_sum_t1, product_sum_t2;
logic product_sum_s1, next_product_sum_s1, product_sum_s2;

logic [31:0] s, temp_score;
logic [32:0] temp_s;
logic [21:0] score [0:31];

// Output
logic [40:0] o_token [0:7];

//---------------------------------------------------------------------
// MAIN FSM
//---------------------------------------------------------------------
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        state <= IDLE;
    else
        state <= next_state;
end

always_comb begin
    next_state = state;
    case (state)
        IDLE: begin
            if (i_valid) 
                next_state = WAIT_M_READY;
        end
        WAIT_M_READY: begin
            if (m_ready) 
                next_state = READ_INPUT_RAT;
        end
        READ_INPUT_RAT: begin
            if (mem_counter == L) 
                next_state = MM_Q1;
        end

        MM_Q1: next_state = MM_Q2;
        MM_Q2: begin
            if(ptr + 4 == L) begin
                if (ptrt < 7) 
                    next_state = MM_Q1;
                else 
                    next_state = MM_K1;
            end
        end

        MM_K1: next_state = MM_K2;
        MM_K2: begin
            if(ptr + 4 == L) begin
                if (ptrt < 7) 
                    next_state = MM_K1;
                else 
                    next_state = MM_K3;
            end
        end
        MM_K3: next_state = MM_T1;

        MM_T1: begin
            if (ptr == L - 1) 
                next_state = MM_T2;
        end
        MM_T2: begin
            if(!product_sum_t1) begin
                if(ptrt == L - 1)
                    next_state = MM_V1;
                else
                    next_state = MM_T1;
            end
        end

        MM_V1: next_state = MM_V2;
        MM_V2: begin
            if(ptr + 4 == L) begin
                if (ptrt < 7) 
                    next_state = MM_V1;
                else 
                    next_state = MM_S1;
            end
        end

        MM_S1: begin
            if ((ptrt == 7) && (ptr + 4 == L)) 
                next_state = OUT;
        end
        OUT: begin
            if (ptr == 7)
                next_state = IDLE;
        end
    endcase
end

//---------------------------------------------------------------------
// DIMENSION CALCULATION
//---------------------------------------------------------------------
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        L <= 0;
        //l <= 0;
    end
    else if (i_valid) begin
        case (i_length)
            2'b00: begin L <= 4; l <= 2; end
            2'b01: begin L <= 8; l <= 3; end
            2'b10: begin L <= 16; l <= 4; end
            2'b11: begin L <= 32; l <= 5; end
        endcase
    end
end

//---------------------------------------------------------------------
// V-ROM READ
//---------------------------------------------------------------------
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        m_read <= 0;
        m_addr <= 0;
        mem_counter <= 0;
        rat_update_enable <= 0;
    end
    else begin
        mem_counter <= next_mem_counter;
        if (next_state == MM_Q1 || next_state == MM_K1 || next_state == MM_V1 || state == READ_INPUT_RAT) begin
            m_read <= 1;
            m_addr <= mem_counter;
        end
        else begin
            m_read <= 0;
            rat_update_enable <= 0;
        end

        if (state == READ_INPUT_RAT) begin
            if (mem_counter > 0) 
                rat_update_enable <= 1;
            else 
                rat_update_enable <= 0;
        end
    end
end

always_comb begin
    next_mem_counter = mem_counter;
    if (state == IDLE) 
        next_mem_counter = 0;
    if (next_state == MM_Q1 || next_state == MM_K1 || next_state == MM_V1 || state == READ_INPUT_RAT) 
        next_mem_counter = mem_counter + 1;
end

//---------------------------------------------------------------------
// I_TOKEN READING WITH PIPELINED RAT
//---------------------------------------------------------------------
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (int i = 0; i < 32; i++) begin
            for (int j = 0; j < 8; j++) 
                i_token[i][j] <= 0;
        end
        previous_row_avg <= 0;
    end
    else begin
        if (m_read && state == READ_INPUT_RAT) begin
            // Read current row
            i_token[ptr][0] <= m_data[3:0];
            i_token[ptr][1] <= m_data[7:4];
            i_token[ptr][2] <= m_data[11:8];
            i_token[ptr][3] <= m_data[15:12];
            i_token[ptr][4] <= m_data[19:16];
            i_token[ptr][5] <= m_data[23:20];
            i_token[ptr][6] <= m_data[27:24];
            i_token[ptr][7] <= m_data[31:28];
            // Store the average for this row (will be used in next cycle)
            previous_row_avg <= next_previous_row_avg;
        end

        // Apply RAT to previous row (if exists)
        if (rat_update_enable) begin
            for (int j = 0; j < 8; j++) begin
                if (i_token[ptr_1][j] < previous_row_avg) 
                      i_token[ptr_1][j] <= 0;
            end
        end
    end
end

//Calculate current row average
always_comb begin
    if (state == READ_INPUT_RAT) begin
        temp_sum = (m_data[3:0] + m_data[7:4] + m_data[11:8] + m_data[15:12] + m_data[19:16] + m_data[23:20] + m_data[27:24] + m_data[31:28]);
        next_previous_row_avg = temp_sum >> 3;
    end
    else 
        next_previous_row_avg = 0;
end

//---------------------------------------------------------------------
// MM_1: read WQ, WK, WV column
//---------------------------------------------------------------------
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (int i = 0; i < 8; i++) 
            temp_col[i] <= 0;
    end
    else if (state == MM_Q1 || state == MM_K1 || state == MM_V1) begin
        temp_col[0] <= m_data[3:0];
        temp_col[1] <= m_data[7:4];
        temp_col[2] <= m_data[11:8];
        temp_col[3] <= m_data[15:12];
        temp_col[4] <= m_data[19:16];
        temp_col[5] <= m_data[23:20];
        temp_col[6] <= m_data[27:24];
        temp_col[7] <= m_data[31:28];
    end
end

//---------------------------------------------------------------------
// MM_2, MM_3: multiply elements
//---------------------------------------------------------------------
assign a = ptr + 1;
assign b = ptr + 2;
assign c = ptr + 3;
assign d = ptr_1 + 1;
assign e = ptr_1 + 2;
assign f = ptr_1 + 3;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (int i = 0; i < 8; i++) begin
            product_0[i] <= 0;
            product_1[i] <= 0;
            product_2[i] <= 0;
            product_3[i] <= 0;
        end
    end
    else if (state == MM_Q2 || state == MM_K2 || state == MM_V2) begin
        for (int i = 0; i < 8; ++i) begin
            product_0[i] <= i_token[ptr][i] * temp_col[i];
            product_1[i] <= i_token[a][i] * temp_col[i];
            product_2[i] <= i_token[b][i] * temp_col[i];
            product_3[i] <= i_token[c][i] * temp_col[i];
        end
    end
    else if (state == MM_T1) begin
        for (int i = 0; i < 8; ++i) begin
            product_0[i] <= q[ptr][i][5:0] * k[ptrt][i][5:0];
            product_1[i] <= q[ptr][i][10:6] * k[ptrt][i][5:0];
            product_2[i] <= q[ptr][i][5:0] * k[ptrt][i][10:6];
            product_3[i] <= q[ptr][i][10:6] * k[ptrt][i][10:6];
        end
    end
    else if (state == MM_S1) begin
        product_0[0] <= score[ptr][5:0] * q[ptr][ptrt][5:0]; //q=v
        product_0[1] <= score[ptr][11:6] * q[ptr][ptrt][5:0];
        product_0[2] <= score[ptr][17:12] * q[ptr][ptrt][5:0];
        product_0[3] <= score[ptr][21:18] * q[ptr][ptrt][5:0];
        product_0[4] <= score[ptr][5:0] * q[ptr][ptrt][10:6];
        product_0[5] <= score[ptr][11:6] * q[ptr][ptrt][10:6];
        product_0[6] <= score[ptr][17:12] * q[ptr][ptrt][10:6];
        product_0[7] <= score[ptr][21:18] * q[ptr][ptrt][10:6];

        product_1[0] <= score[a][5:0] * q[a][ptrt][5:0];
        product_1[1] <= score[a][11:6] * q[a][ptrt][5:0];
        product_1[2] <= score[a][17:12] * q[a][ptrt][5:0];
        product_1[3] <= score[a][21:18] * q[a][ptrt][5:0];
        product_1[4] <= score[a][5:0] * q[a][ptrt][10:6];
        product_1[5] <= score[a][11:6] * q[a][ptrt][10:6];
        product_1[6] <= score[a][17:12] * q[a][ptrt][10:6];
        product_1[7] <= score[a][21:18] * q[a][ptrt][10:6];

        product_2[0] <= score[b][5:0] * q[b][ptrt][5:0];
        product_2[1] <= score[b][11:6] * q[b][ptrt][5:0];
        product_2[2] <= score[b][17:12] * q[b][ptrt][5:0];
        product_2[3] <= score[b][21:18] * q[b][ptrt][5:0];
        product_2[4] <= score[b][5:0] * q[b][ptrt][10:6];
        product_2[5] <= score[b][11:6] * q[b][ptrt][10:6];
        product_2[6] <= score[b][17:12] * q[b][ptrt][10:6];
        product_2[7] <= score[b][21:18] * q[b][ptrt][10:6];

        product_3[0] <= score[c][5:0] * q[c][ptrt][5:0];
        product_3[1] <= score[c][11:6] * q[c][ptrt][5:0];
        product_3[2] <= score[c][17:12] * q[c][ptrt][5:0];
        product_3[3] <= score[c][21:18] * q[c][ptrt][5:0];
        product_3[4] <= score[c][5:0] * q[c][ptrt][10:6];
        product_3[5] <= score[c][11:6] * q[c][ptrt][10:6];
        product_3[6] <= score[c][17:12] * q[c][ptrt][10:6];
        product_3[7] <= score[c][21:18] * q[c][ptrt][10:6];
    end
    else begin
        for (int i = 0; i < 8; i++) begin
            product_0[i] <= 0;
            product_1[i] <= 0;
            product_2[i] <= 0;
            product_3[i] <= 0;
        end
    end
end

assign sum_00 = product_0[0] + product_0[1] + product_0[2] + product_0[3];
assign sum_01 = product_0[4] + product_0[5] + product_0[6] + product_0[7];
assign sum_10 = product_1[0] + product_1[1] + product_1[2] + product_1[3];
assign sum_11 = product_1[4] + product_1[5] + product_1[6] + product_1[7];
assign sum_20 = product_2[0] + product_2[1] + product_2[2] + product_2[3];
assign sum_21 = product_2[4] + product_2[5] + product_2[6] + product_2[7];
assign sum_30 = product_3[0] + product_3[1] + product_3[2] + product_3[3];
assign sum_31 = product_3[4] + product_3[5] + product_3[6] + product_3[7];

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (int i = 0; i < 32; i++) begin
            for (int j = 0; j < 8; j++)
                q[i][j] <= 0;
        end
    end
    else if (product_sum_q) begin
        q[ptr_1][ptr_2] <= sum_00 + sum_01;
        q[d][ptr_2] <= sum_10 + sum_11;
        q[e][ptr_2] <= sum_20 + sum_21;
        q[f][ptr_2] <= sum_30 + sum_31;
    end
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (int i = 0; i < 32; i++) begin
            for (int j = 0; j < 8; j++)
                k[i][j] <= 0;
        end
    end
    else if (product_sum_k) begin
        k[ptr_1][ptr_2] <= sum_00 + sum_01;
        k[d][ptr_2] <= sum_10 + sum_11;
        k[e][ptr_2] <= sum_20 + sum_21;
        k[f][ptr_2] <= sum_30 + sum_31;
    end
end

//---------------------------------------------------------------------
// MM_T, MM_S multiplication
//---------------------------------------------------------------------
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (int i = 0; i < 5; i++) 
            t[i] <= 0;
    end
    else if (product_sum_t1) begin
        t[0] <= sum_00 + sum_01;
        t[1] <= sum_10 + sum_11;
        t[2] <= sum_20 + sum_21;
        t[3] <= sum_30 + sum_31;
    end
    else if (product_sum_s1) begin
        t[0] <= product_0[0] + product_1[0] + product_2[0] + product_3[0];
        t[1] <= product_0[1] + product_1[1] + product_2[1] + product_3[1] + product_0[4] + product_1[4] + product_2[4] + product_3[4];
        t[2] <= product_0[2] + product_1[2] + product_2[2] + product_3[2] + product_0[5] + product_1[5] + product_2[5] + product_3[5];
        t[3] <= product_0[3] + product_1[3] + product_2[3] + product_3[3] + product_0[6] + product_1[6] + product_2[6] + product_3[6];
        t[4] <= product_0[7] + product_1[7] + product_2[7] + product_3[7];
    end
    else begin
        for (int i = 0; i < 5; i++)
            t[i] <= 0;
    end
end

always_comb begin
    temp_score = 0;
    if (product_sum_t2) begin
        temp_s = (t[0] + ((t[1] + t[2]) << 6) + (t[3] << 12));
        temp_score = ((((s + temp_s) >> l) > temp_s) ? 0 : temp_s);
    end
    else if (product_sum_s2) 
        temp_s = (t[0] + (t[1] << 6) + (t[2] << 12) + (t[3] << 18) + (t[4] << 24));
    else
        temp_s = 0;
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (int i = 0; i < 32; i++) 
            score[i] <= 0;
        s <= 0;
    end
    else begin
        if (product_sum_t2) begin
            s <= s + temp_s;
            if(!product_sum_t1) 
                score[ptrt] <= temp_score;
        end
        else
            s <= 0;
    end
end

//---------------------------------------------------------------------
// MM_S multiplication
//---------------------------------------------------------------------
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (int i = 0; i < 32; i++) 
            o_token[i] <= 0;
    end
    else begin
        if (state == IDLE) begin
            for (int i = 0; i < 32; i++) 
                o_token[i] <= 0;
        end
        if (product_sum_s2) 
            o_token[ptr_2] <= o_token[ptr_2] + temp_s;
    end
end

//---------------------------------------------------------------------
// Pointer
//---------------------------------------------------------------------
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        //ptr <= 0;
        //ptrt <= 0;
        //ptr_1 <= 0;
        //ptr_2 <= 0;
        //product_sum_q <= 0;
        //product_sum_k <= 0;
        product_sum_t1 <= 0;
        product_sum_t2 <= 0;
        product_sum_s1 <= 0;
        product_sum_s2 <= 0;
    end
    else begin
        ptr <= next_ptr;
        ptrt <= next_ptrt;
        ptr_1 <= next_ptr_1;
        ptr_2 <= next_ptr_2;
        product_sum_q <= next_product_sum_q;
        product_sum_k <= next_product_sum_k;
        product_sum_t1 <= next_product_sum_t1;
        product_sum_t2 <= product_sum_t1;
        product_sum_s1 <= next_product_sum_s1;
        product_sum_s2 <= product_sum_s1;
    end
end

always_comb begin
    next_ptr = ptr;
    next_ptrt = ptrt;
    next_ptr_1 = ptr_1;
    next_ptr_2 = ptr_2;
    next_product_sum_q = 0;
    next_product_sum_k = 0;
    next_product_sum_t1 = 0;
    next_product_sum_s1 = 0;
    case (state)
        IDLE: begin
            next_ptr = 0;
            next_ptrt = 0;
        end

        READ_INPUT_RAT: begin
            if (mem_counter > 0) 
                next_ptr = mem_counter;
            next_ptr_1 = ptr;
        end

        MM_Q1: 
            next_ptr = 0;
        MM_Q2: begin
            next_product_sum_q = 1;
            next_ptr_1 = ptr;
            next_ptr_2 = ptrt;
            if ((next_state == MM_Q2) && (ptr + 4 < L)) 
                next_ptr = ptr + 4;
            if ((next_state == MM_Q1) && (ptr + 4 == L)) begin
                next_ptrt = ptrt + 1;
                next_ptr = 0;
            end
            if (next_state == MM_K1) begin
                next_ptr = 0;
                next_ptrt = 0;
            end
        end

        MM_K2: begin
            next_product_sum_k = 1;
            next_ptr_1 = ptr;
            next_ptr_2 = ptrt;
            if ((next_state == MM_K2) && (ptr + 4 < L)) 
                next_ptr = ptr + 4;
            if ((next_state == MM_K1) && (ptr + 4 == L)) begin
                next_ptrt = ptrt + 1;
                next_ptr = 0;
            end
        end
        MM_K3: begin
            next_ptr = 0;
            next_ptrt = 0;
        end
        MM_T1: begin
            next_product_sum_t1 = 1;
            if(ptr == L - 1)
                next_ptr = 0;
            else
                next_ptr = a;
            next_ptr_1 = ptr;
            next_ptr_2 = ptr_1;
        end
        MM_T2: begin
            if (next_state == MM_T1) 
                next_ptrt = ptrt + 1;
            else 
                next_ptrt = ptrt;
            if (next_state == MM_V1) begin
                next_ptr = 0;
                next_ptrt = 0;
            end
        end
        MM_V2: begin
            next_product_sum_q = 1;
            next_ptr_1 = ptr;
            next_ptr_2 = ptrt;
            if ((next_state == MM_V2) && (ptr + 4 < L)) 
                next_ptr = ptr + 4;
            
            if ((next_state == MM_V1) && (ptr + 4 == L)) begin
                next_ptrt = ptrt + 1;
                next_ptr = 0;
            end
            if(next_state == MM_S1) begin
                next_ptr = 0;
                next_ptrt = 0;
            end
        end

        MM_S1: begin
            next_ptr_1 = ptrt;
            next_product_sum_s1 = 1;
            //next_ptr_2 = ptr_1;
            if (next_state == MM_S1)begin
                if(ptr + 4 < L)
                    next_ptr = ptr + 4;
                else begin
                    next_ptr = 0;
                    next_ptrt = ptrt + 1;
                end
            end
            if(next_state == OUT)
                next_ptr = 1;
        end

        OUT: begin
            if (ptr == 7)
                next_ptr = 0;
            else 
                next_ptr = a;
        end
    endcase

    if(product_sum_s1) 
        next_ptr_2 = ptr_1;
end

//---------------------------------------------------------------------
// OUTPUT GENERATION
//---------------------------------------------------------------------
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        o_valid <= 0;
        o_data <= 0;
    end       
    else if (state == OUT) begin
        o_valid <= 1;
        o_data <= o_token[ptr];
        if (ptr > 7) 
            o_valid <= 0;
    end
    else if (next_state == OUT) begin
        o_valid <= 1;
        o_data <= o_token[0];
    end
    else
        o_valid <= 0;
end

endmodule