module division_unit_tb;

    reg clk_i_tb;         // Clock input
    reg rst_i_tb;         // Reset input
    reg enable_i_tb;       // Enable input
    reg [3:0] islem_i_tb; // Operation input
    reg [31:0] bolunen_i_tb; // Operand 1 input
    reg [31:0] bolen_i_tb;   // Operand 2 input
    wire [31:0] sonuc_o_tb;  // Result output
    wire bitti_o_tb;         // Completion output

    // Instantiate the unit under test (UUT)
    division_unit uut (
        .clk_i(clk_i_tb),
        .rst_i(rst_i_tb),
        .enable_i(enable_i_tb),
        .islem_i(islem_i_tb),
        .bolunen_i(bolunen_i_tb),
        .bolen_i(bolen_i_tb),
        .sonuc_o(sonuc_o_tb),
        .bitti_o(bitti_o_tb)

    );

    // Clock generation
    initial begin
        clk_i_tb = 0;
        forever #1 clk_i_tb = ~clk_i_tb;
    end
    // Test case - 0'a bölme gibi  kýsýmlar test edilecek
    initial begin
        enable_i_tb = 1'b1;


        //DIVU
        bolunen_i_tb = 32'd15; 
        bolen_i_tb   = 32'd4;    
        islem_i_tb   = `INT_DIVU;
        #170;

        bolunen_i_tb = 32'd25; 
        bolen_i_tb   = 32'd5;    
        islem_i_tb   = `INT_DIVU;
        #70;

        bolunen_i_tb = 32'd3; 
        bolen_i_tb   = 32'd6;    
        islem_i_tb   = `INT_DIVU;
        #70;

        bolunen_i_tb = 32'd3; 
        bolen_i_tb   = 32'd1;    
        islem_i_tb   = `INT_DIVU;
        #70;
        
        bolunen_i_tb = 32'd15; 
        bolen_i_tb   = 32'd13;    
        islem_i_tb   = `INT_DIVU;
        #170;

        bolunen_i_tb = 32'd25; 
        bolen_i_tb   = 32'd7;    
        islem_i_tb   = `INT_DIVU;
        #70;

        bolunen_i_tb = 32'd6; 
        bolen_i_tb   = 32'd6;    
        islem_i_tb   = `INT_DIVU;
        #70;

        bolunen_i_tb = 32'd3; 
        bolen_i_tb   = 32'd3;    
        islem_i_tb   = `INT_DIVU;
        #70;


        //REMU
        bolunen_i_tb = 32'd17; 
        bolen_i_tb   = 32'd4;    
        islem_i_tb   = `INT_REMU;
        #70;

        bolunen_i_tb = 32'd25; 
        bolen_i_tb   = 32'd5;    
        islem_i_tb   = `INT_REMU;
        #70;

        bolunen_i_tb = 32'd3; 
        bolen_i_tb   = 32'd6;    
        islem_i_tb   = `INT_REMU;
        #70;

        bolunen_i_tb = 32'd3; 
        bolen_i_tb   = 32'd1;    
        islem_i_tb   = `INT_REMU;
        #70;


        //DIV
        bolunen_i_tb = 32'd15; 
        bolen_i_tb   = 32'd4;    
        islem_i_tb   = `INT_DIV;
        #70;
        
        bolunen_i_tb = 32'd21; 
        bolen_i_tb   = 32'd8;    
        islem_i_tb   = `INT_DIV;
        #70;
        
        bolunen_i_tb = -32'd15; 
        bolen_i_tb   =  32'd4;   
        islem_i_tb   = `INT_DIV;
        #70;
        
        bolunen_i_tb = -32'd21;
        bolen_i_tb   =  32'd8;    
        islem_i_tb   = `INT_DIV;
        #70;
        
        bolunen_i_tb =  32'd15; 
        bolen_i_tb   = -32'd4;   
        islem_i_tb   = `INT_DIV;
        #70;
        
        bolunen_i_tb =  32'd21; 
        bolen_i_tb   = -32'd8;   
        islem_i_tb   = `INT_DIV;
        #70;
        
        bolunen_i_tb = -32'd15; 
        bolen_i_tb   = -32'd4;    
        islem_i_tb   = `INT_DIV;
        #70;
        
        bolunen_i_tb = -32'd21; 
        bolen_i_tb   = -32'd8;    
        islem_i_tb   = `INT_DIV;
        #70;
        
        
        //REM
        bolunen_i_tb = 32'd15; 
        bolen_i_tb   = 32'd4;    
        islem_i_tb   = `INT_REM;
        #70;
        
        bolunen_i_tb = 32'd21; 
        bolen_i_tb   = 32'd8;    
        islem_i_tb   = `INT_REM;
        #70;
        
        bolunen_i_tb = -32'd15; 
        bolen_i_tb   =  32'd4;   
        islem_i_tb   = `INT_REM;
        #70;
       
        bolunen_i_tb = -32'd21;
        bolen_i_tb   =  32'd8;    
        islem_i_tb   = `INT_REM;
        #70;
        
        bolunen_i_tb =  32'd15; 
        bolen_i_tb   = -32'd4;   
        islem_i_tb   = `INT_REM;
        #70;
        
        bolunen_i_tb =  32'd21; 
        bolen_i_tb   = -32'd8;   
        islem_i_tb   = `INT_REM;
        #70;
        
        bolunen_i_tb = -32'd15; 
        bolen_i_tb   = -32'd4;    
        islem_i_tb   = `INT_REM;
        #70;
        
        bolunen_i_tb = -32'd21; 
        bolen_i_tb   = -32'd8;    
        islem_i_tb   = `INT_REM;
        #70;
    
    end
 endmodule