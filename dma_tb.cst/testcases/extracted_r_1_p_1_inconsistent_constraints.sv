class c_1_1;
    randc bit[31:0] src; // rand_mode = ON 
    randc bit[31:0] dst; // rand_mode = ON 
    rand bit[31:0] len; // rand_mode = ON 

    constraint ad_this    // (constraint_mode = ON) (./rtl/inc/test_data_generator.svh:327)
    {
       (src >= 32'h11000000);
       (src <= 32'h11003fff);
       (dst >= 32'h14000000);
       (dst <= 32'h1400ffff);
       ((src + len) <= 32'h10003fff);
       ((dst + len) <= 32'h14003fff);
       ((src % 32) == 0);
       ((dst % 32) == 0);
       (len <= 32'h4000);
    }
endclass

program p_1_1;
    c_1_1 obj;
    string randState;

    initial
        begin
            obj = new;
            randState = "z10zx0x0x011xx1xz0xzz1xz0zxz0000zxxzxxzzxzxzzzxxxxzxxzxxxxzzzzzz";
            obj.set_randstate(randState);
            obj.randomize();
        end
endprogram
