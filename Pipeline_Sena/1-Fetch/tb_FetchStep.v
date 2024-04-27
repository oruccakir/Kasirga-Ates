`timescale 1ns / 1ps


module tb_fetchstep();
    reg clk_i; // Clock input
    reg rst_i; // Reset input

    // buyruk önbelleği <> getir
    reg bellek_gecerli_i;
    reg [31:0] bellek_deger_i;
    wire bellek_istek_o;
    wire [31:0] bellek_ps_o;
    

    // getir <> coz
    reg coz_bos_i;
    wire [31:0] coz_buyruk_o;
    wire coz_buyruk_gecerli_o;
    wire [31:0] coz_ps_o;

    //dallanma birimi (yurut) <> getir
    reg [31:0] yurut_ps_i;
    reg yurut_ps_gecerli_i;
    reg yurut_atladi_i;
    
    FetchStep fs(
        .clk_i              (clk_i),
        .rst_i              (rst_i),
                   
        .bellek_gecerli_i   (bellek_gecerli_i),
        .bellek_deger_i     (bellek_deger_i),
        .bellek_istek_o     (bellek_istek_o),
        .bellek_ps_o        (bellek_ps_o),
    
        .coz_bos_i          (coz_bos_i),
        .coz_buyruk_o       (coz_buyruk_o),
        .coz_buyruk_gecerli_o(coz_buyruk_gecerli_o),
        .coz_ps_o           (coz_ps_o),
                   
        .yurut_ps_i         (yurut_ps_i),
        .yurut_ps_gecerli_i (yurut_ps_gecerli_i),
        .yurut_atladi_i     (yurut_atladi_i)); 
            
    always begin
        clk_i =~clk_i;
        #5;
    end     

    
    initial begin
        rst_i = 1'b1;
        rst_i = 1'b0;
        clk_i = 1'b0;
        

        //durum 1
        bellek_gecerli_i = 1'b0;
        bellek_deger_i = 10; 
        coz_bos_i = 1'b1;
        yurut_ps_i = 32'd0;
        yurut_ps_gecerli_i = 1'b0;
        yurut_atladi_i = 1'b0;
        
        #10;
        if (bellek_istek_o == 1 && bellek_ps_o == 0 && coz_buyruk_gecerli_o == 0) begin
            $display("test 1 passed");
        end
        else begin
            $display(bellek_istek_o);
            $display(bellek_ps_o);
            $display(coz_buyruk_o);
            $display(bellek_deger_i);
            $display(coz_buyruk_gecerli_o);
            $display(coz_ps_o);
        end
        //durum 2
        bellek_gecerli_i = 1'b0;
        bellek_deger_i = 10; 
        coz_bos_i = 1'b1;
        yurut_ps_i = 32'd0;
        yurut_ps_gecerli_i = 1'b0;
        yurut_atladi_i = 1'b0;
        
        #10;
        if (bellek_istek_o == 1 && bellek_ps_o == 0 && coz_buyruk_gecerli_o == 0) begin
            $display("test 2 passed");
        end
        else begin
            $display(bellek_istek_o);
            $display(bellek_ps_o);
            $display(coz_buyruk_o);
            $display(bellek_deger_i);
            $display(coz_buyruk_gecerli_o);
            $display(coz_ps_o);
        end

        //durum 3
        bellek_gecerli_i = 1'b1;
        bellek_deger_i = 10; 
        coz_bos_i = 1'b1;
        yurut_ps_i = 32'd0;
        yurut_ps_gecerli_i = 1'b0;
        yurut_atladi_i = 1'b0;
        
        #10;
        if (bellek_istek_o == 1 && bellek_ps_o == 4 && coz_buyruk_o == 10 && coz_buyruk_gecerli_o == 1 && coz_ps_o == 0) begin
            $display("test 3 passed");
        end
        else begin
            $display(bellek_istek_o);
            $display(bellek_ps_o);
            $display(coz_buyruk_o);
            $display(bellek_deger_i);
            $display(coz_buyruk_gecerli_o);
            $display(coz_ps_o);
        end


        //durum 4
        bellek_gecerli_i = 1'b0;
        bellek_deger_i = 30; 
        coz_bos_i = 1'b0;
        yurut_ps_i = 696;
        yurut_ps_gecerli_i = 1'b1;
        yurut_atladi_i = 1'b0;
        
        #10;
        if (bellek_istek_o ==  1 && bellek_ps_o == 696 && coz_buyruk_gecerli_o == 0 ) begin
            $display("test 4 passed");
        end
        else begin
            $display(bellek_istek_o);
            $display(bellek_ps_o);
            $display(coz_buyruk_o);
            $display(bellek_deger_i);
            $display(coz_buyruk_gecerli_o);
            $display(coz_ps_o);
        end
        
        
        //durum 5
        bellek_gecerli_i = 1'b1;
        bellek_deger_i = 90; 
        coz_bos_i = 1'b1;
        yurut_ps_i = 696;
        yurut_ps_gecerli_i = 1'b0;
        yurut_atladi_i = 1'b1;
        
        #10;
        if (bellek_istek_o == 1 && bellek_ps_o == 700 && coz_buyruk_o == 90 && coz_buyruk_gecerli_o == 1 && coz_ps_o == 696) begin
            $display("test 5 passed");
        end
        else begin
            $display(bellek_istek_o);
            $display(bellek_ps_o);
            $display(coz_buyruk_o);
            $display(bellek_deger_i);
            $display(coz_buyruk_gecerli_o);
            $display(coz_ps_o);
        end
        
        //durum 6
        bellek_gecerli_i = 1'b0;
        bellek_deger_i = 56; 
        coz_bos_i = 1'b0;
        yurut_ps_i = 32'b11111111_10111000_11111111_00010011;
        yurut_ps_gecerli_i = 1'b0;
        yurut_atladi_i = 1'b0;
        
        #10;
        if (bellek_istek_o == 0 && bellek_ps_o == 700 && coz_buyruk_o == 90 && coz_buyruk_gecerli_o == 0 && coz_ps_o == 696) begin
            $display("test 6 passed");
        end
        else begin
            $display(bellek_istek_o);
            $display(bellek_ps_o);
            $display(coz_buyruk_o);
            $display(bellek_deger_i);
            $display(coz_buyruk_gecerli_o);
            $display(coz_ps_o);
        end

       

        

        





        $finish;
    end
endmodule