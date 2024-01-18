`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/04/09 12:02:18
// Design Name: 
// Module Name: commonclkBRAMfifo_to_asicfifo_wrapper
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module commonclkBRAMfifo_to_asicfifo_wrapper
#(
    parameter WIDTH = 4,
    parameter DEPTH = 256,
    parameter OUTPUT_DELAY = 3,
    parameter EMAA = 3'd2,
    parameter EMAWA = 2'd0,
    parameter EMAB = 3'd2,
    parameter EMAWB = 2'd0,
    parameter RET1N = 1'd1,
    
    parameter MANUAL_CONFIG = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
    
    parameter ALMOST_FULL = 1,
    parameter ALMOST_EMPTY = 1,
    parameter NEED_DATACOUNT = 1'd0,
    parameter FIRST_WORD_FALL_THROUGH = 1'd0,
    
    parameter ADDRESS_WIDTH = $clog2(DEPTH),
    parameter DATACOUNT_WIDTH = $clog2(DEPTH)
)(
    input                           clk,
    input                           srst,
    input   [WIDTH-1:0]             din,
    input                           wr_en,
    input                           rd_en,
    output  [WIDTH-1:0]             dout,
    output                          full,
    output                          empty,
    output  [DATACOUNT_WIDTH-1:0]   data_count,
    
    output                          almost_full,
    output                          almost_empty,
    output                          half_full
    );
    
localparam SMIC_DRAM_MUL = DEPTH<=0?(-1):(DEPTH<=32?1:(DEPTH<=512?2:(DEPTH<=1024?4:(-1))));
localparam SMIC_DRAM_DEPTH_MUL1 = DEPTH<=0?(-1):(DEPTH<=4?4:(DEPTH<=6?6:(DEPTH<=8?8:(DEPTH<=10?10:(DEPTH<=12?12:(DEPTH<=14?14:(DEPTH<=16?16:(DEPTH<=18?18:(DEPTH<=20?20:(DEPTH<=22?22:(DEPTH<=24?24:(DEPTH<=26?26:(DEPTH<=28?28:(DEPTH<=30?30:(DEPTH<=32?32:(DEPTH<=34?34:(DEPTH<=36?36:(DEPTH<=38?38:(DEPTH<=40?40:(DEPTH<=42?42:(DEPTH<=44?44:(DEPTH<=46?46:(DEPTH<=48?48:(DEPTH<=50?50:(DEPTH<=52?52:(DEPTH<=54?54:(DEPTH<=56?56:(DEPTH<=58?58:(DEPTH<=60?60:(DEPTH<=62?62:(DEPTH<=64?64:(DEPTH<=66?66:(DEPTH<=68?68:(DEPTH<=70?70:(DEPTH<=72?72:(DEPTH<=74?74:(DEPTH<=76?76:(DEPTH<=78?78:(DEPTH<=80?80:(DEPTH<=82?82:(DEPTH<=84?84:(DEPTH<=86?86:(DEPTH<=88?88:(DEPTH<=90?90:(DEPTH<=92?92:(DEPTH<=94?94:(DEPTH<=96?96:(DEPTH<=98?98:(DEPTH<=100?100:(DEPTH<=102?102:(DEPTH<=104?104:(DEPTH<=106?106:(DEPTH<=108?108:(DEPTH<=110?110:(DEPTH<=112?112:(DEPTH<=114?114:(DEPTH<=116?116:(DEPTH<=118?118:(DEPTH<=120?120:(DEPTH<=122?122:(DEPTH<=124?124:(DEPTH<=126?126:(DEPTH<=128?128:(DEPTH<=130?130:(DEPTH<=132?132:(DEPTH<=134?134:(DEPTH<=136?136:(DEPTH<=138?138:(DEPTH<=140?140:(DEPTH<=142?142:(DEPTH<=144?144:(DEPTH<=146?146:(DEPTH<=148?148:(DEPTH<=150?150:(DEPTH<=152?152:(DEPTH<=154?154:(DEPTH<=156?156:(DEPTH<=158?158:(DEPTH<=160?160:(DEPTH<=162?162:(DEPTH<=164?164:(DEPTH<=166?166:(DEPTH<=168?168:(DEPTH<=170?170:(DEPTH<=172?172:(DEPTH<=174?174:(DEPTH<=176?176:(DEPTH<=178?178:(DEPTH<=180?180:(DEPTH<=182?182:(DEPTH<=184?184:(DEPTH<=186?186:(DEPTH<=188?188:(DEPTH<=190?190:(DEPTH<=192?192:(DEPTH<=194?194:(DEPTH<=196?196:(DEPTH<=198?198:(DEPTH<=200?200:(DEPTH<=202?202:(DEPTH<=204?204:(DEPTH<=206?206:(DEPTH<=208?208:(DEPTH<=210?210:(DEPTH<=212?212:(DEPTH<=214?214:(DEPTH<=216?216:(DEPTH<=218?218:(DEPTH<=220?220:(DEPTH<=222?222:(DEPTH<=224?224:(DEPTH<=226?226:(DEPTH<=228?228:(DEPTH<=230?230:(DEPTH<=232?232:(DEPTH<=234?234:(DEPTH<=236?236:(DEPTH<=238?238:(DEPTH<=240?240:(DEPTH<=242?242:(DEPTH<=244?244:(DEPTH<=246?246:(DEPTH<=248?248:(DEPTH<=250?250:(DEPTH<=252?252:(DEPTH<=254?254:(DEPTH<=256?256:(-1))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))));
localparam SMIC_DRAM_DEPTH_MUL2 = DEPTH<=0?(-1):(DEPTH<=32?32:(DEPTH<=36?36:(DEPTH<=40?40:(DEPTH<=44?44:(DEPTH<=48?48:(DEPTH<=52?52:(DEPTH<=56?56:(DEPTH<=60?60:(DEPTH<=64?64:(DEPTH<=68?68:(DEPTH<=72?72:(DEPTH<=76?76:(DEPTH<=80?80:(DEPTH<=84?84:(DEPTH<=88?88:(DEPTH<=92?92:(DEPTH<=96?96:(DEPTH<=100?100:(DEPTH<=104?104:(DEPTH<=108?108:(DEPTH<=112?112:(DEPTH<=116?116:(DEPTH<=120?120:(DEPTH<=124?124:(DEPTH<=128?128:(DEPTH<=132?132:(DEPTH<=136?136:(DEPTH<=140?140:(DEPTH<=144?144:(DEPTH<=148?148:(DEPTH<=152?152:(DEPTH<=156?156:(DEPTH<=160?160:(DEPTH<=164?164:(DEPTH<=168?168:(DEPTH<=172?172:(DEPTH<=176?176:(DEPTH<=180?180:(DEPTH<=184?184:(DEPTH<=188?188:(DEPTH<=192?192:(DEPTH<=196?196:(DEPTH<=200?200:(DEPTH<=204?204:(DEPTH<=208?208:(DEPTH<=212?212:(DEPTH<=216?216:(DEPTH<=220?220:(DEPTH<=224?224:(DEPTH<=228?228:(DEPTH<=232?232:(DEPTH<=236?236:(DEPTH<=240?240:(DEPTH<=244?244:(DEPTH<=248?248:(DEPTH<=252?252:(DEPTH<=256?256:(DEPTH<=260?260:(DEPTH<=264?264:(DEPTH<=268?268:(DEPTH<=272?272:(DEPTH<=276?276:(DEPTH<=280?280:(DEPTH<=284?284:(DEPTH<=288?288:(DEPTH<=292?292:(DEPTH<=296?296:(DEPTH<=300?300:(DEPTH<=304?304:(DEPTH<=308?308:(DEPTH<=312?312:(DEPTH<=316?316:(DEPTH<=320?320:(DEPTH<=324?324:(DEPTH<=328?328:(DEPTH<=332?332:(DEPTH<=336?336:(DEPTH<=340?340:(DEPTH<=344?344:(DEPTH<=348?348:(DEPTH<=352?352:(DEPTH<=356?356:(DEPTH<=360?360:(DEPTH<=364?364:(DEPTH<=368?368:(DEPTH<=372?372:(DEPTH<=376?376:(DEPTH<=380?380:(DEPTH<=384?384:(DEPTH<=388?388:(DEPTH<=392?392:(DEPTH<=396?396:(DEPTH<=400?400:(DEPTH<=404?404:(DEPTH<=408?408:(DEPTH<=412?412:(DEPTH<=416?416:(DEPTH<=420?420:(DEPTH<=424?424:(DEPTH<=428?428:(DEPTH<=432?432:(DEPTH<=436?436:(DEPTH<=440?440:(DEPTH<=444?444:(DEPTH<=448?448:(DEPTH<=452?452:(DEPTH<=456?456:(DEPTH<=460?460:(DEPTH<=464?464:(DEPTH<=468?468:(DEPTH<=472?472:(DEPTH<=476?476:(DEPTH<=480?480:(DEPTH<=484?484:(DEPTH<=488?488:(DEPTH<=492?492:(DEPTH<=496?496:(DEPTH<=500?500:(DEPTH<=504?504:(DEPTH<=508?508:(DEPTH<=512?512:(-1))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))));
localparam SMIC_DRAM_DEPTH_MUL4 = DEPTH<=0?(-1):(DEPTH<=64?64:(DEPTH<=72?72:(DEPTH<=80?80:(DEPTH<=88?88:(DEPTH<=96?96:(DEPTH<=104?104:(DEPTH<=112?112:(DEPTH<=120?120:(DEPTH<=128?128:(DEPTH<=136?136:(DEPTH<=144?144:(DEPTH<=152?152:(DEPTH<=160?160:(DEPTH<=168?168:(DEPTH<=176?176:(DEPTH<=184?184:(DEPTH<=192?192:(DEPTH<=200?200:(DEPTH<=208?208:(DEPTH<=216?216:(DEPTH<=224?224:(DEPTH<=232?232:(DEPTH<=240?240:(DEPTH<=248?248:(DEPTH<=256?256:(DEPTH<=264?264:(DEPTH<=272?272:(DEPTH<=280?280:(DEPTH<=288?288:(DEPTH<=296?296:(DEPTH<=304?304:(DEPTH<=312?312:(DEPTH<=320?320:(DEPTH<=328?328:(DEPTH<=336?336:(DEPTH<=344?344:(DEPTH<=352?352:(DEPTH<=360?360:(DEPTH<=368?368:(DEPTH<=376?376:(DEPTH<=384?384:(DEPTH<=392?392:(DEPTH<=400?400:(DEPTH<=408?408:(DEPTH<=416?416:(DEPTH<=424?424:(DEPTH<=432?432:(DEPTH<=440?440:(DEPTH<=448?448:(DEPTH<=456?456:(DEPTH<=464?464:(DEPTH<=472?472:(DEPTH<=480?480:(DEPTH<=488?488:(DEPTH<=496?496:(DEPTH<=504?504:(DEPTH<=512?512:(DEPTH<=520?520:(DEPTH<=528?528:(DEPTH<=536?536:(DEPTH<=544?544:(DEPTH<=552?552:(DEPTH<=560?560:(DEPTH<=568?568:(DEPTH<=576?576:(DEPTH<=584?584:(DEPTH<=592?592:(DEPTH<=600?600:(DEPTH<=608?608:(DEPTH<=616?616:(DEPTH<=624?624:(DEPTH<=632?632:(DEPTH<=640?640:(DEPTH<=648?648:(DEPTH<=656?656:(DEPTH<=664?664:(DEPTH<=672?672:(DEPTH<=680?680:(DEPTH<=688?688:(DEPTH<=696?696:(DEPTH<=704?704:(DEPTH<=712?712:(DEPTH<=720?720:(DEPTH<=728?728:(DEPTH<=736?736:(DEPTH<=744?744:(DEPTH<=752?752:(DEPTH<=760?760:(DEPTH<=768?768:(DEPTH<=776?776:(DEPTH<=784?784:(DEPTH<=792?792:(DEPTH<=800?800:(DEPTH<=808?808:(DEPTH<=816?816:(DEPTH<=824?824:(DEPTH<=832?832:(DEPTH<=840?840:(DEPTH<=848?848:(DEPTH<=856?856:(DEPTH<=864?864:(DEPTH<=872?872:(DEPTH<=880?880:(DEPTH<=888?888:(DEPTH<=896?896:(DEPTH<=904?904:(DEPTH<=912?912:(DEPTH<=920?920:(DEPTH<=928?928:(DEPTH<=936?936:(DEPTH<=944?944:(DEPTH<=952?952:(DEPTH<=960?960:(DEPTH<=968?968:(DEPTH<=976?976:(DEPTH<=984?984:(DEPTH<=992?992:(DEPTH<=1000?1000:(DEPTH<=1008?1008:(DEPTH<=1016?1016:(DEPTH<=1024?1024:(-1))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))));
localparam SMIC_DRAM_WIDTH_MUL1 = WIDTH<=0?(-1):(WIDTH<=4?4:(WIDTH<=6?6:(WIDTH<=8?8:(WIDTH<=10?10:(WIDTH<=12?12:(WIDTH<=14?14:(WIDTH<=16?16:(WIDTH<=18?18:(WIDTH<=20?20:(WIDTH<=22?22:(WIDTH<=24?24:(WIDTH<=26?26:(WIDTH<=28?28:(WIDTH<=30?30:(WIDTH<=32?32:(WIDTH<=34?34:(WIDTH<=36?36:(WIDTH<=38?38:(WIDTH<=40?40:(WIDTH<=42?42:(WIDTH<=44?44:(WIDTH<=46?46:(WIDTH<=48?48:(WIDTH<=50?50:(WIDTH<=52?52:(WIDTH<=54?54:(WIDTH<=56?56:(WIDTH<=58?58:(WIDTH<=60?60:(WIDTH<=62?62:(WIDTH<=64?64:(WIDTH<=66?66:(WIDTH<=68?68:(WIDTH<=70?70:(WIDTH<=72?72:(WIDTH<=74?74:(WIDTH<=76?76:(WIDTH<=78?78:(WIDTH<=80?80:(WIDTH<=82?82:(WIDTH<=84?84:(WIDTH<=86?86:(WIDTH<=88?88:(WIDTH<=90?90:(WIDTH<=92?92:(WIDTH<=94?94:(WIDTH<=96?96:(WIDTH<=98?98:(WIDTH<=100?100:(WIDTH<=102?102:(WIDTH<=104?104:(WIDTH<=106?106:(WIDTH<=108?108:(WIDTH<=110?110:(WIDTH<=112?112:(WIDTH<=114?114:(WIDTH<=116?116:(WIDTH<=118?118:(WIDTH<=120?120:(WIDTH<=122?122:(WIDTH<=124?124:(WIDTH<=126?126:(WIDTH<=128?128:(WIDTH<=130?130:(WIDTH<=132?132:(WIDTH<=134?134:(WIDTH<=136?136:(WIDTH<=138?138:(WIDTH<=140?140:(WIDTH<=142?142:(WIDTH<=144?144:(WIDTH<=146?146:(WIDTH<=148?148:(WIDTH<=150?150:(WIDTH<=152?152:(WIDTH<=154?154:(WIDTH<=156?156:(WIDTH<=158?158:(WIDTH<=160?160:(-1))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))));
localparam SMIC_DRAM_WIDTH_MUL2 = WIDTH<=0?(-1):(WIDTH<=4?4:(WIDTH<=5?5:(WIDTH<=6?6:(WIDTH<=7?7:(WIDTH<=8?8:(WIDTH<=9?9:(WIDTH<=10?10:(WIDTH<=11?11:(WIDTH<=12?12:(WIDTH<=13?13:(WIDTH<=14?14:(WIDTH<=15?15:(WIDTH<=16?16:(WIDTH<=17?17:(WIDTH<=18?18:(WIDTH<=19?19:(WIDTH<=20?20:(WIDTH<=21?21:(WIDTH<=22?22:(WIDTH<=23?23:(WIDTH<=24?24:(WIDTH<=25?25:(WIDTH<=26?26:(WIDTH<=27?27:(WIDTH<=28?28:(WIDTH<=29?29:(WIDTH<=30?30:(WIDTH<=31?31:(WIDTH<=32?32:(WIDTH<=33?33:(WIDTH<=34?34:(WIDTH<=35?35:(WIDTH<=36?36:(WIDTH<=37?37:(WIDTH<=38?38:(WIDTH<=39?39:(WIDTH<=40?40:(WIDTH<=41?41:(WIDTH<=42?42:(WIDTH<=43?43:(WIDTH<=44?44:(WIDTH<=45?45:(WIDTH<=46?46:(WIDTH<=47?47:(WIDTH<=48?48:(WIDTH<=49?49:(WIDTH<=50?50:(WIDTH<=51?51:(WIDTH<=52?52:(WIDTH<=53?53:(WIDTH<=54?54:(WIDTH<=55?55:(WIDTH<=56?56:(WIDTH<=57?57:(WIDTH<=58?58:(WIDTH<=59?59:(WIDTH<=60?60:(WIDTH<=61?61:(WIDTH<=62?62:(WIDTH<=63?63:(WIDTH<=64?64:(WIDTH<=65?65:(WIDTH<=66?66:(WIDTH<=67?67:(WIDTH<=68?68:(WIDTH<=69?69:(WIDTH<=70?70:(WIDTH<=71?71:(WIDTH<=72?72:(WIDTH<=73?73:(WIDTH<=74?74:(WIDTH<=75?75:(WIDTH<=76?76:(WIDTH<=77?77:(WIDTH<=78?78:(WIDTH<=79?79:(WIDTH<=80?80:(WIDTH<=81?81:(WIDTH<=82?82:(WIDTH<=83?83:(WIDTH<=84?84:(WIDTH<=85?85:(WIDTH<=86?86:(WIDTH<=87?87:(WIDTH<=88?88:(WIDTH<=89?89:(WIDTH<=90?90:(WIDTH<=91?91:(WIDTH<=92?92:(WIDTH<=93?93:(WIDTH<=94?94:(WIDTH<=95?95:(WIDTH<=96?96:(WIDTH<=97?97:(WIDTH<=98?98:(WIDTH<=99?99:(WIDTH<=100?100:(WIDTH<=101?101:(WIDTH<=102?102:(WIDTH<=103?103:(WIDTH<=104?104:(WIDTH<=105?105:(WIDTH<=106?106:(WIDTH<=107?107:(WIDTH<=108?108:(WIDTH<=109?109:(WIDTH<=110?110:(WIDTH<=111?111:(WIDTH<=112?112:(WIDTH<=113?113:(WIDTH<=114?114:(WIDTH<=115?115:(WIDTH<=116?116:(WIDTH<=117?117:(WIDTH<=118?118:(WIDTH<=119?119:(WIDTH<=120?120:(WIDTH<=121?121:(WIDTH<=122?122:(WIDTH<=123?123:(WIDTH<=124?124:(WIDTH<=125?125:(WIDTH<=126?126:(WIDTH<=127?127:(WIDTH<=128?128:(WIDTH<=129?129:(WIDTH<=130?130:(WIDTH<=131?131:(WIDTH<=132?132:(WIDTH<=133?133:(WIDTH<=134?134:(WIDTH<=135?135:(WIDTH<=136?136:(WIDTH<=137?137:(WIDTH<=138?138:(WIDTH<=139?139:(WIDTH<=140?140:(WIDTH<=141?141:(WIDTH<=142?142:(WIDTH<=143?143:(WIDTH<=144?144:(WIDTH<=145?145:(WIDTH<=146?146:(WIDTH<=147?147:(WIDTH<=148?148:(WIDTH<=149?149:(WIDTH<=150?150:(WIDTH<=151?151:(WIDTH<=152?152:(WIDTH<=153?153:(WIDTH<=154?154:(WIDTH<=155?155:(WIDTH<=156?156:(WIDTH<=157?157:(WIDTH<=158?158:(WIDTH<=159?159:(WIDTH<=160?160:(-1))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))));
localparam SMIC_DRAM_WIDTH_MUL4 = WIDTH<=0?(-1):(WIDTH<=4?4:(WIDTH<=5?5:(WIDTH<=6?6:(WIDTH<=7?7:(WIDTH<=8?8:(WIDTH<=9?9:(WIDTH<=10?10:(WIDTH<=11?11:(WIDTH<=12?12:(WIDTH<=13?13:(WIDTH<=14?14:(WIDTH<=15?15:(WIDTH<=16?16:(WIDTH<=17?17:(WIDTH<=18?18:(WIDTH<=19?19:(WIDTH<=20?20:(WIDTH<=21?21:(WIDTH<=22?22:(WIDTH<=23?23:(WIDTH<=24?24:(WIDTH<=25?25:(WIDTH<=26?26:(WIDTH<=27?27:(WIDTH<=28?28:(WIDTH<=29?29:(WIDTH<=30?30:(WIDTH<=31?31:(WIDTH<=32?32:(WIDTH<=33?33:(WIDTH<=34?34:(WIDTH<=35?35:(WIDTH<=36?36:(WIDTH<=37?37:(WIDTH<=38?38:(WIDTH<=39?39:(WIDTH<=40?40:(WIDTH<=41?41:(WIDTH<=42?42:(WIDTH<=43?43:(WIDTH<=44?44:(WIDTH<=45?45:(WIDTH<=46?46:(WIDTH<=47?47:(WIDTH<=48?48:(WIDTH<=49?49:(WIDTH<=50?50:(WIDTH<=51?51:(WIDTH<=52?52:(WIDTH<=53?53:(WIDTH<=54?54:(WIDTH<=55?55:(WIDTH<=56?56:(WIDTH<=57?57:(WIDTH<=58?58:(WIDTH<=59?59:(WIDTH<=60?60:(WIDTH<=61?61:(WIDTH<=62?62:(WIDTH<=63?63:(WIDTH<=64?64:(WIDTH<=65?65:(WIDTH<=66?66:(WIDTH<=67?67:(WIDTH<=68?68:(WIDTH<=69?69:(WIDTH<=70?70:(WIDTH<=71?71:(WIDTH<=72?72:(WIDTH<=73?73:(WIDTH<=74?74:(WIDTH<=75?75:(WIDTH<=76?76:(WIDTH<=77?77:(WIDTH<=78?78:(WIDTH<=79?79:(WIDTH<=80?80:(-1))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))));
localparam SMIC_DRAM_DEPTH = SMIC_DRAM_MUL==1?SMIC_DRAM_DEPTH_MUL1:(SMIC_DRAM_MUL==2?SMIC_DRAM_DEPTH_MUL2:(SMIC_DRAM_MUL==4?SMIC_DRAM_DEPTH_MUL4:(-1)));
localparam SMIC_DRAM_WIDTH = SMIC_DRAM_MUL==1?SMIC_DRAM_WIDTH_MUL1:(SMIC_DRAM_MUL==2?SMIC_DRAM_WIDTH_MUL2:(SMIC_DRAM_MUL==4?SMIC_DRAM_WIDTH_MUL4:(-1)));

localparam SMIC_SRAM_MUL = DEPTH<=0?(-1):(DEPTH<=1024?4:(DEPTH<=2048?8:(DEPTH<=4096?16:(-1))));
localparam SMIC_SRAM_DEPTH_MUL4  = DEPTH<=0?(-1):(DEPTH<=64?64:(DEPTH<=80?80:(DEPTH<=96?96:(DEPTH<=112?112:(DEPTH<=128?128:(DEPTH<=144?144:(DEPTH<=160?160:(DEPTH<=176?176:(DEPTH<=192?192:(DEPTH<=208?208:(DEPTH<=224?224:(DEPTH<=240?240:(DEPTH<=256?256:(DEPTH<=272?272:(DEPTH<=288?288:(DEPTH<=304?304:(DEPTH<=320?320:(DEPTH<=336?336:(DEPTH<=352?352:(DEPTH<=368?368:(DEPTH<=384?384:(DEPTH<=400?400:(DEPTH<=416?416:(DEPTH<=432?432:(DEPTH<=448?448:(DEPTH<=464?464:(DEPTH<=480?480:(DEPTH<=496?496:(DEPTH<=512?512:(DEPTH<=528?528:(DEPTH<=544?544:(DEPTH<=560?560:(DEPTH<=576?576:(DEPTH<=592?592:(DEPTH<=608?608:(DEPTH<=624?624:(DEPTH<=640?640:(DEPTH<=656?656:(DEPTH<=672?672:(DEPTH<=688?688:(DEPTH<=704?704:(DEPTH<=720?720:(DEPTH<=736?736:(DEPTH<=752?752:(DEPTH<=768?768:(DEPTH<=784?784:(DEPTH<=800?800:(DEPTH<=816?816:(DEPTH<=832?832:(DEPTH<=848?848:(DEPTH<=864?864:(DEPTH<=880?880:(DEPTH<=896?896:(DEPTH<=912?912:(DEPTH<=928?928:(DEPTH<=944?944:(DEPTH<=960?960:(DEPTH<=976?976:(DEPTH<=992?992:(DEPTH<=1008?1008:(DEPTH<=1024?1024:(-1))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))));
localparam SMIC_SRAM_DEPTH_MUL8  = DEPTH<=0?(-1):(DEPTH<=128?128:(DEPTH<=160?160:(DEPTH<=192?192:(DEPTH<=224?224:(DEPTH<=256?256:(DEPTH<=288?288:(DEPTH<=320?320:(DEPTH<=352?352:(DEPTH<=384?384:(DEPTH<=416?416:(DEPTH<=448?448:(DEPTH<=480?480:(DEPTH<=512?512:(DEPTH<=544?544:(DEPTH<=576?576:(DEPTH<=608?608:(DEPTH<=640?640:(DEPTH<=672?672:(DEPTH<=704?704:(DEPTH<=736?736:(DEPTH<=768?768:(DEPTH<=800?800:(DEPTH<=832?832:(DEPTH<=864?864:(DEPTH<=896?896:(DEPTH<=928?928:(DEPTH<=960?960:(DEPTH<=992?992:(DEPTH<=1024?1024:(DEPTH<=1056?1056:(DEPTH<=1088?1088:(DEPTH<=1120?1120:(DEPTH<=1152?1152:(DEPTH<=1184?1184:(DEPTH<=1216?1216:(DEPTH<=1248?1248:(DEPTH<=1280?1280:(DEPTH<=1312?1312:(DEPTH<=1344?1344:(DEPTH<=1376?1376:(DEPTH<=1408?1408:(DEPTH<=1440?1440:(DEPTH<=1472?1472:(DEPTH<=1504?1504:(DEPTH<=1536?1536:(DEPTH<=1568?1568:(DEPTH<=1600?1600:(DEPTH<=1632?1632:(DEPTH<=1664?1664:(DEPTH<=1696?1696:(DEPTH<=1728?1728:(DEPTH<=1760?1760:(DEPTH<=1792?1792:(DEPTH<=1824?1824:(DEPTH<=1856?1856:(DEPTH<=1888?1888:(DEPTH<=1920?1920:(DEPTH<=1952?1952:(DEPTH<=1984?1984:(DEPTH<=2016?2016:(DEPTH<=2048?2048:(-1))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))));
localparam SMIC_SRAM_DEPTH_MUL16 = DEPTH<=0?(-1):(DEPTH<=256?256:(DEPTH<=320?320:(DEPTH<=384?384:(DEPTH<=448?448:(DEPTH<=512?512:(DEPTH<=576?576:(DEPTH<=640?640:(DEPTH<=704?704:(DEPTH<=768?768:(DEPTH<=832?832:(DEPTH<=896?896:(DEPTH<=960?960:(DEPTH<=1024?1024:(DEPTH<=1088?1088:(DEPTH<=1152?1152:(DEPTH<=1216?1216:(DEPTH<=1280?1280:(DEPTH<=1344?1344:(DEPTH<=1408?1408:(DEPTH<=1472?1472:(DEPTH<=1536?1536:(DEPTH<=1600?1600:(DEPTH<=1664?1664:(DEPTH<=1728?1728:(DEPTH<=1792?1792:(DEPTH<=1856?1856:(DEPTH<=1920?1920:(DEPTH<=1984?1984:(DEPTH<=2048?2048:(DEPTH<=2112?2112:(DEPTH<=2176?2176:(DEPTH<=2240?2240:(DEPTH<=2304?2304:(DEPTH<=2368?2368:(DEPTH<=2432?2432:(DEPTH<=2496?2496:(DEPTH<=2560?2560:(DEPTH<=2624?2624:(DEPTH<=2688?2688:(DEPTH<=2752?2752:(DEPTH<=2816?2816:(DEPTH<=2880?2880:(DEPTH<=2944?2944:(DEPTH<=3008?3008:(DEPTH<=3072?3072:(DEPTH<=3136?3136:(DEPTH<=3200?3200:(DEPTH<=3264?3264:(DEPTH<=3328?3328:(DEPTH<=3392?3392:(DEPTH<=3456?3456:(DEPTH<=3520?3520:(DEPTH<=3584?3584:(DEPTH<=3648?3648:(DEPTH<=3712?3712:(DEPTH<=3776?3776:(DEPTH<=3840?3840:(DEPTH<=3904?3904:(DEPTH<=3968?3968:(DEPTH<=4032?4032:(DEPTH<=4096?4096:(-1))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))));
localparam SMIC_SRAM_WIDTH_MUL4  = WIDTH<=0?(-1):(WIDTH<=4?4:(WIDTH<=5?5:(WIDTH<=6?6:(WIDTH<=7?7:(WIDTH<=8?8:(WIDTH<=9?9:(WIDTH<=10?10:(WIDTH<=11?11:(WIDTH<=12?12:(WIDTH<=13?13:(WIDTH<=14?14:(WIDTH<=15?15:(WIDTH<=16?16:(WIDTH<=17?17:(WIDTH<=18?18:(WIDTH<=19?19:(WIDTH<=20?20:(WIDTH<=21?21:(WIDTH<=22?22:(WIDTH<=23?23:(WIDTH<=24?24:(WIDTH<=25?25:(WIDTH<=26?26:(WIDTH<=27?27:(WIDTH<=28?28:(WIDTH<=29?29:(WIDTH<=30?30:(WIDTH<=31?31:(WIDTH<=32?32:(WIDTH<=33?33:(WIDTH<=34?34:(WIDTH<=35?35:(WIDTH<=36?36:(WIDTH<=37?37:(WIDTH<=38?38:(WIDTH<=39?39:(WIDTH<=40?40:(WIDTH<=41?41:(WIDTH<=42?42:(WIDTH<=43?43:(WIDTH<=44?44:(WIDTH<=45?45:(WIDTH<=46?46:(WIDTH<=47?47:(WIDTH<=48?48:(WIDTH<=49?49:(WIDTH<=50?50:(WIDTH<=51?51:(WIDTH<=52?52:(WIDTH<=53?53:(WIDTH<=54?54:(WIDTH<=55?55:(WIDTH<=56?56:(WIDTH<=57?57:(WIDTH<=58?58:(WIDTH<=59?59:(WIDTH<=60?60:(WIDTH<=61?61:(WIDTH<=62?62:(WIDTH<=63?63:(WIDTH<=64?64:(WIDTH<=65?65:(WIDTH<=66?66:(WIDTH<=67?67:(WIDTH<=68?68:(WIDTH<=69?69:(WIDTH<=70?70:(WIDTH<=71?71:(WIDTH<=72?72:(WIDTH<=73?73:(WIDTH<=74?74:(WIDTH<=75?75:(WIDTH<=76?76:(WIDTH<=77?77:(WIDTH<=78?78:(WIDTH<=79?79:(WIDTH<=80?80:(-1))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))));
localparam SMIC_SRAM_WIDTH_MUL8  = WIDTH<=0?(-1):(WIDTH<=4?4:(WIDTH<=5?5:(WIDTH<=6?6:(WIDTH<=7?7:(WIDTH<=8?8:(WIDTH<=9?9:(WIDTH<=10?10:(WIDTH<=11?11:(WIDTH<=12?12:(WIDTH<=13?13:(WIDTH<=14?14:(WIDTH<=15?15:(WIDTH<=16?16:(WIDTH<=17?17:(WIDTH<=18?18:(WIDTH<=19?19:(WIDTH<=20?20:(WIDTH<=21?21:(WIDTH<=22?22:(WIDTH<=23?23:(WIDTH<=24?24:(WIDTH<=25?25:(WIDTH<=26?26:(WIDTH<=27?27:(WIDTH<=28?28:(WIDTH<=29?29:(WIDTH<=30?30:(WIDTH<=31?31:(WIDTH<=32?32:(WIDTH<=33?33:(WIDTH<=34?34:(WIDTH<=35?35:(WIDTH<=36?36:(WIDTH<=37?37:(WIDTH<=38?38:(WIDTH<=39?39:(WIDTH<=40?40:(-1))))))))))))))))))))))))))))))))))))));
localparam SMIC_SRAM_WIDTH_MUL16 = WIDTH<=0?(-1):(WIDTH<=4?4:(WIDTH<=5?5:(WIDTH<=6?6:(WIDTH<=7?7:(WIDTH<=8?8:(WIDTH<=9?9:(WIDTH<=10?10:(WIDTH<=11?11:(WIDTH<=12?12:(WIDTH<=13?13:(WIDTH<=14?14:(WIDTH<=15?15:(WIDTH<=16?16:(WIDTH<=17?17:(WIDTH<=18?18:(WIDTH<=19?19:(WIDTH<=20?20:(-1))))))))))))))))));
localparam SMIC_SRAM_DEPTH = SMIC_SRAM_MUL==4?SMIC_SRAM_DEPTH_MUL4:(SMIC_SRAM_MUL==8?SMIC_SRAM_DEPTH_MUL8:(SMIC_SRAM_MUL==16?SMIC_SRAM_DEPTH_MUL16:(-1)));
localparam SMIC_SRAM_WIDTH = SMIC_SRAM_MUL==4?SMIC_SRAM_WIDTH_MUL4:(SMIC_SRAM_MUL==8?SMIC_SRAM_WIDTH_MUL8:(SMIC_SRAM_MUL==16?SMIC_SRAM_WIDTH_MUL16:(-1)));

localparam DWorSMIC = ((WIDTH * DEPTH <= 1024)&&(WIDTH<=1024)&&(DEPTH<=1024)&&((WIDTH!=SMIC_DRAM_WIDTH)||(DEPTH!=SMIC_DRAM_DEPTH))&&((WIDTH!=SMIC_SRAM_WIDTH)||(DEPTH!=SMIC_SRAM_DEPTH)))?"DW":((WIDTH>80||(WIDTH * DEPTH <= 16384))&&(SMIC_DRAM_DEPTH!=-1||SMIC_DRAM_WIDTH!=-1)?"SMIC_REGFILE":(DEPTH>1024||(WIDTH * DEPTH > 32768)?"SMIC_SRAM":(SMIC_SRAM_DEPTH*SMIC_SRAM_WIDTH-DEPTH*WIDTH>SMIC_DRAM_DEPTH*SMIC_DRAM_WIDTH-DEPTH*WIDTH?"SMIC_REGFILE":"SMIC_SRAM")));

localparam FIRST_CHOOSED_WIDTH = DWorSMIC == "DW"?(WIDTH<=0?-1:WIDTH):(DWorSMIC == "SMIC_REGFILE"?SMIC_DRAM_WIDTH:SMIC_SRAM_WIDTH);
localparam FIRST_CHOOSED_DEPTH = DWorSMIC == "DW"?(DEPTH<=0?-1:(DEPTH<=1?2:DEPTH)):(DWorSMIC == "SMIC_REGFILE"?SMIC_DRAM_DEPTH:SMIC_SRAM_DEPTH);

localparam CHOOSED_WIDTH = (FIRST_CHOOSED_WIDTH == -1 && MANUAL_CONFIG != "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX")?WIDTH:FIRST_CHOOSED_WIDTH;
localparam CHOOSED_DEPTH = (FIRST_CHOOSED_DEPTH == -1 && MANUAL_CONFIG != "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX")?DEPTH:FIRST_CHOOSED_DEPTH;

localparam ADDRESS_WIDTH_OF_RAM = $clog2(CHOOSED_DEPTH);

`ifndef DUMP_SIMU
    `ifdef DUMP_VCD
        `define DUMP_SIMU
    `else
        `ifdef DUMP_FSDB
            `define DUMP_SIMU
        `endif
    `endif
`endif

`ifdef DUMP_SIMU
initial begin
    if(OUTPUT_DELAY < 1 || OUTPUT_DELAY > 4)
      begin
        $display("Invalid output delay! (File:",`__FILE__,", Line:",`__LINE__);
        $stop;
      end
    if(CHOOSED_DEPTH == -1)
      begin
        $display("Invalid dram depth! (File:",`__FILE__,", Line:",`__LINE__);
        $stop;
      end
    else if(CHOOSED_WIDTH == -1)
      begin
        $display("invalid dram width! (File:",`__FILE__,", Line:",`__LINE__);
        $stop;
      end
end
`endif

wire fifocontroler_we_n_toRAM;
wire [ADDRESS_WIDTH-1:0] addra;
wire [ADDRESS_WIDTH-1:0] addrb;

DW_fifoctl_s1_sf #(     .depth(CHOOSED_DEPTH), 
                        .ae_level(ALMOST_EMPTY), 
                        .af_level(ALMOST_FULL), 
                        .err_mode(0), 
                        .rst_mode(0)
                  ) DW_fifoctl_s1_sf (
                        .clk(clk), 
                        .rst_n(~srst),
                        .push_req_n(~wr_en), 
                        .pop_req_n(~rd_en),
                        .diag_n(1'd1), 
                        .we_n(fifocontroler_we_n_toRAM), 
                        .empty(empty),
                        .almost_empty(almost_empty), 
                        .half_full(half_full),
                        .almost_full(almost_full), 
                        .full(full),
                        .error(), 
                        .wr_addr(addra),
                        .rd_addr(addrb)
                  );
					
//assign addrb = addrb_beforecheck==addra?addrb_beforecheck-1'd1:addrb_beforecheck;
     
     
generate
    if(NEED_DATACOUNT == 1'd1)
      begin:DATACOUNTER
        reg [ADDRESS_WIDTH:0] data_count_r;             
        always @ (posedge clk or posedge srst)
          begin
            if(srst)
              begin
                data_count_r <= {(ADDRESS_WIDTH+1){1'd0}};
              end
            else
              begin
                if(wr_en && (!rd_en))
                    if(data_count_r == DEPTH)
                        data_count_r <= data_count_r;
                    else
                        data_count_r <= data_count_r + 1'd1;
                else if((!wr_en) && rd_en)
                    if(data_count_r == {(ADDRESS_WIDTH+1){1'd0}})
                        data_count_r <= data_count_r;
                    else
                        data_count_r <= data_count_r - 1'd1;
                else
                    data_count_r <= data_count_r;
              end
          end
		assign data_count = data_count_r;
    end
endgenerate
                  
wire [WIDTH-1:0] dout_z0;            
generate
    if(MANUAL_CONFIG == "SRAMdpw8d16384")
      begin:SRAMdpw8d16384
        wire [WIDTH-1:0] dout_z0_slice[0:3];
        wire [3:0] choosedSRAM_wr = ~(4'd1 << addra[13:12]);
        wire [3:0] choosedSRAM_rd = ~(4'd1 << addrb[13:12]);
        reg [13:12] addrb_z1;
        always@(posedge clk) addrb_z1[13:12] <= addrb[13:12];
        assign dout_z0 = dout_z0_slice[addrb_z1[13:12]];
        
            SRAMdpw8d4096  SRAMdpw8d4096_1    (.QB(dout_z0_slice[ 0]),.CLKA(clk),.CENA(choosedSRAM_wr[ 0]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[11:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 0]),.WENB(1'd1),.AB(addrb[11:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({12{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({12{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw8d4096  SRAMdpw8d4096_2    (.QB(dout_z0_slice[ 1]),.CLKA(clk),.CENA(choosedSRAM_wr[ 1]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[11:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 1]),.WENB(1'd1),.AB(addrb[11:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({12{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({12{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw8d4096  SRAMdpw8d4096_3    (.QB(dout_z0_slice[ 2]),.CLKA(clk),.CENA(choosedSRAM_wr[ 2]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[11:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 2]),.WENB(1'd1),.AB(addrb[11:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({12{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({12{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw8d4096  SRAMdpw8d4096_4    (.QB(dout_z0_slice[ 3]),.CLKA(clk),.CENA(choosedSRAM_wr[ 3]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[11:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 3]),.WENB(1'd1),.AB(addrb[11:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({12{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({12{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
      end
    else if(MANUAL_CONFIG == "SRAMdpw16d4096")
      begin:SRAMdpw16d4096
        wire [WIDTH-1:0] dout_z0_slice[0:1];
        wire [1:0] choosedSRAM_wr = ~(2'd1 << addra[11]);
        wire [1:0] choosedSRAM_rd = ~(2'd1 << addrb[11]);
        reg [11:11] addrb_z1;
        always@(posedge clk) addrb_z1[11] <= addrb[11];
        assign dout_z0 = dout_z0_slice[addrb_z1[11]];
        
            SRAMdpw16d2048  SRAMdpw16d2048_1  (.QB(dout_z0_slice[ 0]),.CLKA(clk),.CENA(choosedSRAM_wr[ 0]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[10:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 0]),.WENB(1'd1),.AB(addrb[10:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({11{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({11{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw16d2048  SRAMdpw16d2048_2  (.QB(dout_z0_slice[ 1]),.CLKA(clk),.CENA(choosedSRAM_wr[ 1]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[10:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 1]),.WENB(1'd1),.AB(addrb[10:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({11{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({11{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
      end
    else if(MANUAL_CONFIG == "SRAMdpw16d65536")
      begin:SRAMdpw16d65536
        `ifdef SS_CORNER
            wire [WIDTH-1:0] dout_z0_slice[0:31];
            wire [31:0] choosedSRAM_wr = ~(32'd1 << addra[15:11]);
            wire [31:0] choosedSRAM_rd = ~(32'd1 << addrb[15:11]);
            reg [15:11] addrb_z1;
            always@(posedge clk) addrb_z1[15:11] <= addrb[15:11];
            assign dout_z0 = dout_z0_slice[addrb_z1[15:11]];
            
            SRAMdpw16d2048  SRAMdpw16d2048_1  (.QB(dout_z0_slice[ 0]),.CLKA(clk),.CENA(choosedSRAM_wr[ 0]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[10:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 0]),.WENB(1'd1),.AB(addrb[10:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({11{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({11{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw16d2048  SRAMdpw16d2048_2  (.QB(dout_z0_slice[ 1]),.CLKA(clk),.CENA(choosedSRAM_wr[ 1]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[10:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 1]),.WENB(1'd1),.AB(addrb[10:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({11{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({11{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw16d2048  SRAMdpw16d2048_3  (.QB(dout_z0_slice[ 2]),.CLKA(clk),.CENA(choosedSRAM_wr[ 2]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[10:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 2]),.WENB(1'd1),.AB(addrb[10:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({11{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({11{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw16d2048  SRAMdpw16d2048_4  (.QB(dout_z0_slice[ 3]),.CLKA(clk),.CENA(choosedSRAM_wr[ 3]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[10:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 3]),.WENB(1'd1),.AB(addrb[10:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({11{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({11{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw16d2048  SRAMdpw16d2048_5  (.QB(dout_z0_slice[ 4]),.CLKA(clk),.CENA(choosedSRAM_wr[ 4]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[10:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 4]),.WENB(1'd1),.AB(addrb[10:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({11{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({11{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw16d2048  SRAMdpw16d2048_6  (.QB(dout_z0_slice[ 5]),.CLKA(clk),.CENA(choosedSRAM_wr[ 5]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[10:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 5]),.WENB(1'd1),.AB(addrb[10:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({11{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({11{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw16d2048  SRAMdpw16d2048_7  (.QB(dout_z0_slice[ 6]),.CLKA(clk),.CENA(choosedSRAM_wr[ 6]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[10:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 6]),.WENB(1'd1),.AB(addrb[10:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({11{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({11{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw16d2048  SRAMdpw16d2048_8  (.QB(dout_z0_slice[ 7]),.CLKA(clk),.CENA(choosedSRAM_wr[ 7]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[10:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 7]),.WENB(1'd1),.AB(addrb[10:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({11{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({11{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw16d2048  SRAMdpw16d2048_9  (.QB(dout_z0_slice[ 8]),.CLKA(clk),.CENA(choosedSRAM_wr[ 8]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[10:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 8]),.WENB(1'd1),.AB(addrb[10:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({11{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({11{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw16d2048  SRAMdpw16d2048_10 (.QB(dout_z0_slice[ 9]),.CLKA(clk),.CENA(choosedSRAM_wr[ 9]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[10:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 9]),.WENB(1'd1),.AB(addrb[10:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({11{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({11{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw16d2048  SRAMdpw16d2048_11 (.QB(dout_z0_slice[10]),.CLKA(clk),.CENA(choosedSRAM_wr[10]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[10:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[10]),.WENB(1'd1),.AB(addrb[10:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({11{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({11{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw16d2048  SRAMdpw16d2048_12 (.QB(dout_z0_slice[11]),.CLKA(clk),.CENA(choosedSRAM_wr[11]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[10:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[11]),.WENB(1'd1),.AB(addrb[10:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({11{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({11{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw16d2048  SRAMdpw16d2048_13 (.QB(dout_z0_slice[12]),.CLKA(clk),.CENA(choosedSRAM_wr[12]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[10:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[12]),.WENB(1'd1),.AB(addrb[10:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({11{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({11{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw16d2048  SRAMdpw16d2048_14 (.QB(dout_z0_slice[13]),.CLKA(clk),.CENA(choosedSRAM_wr[13]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[10:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[13]),.WENB(1'd1),.AB(addrb[10:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({11{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({11{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw16d2048  SRAMdpw16d2048_15 (.QB(dout_z0_slice[14]),.CLKA(clk),.CENA(choosedSRAM_wr[14]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[10:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[14]),.WENB(1'd1),.AB(addrb[10:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({11{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({11{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw16d2048  SRAMdpw16d2048_16 (.QB(dout_z0_slice[15]),.CLKA(clk),.CENA(choosedSRAM_wr[15]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[10:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[15]),.WENB(1'd1),.AB(addrb[10:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({11{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({11{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw16d2048  SRAMdpw16d2048_17 (.QB(dout_z0_slice[16]),.CLKA(clk),.CENA(choosedSRAM_wr[16]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[10:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[16]),.WENB(1'd1),.AB(addrb[10:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({11{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({11{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw16d2048  SRAMdpw16d2048_18 (.QB(dout_z0_slice[17]),.CLKA(clk),.CENA(choosedSRAM_wr[17]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[10:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[17]),.WENB(1'd1),.AB(addrb[10:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({11{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({11{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw16d2048  SRAMdpw16d2048_19 (.QB(dout_z0_slice[18]),.CLKA(clk),.CENA(choosedSRAM_wr[18]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[10:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[18]),.WENB(1'd1),.AB(addrb[10:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({11{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({11{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw16d2048  SRAMdpw16d2048_20 (.QB(dout_z0_slice[19]),.CLKA(clk),.CENA(choosedSRAM_wr[19]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[10:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[19]),.WENB(1'd1),.AB(addrb[10:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({11{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({11{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw16d2048  SRAMdpw16d2048_21 (.QB(dout_z0_slice[20]),.CLKA(clk),.CENA(choosedSRAM_wr[20]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[10:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[20]),.WENB(1'd1),.AB(addrb[10:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({11{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({11{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw16d2048  SRAMdpw16d2048_22 (.QB(dout_z0_slice[21]),.CLKA(clk),.CENA(choosedSRAM_wr[21]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[10:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[21]),.WENB(1'd1),.AB(addrb[10:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({11{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({11{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw16d2048  SRAMdpw16d2048_23 (.QB(dout_z0_slice[22]),.CLKA(clk),.CENA(choosedSRAM_wr[22]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[10:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[22]),.WENB(1'd1),.AB(addrb[10:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({11{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({11{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw16d2048  SRAMdpw16d2048_24 (.QB(dout_z0_slice[23]),.CLKA(clk),.CENA(choosedSRAM_wr[23]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[10:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[23]),.WENB(1'd1),.AB(addrb[10:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({11{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({11{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw16d2048  SRAMdpw16d2048_25 (.QB(dout_z0_slice[24]),.CLKA(clk),.CENA(choosedSRAM_wr[24]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[10:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[24]),.WENB(1'd1),.AB(addrb[10:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({11{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({11{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw16d2048  SRAMdpw16d2048_26 (.QB(dout_z0_slice[25]),.CLKA(clk),.CENA(choosedSRAM_wr[25]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[10:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[25]),.WENB(1'd1),.AB(addrb[10:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({11{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({11{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw16d2048  SRAMdpw16d2048_27 (.QB(dout_z0_slice[26]),.CLKA(clk),.CENA(choosedSRAM_wr[26]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[10:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[26]),.WENB(1'd1),.AB(addrb[10:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({11{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({11{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw16d2048  SRAMdpw16d2048_28 (.QB(dout_z0_slice[27]),.CLKA(clk),.CENA(choosedSRAM_wr[27]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[10:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[27]),.WENB(1'd1),.AB(addrb[10:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({11{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({11{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw16d2048  SRAMdpw16d2048_29 (.QB(dout_z0_slice[28]),.CLKA(clk),.CENA(choosedSRAM_wr[28]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[10:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[28]),.WENB(1'd1),.AB(addrb[10:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({11{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({11{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw16d2048  SRAMdpw16d2048_30 (.QB(dout_z0_slice[29]),.CLKA(clk),.CENA(choosedSRAM_wr[29]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[10:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[29]),.WENB(1'd1),.AB(addrb[10:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({11{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({11{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw16d2048  SRAMdpw16d2048_31 (.QB(dout_z0_slice[30]),.CLKA(clk),.CENA(choosedSRAM_wr[30]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[10:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[30]),.WENB(1'd1),.AB(addrb[10:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({11{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({11{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw16d2048  SRAMdpw16d2048_32 (.QB(dout_z0_slice[31]),.CLKA(clk),.CENA(choosedSRAM_wr[31]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[10:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[31]),.WENB(1'd1),.AB(addrb[10:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({11{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({11{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
         `else
            wire [WIDTH-1:0] dout_z0_slice[0:15];
            wire [15:0] choosedSRAM_wr = ~(16'd1 << addra[15:12]);
            wire [15:0] choosedSRAM_rd = ~(16'd1 << addrb[15:12]);
            reg [15:12] addrb_z1;
            always@(posedge clk) addrb_z1[15:12] <= addrb[15:12];
            assign dout_z0 = dout_z0_slice[addrb_z1[15:12]];
            
            SRAMdpw16d4096  SRAMdpw16d4096_1  (.QB(dout_z0_slice[ 0]),.CLKA(clk),.CENA(choosedSRAM_wr[ 0]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[11:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 0]),.WENB(1'd1),.AB(addrb[11:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({12{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({12{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw16d4096  SRAMdpw16d4096_2  (.QB(dout_z0_slice[ 1]),.CLKA(clk),.CENA(choosedSRAM_wr[ 1]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[11:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 1]),.WENB(1'd1),.AB(addrb[11:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({12{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({12{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw16d4096  SRAMdpw16d4096_3  (.QB(dout_z0_slice[ 2]),.CLKA(clk),.CENA(choosedSRAM_wr[ 2]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[11:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 2]),.WENB(1'd1),.AB(addrb[11:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({12{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({12{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw16d4096  SRAMdpw16d4096_4  (.QB(dout_z0_slice[ 3]),.CLKA(clk),.CENA(choosedSRAM_wr[ 3]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[11:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 3]),.WENB(1'd1),.AB(addrb[11:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({12{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({12{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw16d4096  SRAMdpw16d4096_5  (.QB(dout_z0_slice[ 4]),.CLKA(clk),.CENA(choosedSRAM_wr[ 4]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[11:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 4]),.WENB(1'd1),.AB(addrb[11:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({12{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({12{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw16d4096  SRAMdpw16d4096_6  (.QB(dout_z0_slice[ 5]),.CLKA(clk),.CENA(choosedSRAM_wr[ 5]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[11:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 5]),.WENB(1'd1),.AB(addrb[11:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({12{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({12{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw16d4096  SRAMdpw16d4096_7  (.QB(dout_z0_slice[ 6]),.CLKA(clk),.CENA(choosedSRAM_wr[ 6]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[11:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 6]),.WENB(1'd1),.AB(addrb[11:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({12{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({12{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw16d4096  SRAMdpw16d4096_8  (.QB(dout_z0_slice[ 7]),.CLKA(clk),.CENA(choosedSRAM_wr[ 7]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[11:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 7]),.WENB(1'd1),.AB(addrb[11:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({12{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({12{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw16d4096  SRAMdpw16d4096_9  (.QB(dout_z0_slice[ 8]),.CLKA(clk),.CENA(choosedSRAM_wr[ 8]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[11:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 8]),.WENB(1'd1),.AB(addrb[11:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({12{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({12{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw16d4096  SRAMdpw16d4096_10 (.QB(dout_z0_slice[ 9]),.CLKA(clk),.CENA(choosedSRAM_wr[ 9]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[11:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 9]),.WENB(1'd1),.AB(addrb[11:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({12{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({12{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw16d4096  SRAMdpw16d4096_11 (.QB(dout_z0_slice[10]),.CLKA(clk),.CENA(choosedSRAM_wr[10]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[11:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[10]),.WENB(1'd1),.AB(addrb[11:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({12{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({12{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw16d4096  SRAMdpw16d4096_12 (.QB(dout_z0_slice[11]),.CLKA(clk),.CENA(choosedSRAM_wr[11]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[11:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[11]),.WENB(1'd1),.AB(addrb[11:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({12{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({12{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw16d4096  SRAMdpw16d4096_13 (.QB(dout_z0_slice[12]),.CLKA(clk),.CENA(choosedSRAM_wr[12]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[11:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[12]),.WENB(1'd1),.AB(addrb[11:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({12{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({12{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw16d4096  SRAMdpw16d4096_14 (.QB(dout_z0_slice[13]),.CLKA(clk),.CENA(choosedSRAM_wr[13]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[11:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[13]),.WENB(1'd1),.AB(addrb[11:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({12{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({12{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw16d4096  SRAMdpw16d4096_15 (.QB(dout_z0_slice[14]),.CLKA(clk),.CENA(choosedSRAM_wr[14]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[11:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[14]),.WENB(1'd1),.AB(addrb[11:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({12{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({12{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw16d4096  SRAMdpw16d4096_16 (.QB(dout_z0_slice[15]),.CLKA(clk),.CENA(choosedSRAM_wr[15]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[11:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[15]),.WENB(1'd1),.AB(addrb[11:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({12{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({12{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
         `endif
      end
    else if(MANUAL_CONFIG == "SRAMdpw24d4096")
      begin:SRAMdpw24d4096
        wire [WIDTH-1:0] dout_z0_slice[0:1];
        wire [1:0] choosedSRAM_wr = ~(2'd1 << addra[11]);
        wire [1:0] choosedSRAM_rd = ~(2'd1 << addrb[11]);
        reg [11:11] addrb_z1;
        always@(posedge clk) addrb_z1[11:11] <= addrb[11:11];
        assign dout_z0 = dout_z0_slice[addrb_z1[11:11]];
        
        SRAMdpw24d2048  SRAMdpw24d2048_1  (.QB(dout_z0_slice[ 0]),.CLKA(clk),.CENA(choosedSRAM_wr[ 0]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[10:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 0]),.WENB(1'd1),.AB(addrb[10:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({11{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({11{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
        SRAMdpw24d2048  SRAMdpw24d2048_2  (.QB(dout_z0_slice[ 1]),.CLKA(clk),.CENA(choosedSRAM_wr[ 1]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[10:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 1]),.WENB(1'd1),.AB(addrb[10:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({11{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({11{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
      end
    else if(MANUAL_CONFIG == "SRAMdpw32d8192")
      begin:SRAMdpw32d8192
        `ifdef SS_CORNER
            wire [WIDTH-1:0] dout_z0_slice[0:7];
            wire [7:0] choosedSRAM_wr = ~(8'd1 << addra[12:10]);
            wire [7:0] choosedSRAM_rd = ~(8'd1 << addrb[12:10]);
            reg [12:10] addrb_z1;
            always@(posedge clk) addrb_z1[12:10] <= addrb[12:10];
            assign dout_z0 = dout_z0_slice[addrb_z1[12:10]];
            
            SRAMdpw32d1024  SRAMdpw32d1024_1  (.QB(dout_z0_slice[ 0]),.CLKA(clk),.CENA(choosedSRAM_wr[ 0]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[9:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 0]),.WENB(1'd1),.AB(addrb[9:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({10{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({10{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw32d1024  SRAMdpw32d1024_2  (.QB(dout_z0_slice[ 1]),.CLKA(clk),.CENA(choosedSRAM_wr[ 1]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[9:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 1]),.WENB(1'd1),.AB(addrb[9:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({10{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({10{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw32d1024  SRAMdpw32d1024_3  (.QB(dout_z0_slice[ 2]),.CLKA(clk),.CENA(choosedSRAM_wr[ 2]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[9:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 2]),.WENB(1'd1),.AB(addrb[9:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({10{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({10{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw32d1024  SRAMdpw32d1024_4  (.QB(dout_z0_slice[ 3]),.CLKA(clk),.CENA(choosedSRAM_wr[ 3]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[9:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 3]),.WENB(1'd1),.AB(addrb[9:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({10{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({10{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw32d1024  SRAMdpw32d1024_5  (.QB(dout_z0_slice[ 4]),.CLKA(clk),.CENA(choosedSRAM_wr[ 4]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[9:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 4]),.WENB(1'd1),.AB(addrb[9:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({10{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({10{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw32d1024  SRAMdpw32d1024_6  (.QB(dout_z0_slice[ 5]),.CLKA(clk),.CENA(choosedSRAM_wr[ 5]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[9:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 5]),.WENB(1'd1),.AB(addrb[9:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({10{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({10{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw32d1024  SRAMdpw32d1024_7  (.QB(dout_z0_slice[ 6]),.CLKA(clk),.CENA(choosedSRAM_wr[ 6]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[9:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 6]),.WENB(1'd1),.AB(addrb[9:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({10{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({10{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw32d1024  SRAMdpw32d1024_8  (.QB(dout_z0_slice[ 7]),.CLKA(clk),.CENA(choosedSRAM_wr[ 7]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[9:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 7]),.WENB(1'd1),.AB(addrb[9:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({10{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({10{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
         `else
            wire [WIDTH-1:0] dout_z0_slice[0:3];
            wire [3:0] choosedSRAM_wr = ~(4'd1 << addra[12:11]);
            wire [3:0] choosedSRAM_rd = ~(4'd1 << addrb[12:11]);
            reg [12:11] addrb_z1;
            always@(posedge clk) addrb_z1[12:11] <= addrb[12:11];
            assign dout_z0 = dout_z0_slice[addrb_z1[12:11]];
            
            SRAMdpw32d2048  SRAMdpw32d2048_1  (.QB(dout_z0_slice[ 0]),.CLKA(clk),.CENA(choosedSRAM_wr[ 0]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[10:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 0]),.WENB(1'd1),.AB(addrb[10:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({11{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({11{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw32d2048  SRAMdpw32d2048_2  (.QB(dout_z0_slice[ 1]),.CLKA(clk),.CENA(choosedSRAM_wr[ 1]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[10:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 1]),.WENB(1'd1),.AB(addrb[10:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({11{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({11{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw32d2048  SRAMdpw32d2048_3  (.QB(dout_z0_slice[ 2]),.CLKA(clk),.CENA(choosedSRAM_wr[ 2]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[10:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 2]),.WENB(1'd1),.AB(addrb[10:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({11{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({11{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw32d2048  SRAMdpw32d2048_4  (.QB(dout_z0_slice[ 3]),.CLKA(clk),.CENA(choosedSRAM_wr[ 3]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[10:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 3]),.WENB(1'd1),.AB(addrb[10:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({11{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({11{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
         `endif
      end
    else if(MANUAL_CONFIG == "SRAMdpw38d2048")
      begin:SRAMdpw38d2048
        `ifdef SS_CORNER
            wire [WIDTH-1:0] dout_z0_slice[0:1];
            wire [1:0] choosedSRAM_wr = ~(2'd1 << addra[10]);
            wire [1:0] choosedSRAM_rd = ~(2'd1 << addrb[10]);
            reg [10:10] addrb_z1;
            always@(posedge clk) addrb_z1[10:10] <= addrb[10:10];
            assign dout_z0 = dout_z0_slice[addrb_z1[10:10]];
            
            SRAMdpw38d1024  SRAMdpw38d1024_1  (.QB(dout_z0_slice[ 0]),.CLKA(clk),.CENA(choosedSRAM_wr[ 0]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[9:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 0]),.WENB(1'd1),.AB(addrb[9:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({10{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({10{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw38d1024  SRAMdpw38d1024_2  (.QB(dout_z0_slice[ 1]),.CLKA(clk),.CENA(choosedSRAM_wr[ 1]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[9:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 1]),.WENB(1'd1),.AB(addrb[9:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({10{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({10{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
         `else
            wire [WIDTH-1:0] dout_z0_slice[0:0];
            wire [0:0] choosedSRAM_wr = ~(1'd1);
            wire [0:0] choosedSRAM_rd = ~(1'd1);
            assign dout_z0 = dout_z0_slice[0];
            
            SRAMdpw38d2048  SRAMdpw38d2048  (.QB(dout_z0_slice[ 0]),.CLKA(clk),.CENA(choosedSRAM_wr[ 0]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[9:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 0]),.WENB(1'd1),.AB(addrb[9:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({11{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({11{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
         `endif
      end
    else if(MANUAL_CONFIG == "SRAMdpw38d16384")
      begin:SRAMdpw38d16384
        `ifdef SS_CORNER
            wire [WIDTH-1:0] dout_z0_slice[0:15];
            wire [15:0] choosedSRAM_wr = ~(16'd1 << addra[13:10]);
            wire [15:0] choosedSRAM_rd = ~(16'd1 << addrb[13:10]);
            reg [13:10] addrb_z1;
            always@(posedge clk) addrb_z1[13:10] <= addrb[13:10];
            assign dout_z0 = dout_z0_slice[addrb_z1[13:10]];
            
            SRAMdpw38d1024  SRAMdpw38d1024_1  (.QB(dout_z0_slice[ 0]),.CLKA(clk),.CENA(choosedSRAM_wr[ 0]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[9:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 0]),.WENB(1'd1),.AB(addrb[9:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({10{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({10{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw38d1024  SRAMdpw38d1024_2  (.QB(dout_z0_slice[ 1]),.CLKA(clk),.CENA(choosedSRAM_wr[ 1]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[9:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 1]),.WENB(1'd1),.AB(addrb[9:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({10{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({10{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw38d1024  SRAMdpw38d1024_3  (.QB(dout_z0_slice[ 2]),.CLKA(clk),.CENA(choosedSRAM_wr[ 2]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[9:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 2]),.WENB(1'd1),.AB(addrb[9:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({10{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({10{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw38d1024  SRAMdpw38d1024_4  (.QB(dout_z0_slice[ 3]),.CLKA(clk),.CENA(choosedSRAM_wr[ 3]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[9:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 3]),.WENB(1'd1),.AB(addrb[9:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({10{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({10{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw38d1024  SRAMdpw38d1024_5  (.QB(dout_z0_slice[ 4]),.CLKA(clk),.CENA(choosedSRAM_wr[ 4]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[9:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 4]),.WENB(1'd1),.AB(addrb[9:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({10{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({10{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw38d1024  SRAMdpw38d1024_6  (.QB(dout_z0_slice[ 5]),.CLKA(clk),.CENA(choosedSRAM_wr[ 5]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[9:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 5]),.WENB(1'd1),.AB(addrb[9:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({10{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({10{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw38d1024  SRAMdpw38d1024_7  (.QB(dout_z0_slice[ 6]),.CLKA(clk),.CENA(choosedSRAM_wr[ 6]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[9:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 6]),.WENB(1'd1),.AB(addrb[9:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({10{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({10{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw38d1024  SRAMdpw38d1024_8  (.QB(dout_z0_slice[ 7]),.CLKA(clk),.CENA(choosedSRAM_wr[ 7]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[9:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 7]),.WENB(1'd1),.AB(addrb[9:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({10{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({10{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw38d1024  SRAMdpw38d1024_9  (.QB(dout_z0_slice[ 8]),.CLKA(clk),.CENA(choosedSRAM_wr[ 8]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[9:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 8]),.WENB(1'd1),.AB(addrb[9:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({10{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({10{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw38d1024  SRAMdpw38d1024_10 (.QB(dout_z0_slice[ 9]),.CLKA(clk),.CENA(choosedSRAM_wr[ 9]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[9:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 9]),.WENB(1'd1),.AB(addrb[9:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({10{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({10{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw38d1024  SRAMdpw38d1024_11 (.QB(dout_z0_slice[10]),.CLKA(clk),.CENA(choosedSRAM_wr[10]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[9:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[10]),.WENB(1'd1),.AB(addrb[9:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({10{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({10{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw38d1024  SRAMdpw38d1024_12 (.QB(dout_z0_slice[11]),.CLKA(clk),.CENA(choosedSRAM_wr[11]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[9:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[11]),.WENB(1'd1),.AB(addrb[9:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({10{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({10{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw38d1024  SRAMdpw38d1024_13 (.QB(dout_z0_slice[12]),.CLKA(clk),.CENA(choosedSRAM_wr[12]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[9:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[12]),.WENB(1'd1),.AB(addrb[9:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({10{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({10{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw38d1024  SRAMdpw38d1024_14 (.QB(dout_z0_slice[13]),.CLKA(clk),.CENA(choosedSRAM_wr[13]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[9:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[13]),.WENB(1'd1),.AB(addrb[9:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({10{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({10{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw38d1024  SRAMdpw38d1024_15 (.QB(dout_z0_slice[14]),.CLKA(clk),.CENA(choosedSRAM_wr[14]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[9:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[14]),.WENB(1'd1),.AB(addrb[9:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({10{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({10{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw38d1024  SRAMdpw38d1024_16 (.QB(dout_z0_slice[15]),.CLKA(clk),.CENA(choosedSRAM_wr[15]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[9:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[15]),.WENB(1'd1),.AB(addrb[9:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({10{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({10{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
         `else
            wire [WIDTH-1:0] dout_z0_slice[0:7];
            wire [7:0] choosedSRAM_wr = ~(8'd1 << addra[13:11]);
            wire [7:0] choosedSRAM_rd = ~(8'd1 << addrb[13:11]);
            reg [13:11] addrb_z1;
            always@(posedge clk) addrb_z1[13:11] <= addrb[13:11];
            assign dout_z0 = dout_z0_slice[addrb_z1[13:11]];
            
            SRAMdpw38d2048  SRAMdpw38d2048_1  (.QB(dout_z0_slice[ 0]),.CLKA(clk),.CENA(choosedSRAM_wr[ 0]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[10:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 0]),.WENB(1'd1),.AB(addrb[10:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({11{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({11{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw38d2048  SRAMdpw38d2048_2  (.QB(dout_z0_slice[ 1]),.CLKA(clk),.CENA(choosedSRAM_wr[ 1]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[10:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 1]),.WENB(1'd1),.AB(addrb[10:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({11{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({11{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw38d2048  SRAMdpw38d2048_3  (.QB(dout_z0_slice[ 2]),.CLKA(clk),.CENA(choosedSRAM_wr[ 2]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[10:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 2]),.WENB(1'd1),.AB(addrb[10:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({11{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({11{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw38d2048  SRAMdpw38d2048_4  (.QB(dout_z0_slice[ 3]),.CLKA(clk),.CENA(choosedSRAM_wr[ 3]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[10:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 3]),.WENB(1'd1),.AB(addrb[10:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({11{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({11{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw38d2048  SRAMdpw38d2048_5  (.QB(dout_z0_slice[ 4]),.CLKA(clk),.CENA(choosedSRAM_wr[ 4]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[10:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 4]),.WENB(1'd1),.AB(addrb[10:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({11{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({11{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw38d2048  SRAMdpw38d2048_6  (.QB(dout_z0_slice[ 5]),.CLKA(clk),.CENA(choosedSRAM_wr[ 5]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[10:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 5]),.WENB(1'd1),.AB(addrb[10:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({11{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({11{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw38d2048  SRAMdpw38d2048_7  (.QB(dout_z0_slice[ 6]),.CLKA(clk),.CENA(choosedSRAM_wr[ 6]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[10:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 6]),.WENB(1'd1),.AB(addrb[10:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({11{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({11{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw38d2048  SRAMdpw38d2048_8  (.QB(dout_z0_slice[ 7]),.CLKA(clk),.CENA(choosedSRAM_wr[ 7]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[10:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 7]),.WENB(1'd1),.AB(addrb[10:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({11{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({11{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
         `endif
      end
    else if(MANUAL_CONFIG == "SRAMdpw40d8192")
      begin:SRAMdpw40d8192
        `ifdef SS_CORNER
            wire [WIDTH-1:0] dout_z0_slice[0:7];
            wire [7:0] choosedSRAM_wr = ~(8'd1 << addra[12:10]);
            wire [7:0] choosedSRAM_rd = ~(8'd1 << addrb[12:10]);
            reg [13:10] addrb_z1;
            always@(posedge clk) addrb_z1[12:10] <= addrb[12:10];
            assign dout_z0 = dout_z0_slice[addrb_z1[12:10]];
            
            SRAMdpw40d1024  SRAMdpw40d1024_1  (.QB(dout_z0_slice[ 0]),.CLKA(clk),.CENA(choosedSRAM_wr[ 0]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[9:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 0]),.WENB(1'd1),.AB(addrb[9:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({10{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({10{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw40d1024  SRAMdpw40d1024_2  (.QB(dout_z0_slice[ 1]),.CLKA(clk),.CENA(choosedSRAM_wr[ 1]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[9:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 1]),.WENB(1'd1),.AB(addrb[9:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({10{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({10{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw40d1024  SRAMdpw40d1024_3  (.QB(dout_z0_slice[ 2]),.CLKA(clk),.CENA(choosedSRAM_wr[ 2]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[9:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 2]),.WENB(1'd1),.AB(addrb[9:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({10{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({10{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw40d1024  SRAMdpw40d1024_4  (.QB(dout_z0_slice[ 3]),.CLKA(clk),.CENA(choosedSRAM_wr[ 3]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[9:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 3]),.WENB(1'd1),.AB(addrb[9:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({10{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({10{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw40d1024  SRAMdpw40d1024_5  (.QB(dout_z0_slice[ 4]),.CLKA(clk),.CENA(choosedSRAM_wr[ 4]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[9:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 4]),.WENB(1'd1),.AB(addrb[9:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({10{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({10{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw40d1024  SRAMdpw40d1024_6  (.QB(dout_z0_slice[ 5]),.CLKA(clk),.CENA(choosedSRAM_wr[ 5]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[9:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 5]),.WENB(1'd1),.AB(addrb[9:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({10{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({10{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw40d1024  SRAMdpw40d1024_7  (.QB(dout_z0_slice[ 6]),.CLKA(clk),.CENA(choosedSRAM_wr[ 6]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[9:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 6]),.WENB(1'd1),.AB(addrb[9:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({10{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({10{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw40d1024  SRAMdpw40d1024_8  (.QB(dout_z0_slice[ 7]),.CLKA(clk),.CENA(choosedSRAM_wr[ 7]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[9:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 7]),.WENB(1'd1),.AB(addrb[9:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({10{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({10{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
         `else
            wire [WIDTH-1:0] dout_z0_slice[0:3];
            wire [3:0] choosedSRAM_wr = ~(4'd1 << addra[12:11]);
            wire [3:0] choosedSRAM_rd = ~(4'd1 << addrb[12:11]);
            reg [12:11] addrb_z1;
            always@(posedge clk) addrb_z1[12:11] <= addrb[12:11];
            assign dout_z0 = dout_z0_slice[addrb_z1[12:11]];
            
            SRAMdpw40d2048  SRAMdpw40d2048_1  (.QB(dout_z0_slice[ 0]),.CLKA(clk),.CENA(choosedSRAM_wr[ 0]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[10:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 0]),.WENB(1'd1),.AB(addrb[10:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({11{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({11{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw40d2048  SRAMdpw40d2048_2  (.QB(dout_z0_slice[ 1]),.CLKA(clk),.CENA(choosedSRAM_wr[ 1]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[10:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 1]),.WENB(1'd1),.AB(addrb[10:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({11{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({11{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw40d2048  SRAMdpw40d2048_3  (.QB(dout_z0_slice[ 2]),.CLKA(clk),.CENA(choosedSRAM_wr[ 2]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[10:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 2]),.WENB(1'd1),.AB(addrb[10:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({11{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({11{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw40d2048  SRAMdpw40d2048_4  (.QB(dout_z0_slice[ 3]),.CLKA(clk),.CENA(choosedSRAM_wr[ 3]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[10:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 3]),.WENB(1'd1),.AB(addrb[10:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({11{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({11{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
         `endif
      end
    else if(MANUAL_CONFIG == "SRAMdpw40d16384")
      begin:SRAMdpw40d16384
        `ifdef SS_CORNER
            wire [WIDTH-1:0] dout_z0_slice[0:15];
            wire [15:0] choosedSRAM_wr = ~(16'd1 << addra[13:10]);
            wire [15:0] choosedSRAM_rd = ~(16'd1 << addrb[13:10]);
            reg [13:10] addrb_z1;
            always@(posedge clk) addrb_z1[13:10] <= addrb[13:10];
            assign dout_z0 = dout_z0_slice[addrb_z1[13:10]];
            
            SRAMdpw40d1024  SRAMdpw40d1024_1  (.QB(dout_z0_slice[ 0]),.CLKA(clk),.CENA(choosedSRAM_wr[ 0]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[9:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 0]),.WENB(1'd1),.AB(addrb[9:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({10{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({10{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw40d1024  SRAMdpw40d1024_2  (.QB(dout_z0_slice[ 1]),.CLKA(clk),.CENA(choosedSRAM_wr[ 1]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[9:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 1]),.WENB(1'd1),.AB(addrb[9:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({10{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({10{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw40d1024  SRAMdpw40d1024_3  (.QB(dout_z0_slice[ 2]),.CLKA(clk),.CENA(choosedSRAM_wr[ 2]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[9:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 2]),.WENB(1'd1),.AB(addrb[9:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({10{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({10{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw40d1024  SRAMdpw40d1024_4  (.QB(dout_z0_slice[ 3]),.CLKA(clk),.CENA(choosedSRAM_wr[ 3]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[9:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 3]),.WENB(1'd1),.AB(addrb[9:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({10{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({10{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw40d1024  SRAMdpw40d1024_5  (.QB(dout_z0_slice[ 4]),.CLKA(clk),.CENA(choosedSRAM_wr[ 4]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[9:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 4]),.WENB(1'd1),.AB(addrb[9:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({10{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({10{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw40d1024  SRAMdpw40d1024_6  (.QB(dout_z0_slice[ 5]),.CLKA(clk),.CENA(choosedSRAM_wr[ 5]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[9:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 5]),.WENB(1'd1),.AB(addrb[9:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({10{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({10{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw40d1024  SRAMdpw40d1024_7  (.QB(dout_z0_slice[ 6]),.CLKA(clk),.CENA(choosedSRAM_wr[ 6]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[9:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 6]),.WENB(1'd1),.AB(addrb[9:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({10{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({10{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw40d1024  SRAMdpw40d1024_8  (.QB(dout_z0_slice[ 7]),.CLKA(clk),.CENA(choosedSRAM_wr[ 7]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[9:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 7]),.WENB(1'd1),.AB(addrb[9:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({10{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({10{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw40d1024  SRAMdpw40d1024_9  (.QB(dout_z0_slice[ 8]),.CLKA(clk),.CENA(choosedSRAM_wr[ 8]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[9:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 8]),.WENB(1'd1),.AB(addrb[9:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({10{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({10{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw40d1024  SRAMdpw40d1024_10 (.QB(dout_z0_slice[ 9]),.CLKA(clk),.CENA(choosedSRAM_wr[ 9]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[9:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 9]),.WENB(1'd1),.AB(addrb[9:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({10{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({10{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw40d1024  SRAMdpw40d1024_11 (.QB(dout_z0_slice[10]),.CLKA(clk),.CENA(choosedSRAM_wr[10]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[9:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[10]),.WENB(1'd1),.AB(addrb[9:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({10{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({10{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw40d1024  SRAMdpw40d1024_12 (.QB(dout_z0_slice[11]),.CLKA(clk),.CENA(choosedSRAM_wr[11]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[9:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[11]),.WENB(1'd1),.AB(addrb[9:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({10{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({10{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw40d1024  SRAMdpw40d1024_13 (.QB(dout_z0_slice[12]),.CLKA(clk),.CENA(choosedSRAM_wr[12]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[9:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[12]),.WENB(1'd1),.AB(addrb[9:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({10{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({10{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw40d1024  SRAMdpw40d1024_14 (.QB(dout_z0_slice[13]),.CLKA(clk),.CENA(choosedSRAM_wr[13]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[9:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[13]),.WENB(1'd1),.AB(addrb[9:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({10{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({10{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw40d1024  SRAMdpw40d1024_15 (.QB(dout_z0_slice[14]),.CLKA(clk),.CENA(choosedSRAM_wr[14]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[9:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[14]),.WENB(1'd1),.AB(addrb[9:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({10{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({10{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw40d1024  SRAMdpw40d1024_16 (.QB(dout_z0_slice[15]),.CLKA(clk),.CENA(choosedSRAM_wr[15]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[9:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[15]),.WENB(1'd1),.AB(addrb[9:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({10{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({10{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
         `else
            wire [WIDTH-1:0] dout_z0_slice[0:7];
            wire [7:0] choosedSRAM_wr = ~(16'd1 << addra[13:11]);
            wire [7:0] choosedSRAM_rd = ~(16'd1 << addrb[13:11]);
            reg [13:11] addrb_z1;
            always@(posedge clk) addrb_z1[13:11] <= addrb[13:11];
            assign dout_z0 = dout_z0_slice[addrb_z1[13:11]];
            
            SRAMdpw40d2048  SRAMdpw40d2048_1  (.QB(dout_z0_slice[ 0]),.CLKA(clk),.CENA(choosedSRAM_wr[ 0]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[10:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 0]),.WENB(1'd1),.AB(addrb[10:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({11{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({11{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw40d2048  SRAMdpw40d2048_2  (.QB(dout_z0_slice[ 1]),.CLKA(clk),.CENA(choosedSRAM_wr[ 1]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[10:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 1]),.WENB(1'd1),.AB(addrb[10:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({11{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({11{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw40d2048  SRAMdpw40d2048_3  (.QB(dout_z0_slice[ 2]),.CLKA(clk),.CENA(choosedSRAM_wr[ 2]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[10:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 2]),.WENB(1'd1),.AB(addrb[10:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({11{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({11{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw40d2048  SRAMdpw40d2048_4  (.QB(dout_z0_slice[ 3]),.CLKA(clk),.CENA(choosedSRAM_wr[ 3]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[10:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 3]),.WENB(1'd1),.AB(addrb[10:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({11{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({11{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw40d2048  SRAMdpw40d2048_5  (.QB(dout_z0_slice[ 4]),.CLKA(clk),.CENA(choosedSRAM_wr[ 4]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[10:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 4]),.WENB(1'd1),.AB(addrb[10:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({11{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({11{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw40d2048  SRAMdpw40d2048_6  (.QB(dout_z0_slice[ 5]),.CLKA(clk),.CENA(choosedSRAM_wr[ 5]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[10:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 5]),.WENB(1'd1),.AB(addrb[10:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({11{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({11{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw40d2048  SRAMdpw40d2048_7  (.QB(dout_z0_slice[ 6]),.CLKA(clk),.CENA(choosedSRAM_wr[ 6]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[10:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 6]),.WENB(1'd1),.AB(addrb[10:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({11{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({11{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
            SRAMdpw40d2048  SRAMdpw40d2048_8  (.QB(dout_z0_slice[ 7]),.CLKA(clk),.CENA(choosedSRAM_wr[ 7]),.WENA(fifocontroler_we_n_toRAM), .AA(addra[10:0]),.DA(din),.CLKB(clk),.CENB(choosedSRAM_rd[ 7]),.WENB(1'd1),.AB(addrb[10:0]),.DB({WIDTH{1'd0}}),.EMAA(EMAA),.EMAWA(EMAWA),.EMAB(EMAB),.EMAWB(EMAWB),.TENA(1'd1),.TCENA(1'd1),.TWENA(1'b1),.TAA({11{1'd0}}),.TDA({WIDTH{1'd0}}),.TENB(1'd1),.TCENB(1'd1),.TWENB(1'b1),.TAB({11{1'd0}}),.TDB({WIDTH{1'd0}}),.RET1N(RET1N),.SIA(2'd0),.SEA(1'd0),.DFTRAMBYP(1'd0),.SIB(2'd0),.SEB(1'd0),.COLLDISN(1'd1), .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB());
         `endif
      end
    else if(MANUAL_CONFIG == "SRAMdpw512d256")
      begin:SRAMdpw64d256
            SRAMdpw64d256  SRAMdpw64d256_1  (
                                .QB(dout_z0[63:0]), //  output [3:0] QB;
                                .CLKA(clk),//  input  CLKA;
                                .CENA(fifocontroler_we_n_toRAM), //  input  CENA;
                                .WENA(fifocontroler_we_n_toRAM), //  input WENA;
                                .AA(addra), //  input [7:0] AA;
                                .DA(din[63:0]), //  input [3:0] DA;
                                .CLKB(clk), //  input  CLKB;
                                .CENB(1'd0), //  input  CENB;
                                .WENB(1'd1), //  input WENB;
                                .AB(addrb), //  input [7:0] AB;
                                .DB({64{1'd0}}), //  input [3:0] DB;
                                .EMAA(EMAA), //  input [2:0] EMAA;
                                .EMAWA(EMAWA), //  input [1:0] EMAWA;
                                .EMAB(EMAB), //  input [2:0] EMAB;
                                .EMAWB(EMAWB), //  input [1:0] EMAWB;
                                .TENA(1'd1), //  input  TENA;
                                .TCENA(1'd1), //  input  TCENA;
                                .TWENA(1'b1), //  input TWENA;
                                .TAA({8{1'd0}}), //  input [7:0] TAA;
                                .TDA({64{1'd0}}), //  input [3:0] TDA;
                                .TENB(1'd1), //  input  TENB;
                                .TCENB(1'd1), //  input  TCENB;
                                .TWENB(1'b1), //  input TWENB;
                                .TAB({8{1'd0}}), //  input [7:0] TAB;
                                .TDB({64{1'd0}}), //  input [3:0] TDB;
                                .RET1N(RET1N), //  input  RET1N;
                                .SIA(2'd0), //  input [1:0] SIA;
                                .SEA(1'd0), //  input  SEA;
                                .DFTRAMBYP(1'd0), //  input  DFTRAMBYP;
                                .SIB(2'd0), //  input [1:0] SIB;
                                .SEB(1'd0), //  input  SEB;
                                .COLLDISN(1'd1) //  input  COLLDISN;
                                , .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB()
                                );
            SRAMdpw64d256  SRAMdpw64d256_2  (
                                .QB(dout_z0[127:64]), //  output [3:0] QB;
                                .CLKA(clk),//  input  CLKA;
                                .CENA(fifocontroler_we_n_toRAM), //  input  CENA;
                                .WENA(fifocontroler_we_n_toRAM), //  input WENA;
                                .AA(addra), //  input [7:0] AA;
                                .DA(din[127:64]), //  input [3:0] DA;
                                .CLKB(clk), //  input  CLKB;
                                .CENB(1'd0), //  input  CENB;
                                .WENB(1'd1), //  input WENB;
                                .AB(addrb), //  input [7:0] AB;
                                .DB({64{1'd0}}), //  input [3:0] DB;
                                .EMAA(EMAA), //  input [2:0] EMAA;
                                .EMAWA(EMAWA), //  input [1:0] EMAWA;
                                .EMAB(EMAB), //  input [2:0] EMAB;
                                .EMAWB(EMAWB), //  input [1:0] EMAWB;
                                .TENA(1'd1), //  input  TENA;
                                .TCENA(1'd1), //  input  TCENA;
                                .TWENA(1'b1), //  input TWENA;
                                .TAA({8{1'd0}}), //  input [7:0] TAA;
                                .TDA({64{1'd0}}), //  input [3:0] TDA;
                                .TENB(1'd1), //  input  TENB;
                                .TCENB(1'd1), //  input  TCENB;
                                .TWENB(1'b1), //  input TWENB;
                                .TAB({8{1'd0}}), //  input [7:0] TAB;
                                .TDB({64{1'd0}}), //  input [3:0] TDB;
                                .RET1N(RET1N), //  input  RET1N;
                                .SIA(2'd0), //  input [1:0] SIA;
                                .SEA(1'd0), //  input  SEA;
                                .DFTRAMBYP(1'd0), //  input  DFTRAMBYP;
                                .SIB(2'd0), //  input [1:0] SIB;
                                .SEB(1'd0), //  input  SEB;
                                .COLLDISN(1'd1) //  input  COLLDISN;
                                , .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB()
                                );
            SRAMdpw64d256  SRAMdpw64d256_3  (
                                .QB(dout_z0[191:128]), //  output [3:0] QB;
                                .CLKA(clk),//  input  CLKA;
                                .CENA(fifocontroler_we_n_toRAM), //  input  CENA;
                                .WENA(fifocontroler_we_n_toRAM), //  input WENA;
                                .AA(addra), //  input [7:0] AA;
                                .DA(din[191:128]), //  input [3:0] DA;
                                .CLKB(clk), //  input  CLKB;
                                .CENB(1'd0), //  input  CENB;
                                .WENB(1'd1), //  input WENB;
                                .AB(addrb), //  input [7:0] AB;
                                .DB({64{1'd0}}), //  input [3:0] DB;
                                .EMAA(EMAA), //  input [2:0] EMAA;
                                .EMAWA(EMAWA), //  input [1:0] EMAWA;
                                .EMAB(EMAB), //  input [2:0] EMAB;
                                .EMAWB(EMAWB), //  input [1:0] EMAWB;
                                .TENA(1'd1), //  input  TENA;
                                .TCENA(1'd1), //  input  TCENA;
                                .TWENA(1'b1), //  input TWENA;
                                .TAA({8{1'd0}}), //  input [7:0] TAA;
                                .TDA({64{1'd0}}), //  input [3:0] TDA;
                                .TENB(1'd1), //  input  TENB;
                                .TCENB(1'd1), //  input  TCENB;
                                .TWENB(1'b1), //  input TWENB;
                                .TAB({8{1'd0}}), //  input [7:0] TAB;
                                .TDB({64{1'd0}}), //  input [3:0] TDB;
                                .RET1N(RET1N), //  input  RET1N;
                                .SIA(2'd0), //  input [1:0] SIA;
                                .SEA(1'd0), //  input  SEA;
                                .DFTRAMBYP(1'd0), //  input  DFTRAMBYP;
                                .SIB(2'd0), //  input [1:0] SIB;
                                .SEB(1'd0), //  input  SEB;
                                .COLLDISN(1'd1) //  input  COLLDISN;
                                , .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB()
                                );
            SRAMdpw64d256  SRAMdpw64d256_4  (
                                .QB(dout_z0[255:192]), //  output [3:0] QB;
                                .CLKA(clk),//  input  CLKA;
                                .CENA(fifocontroler_we_n_toRAM), //  input  CENA;
                                .WENA(fifocontroler_we_n_toRAM), //  input WENA;
                                .AA(addra), //  input [7:0] AA;
                                .DA(din[255:192]), //  input [3:0] DA;
                                .CLKB(clk), //  input  CLKB;
                                .CENB(1'd0), //  input  CENB;
                                .WENB(1'd1), //  input WENB;
                                .AB(addrb), //  input [7:0] AB;
                                .DB({64{1'd0}}), //  input [3:0] DB;
                                .EMAA(EMAA), //  input [2:0] EMAA;
                                .EMAWA(EMAWA), //  input [1:0] EMAWA;
                                .EMAB(EMAB), //  input [2:0] EMAB;
                                .EMAWB(EMAWB), //  input [1:0] EMAWB;
                                .TENA(1'd1), //  input  TENA;
                                .TCENA(1'd1), //  input  TCENA;
                                .TWENA(1'b1), //  input TWENA;
                                .TAA({8{1'd0}}), //  input [7:0] TAA;
                                .TDA({64{1'd0}}), //  input [3:0] TDA;
                                .TENB(1'd1), //  input  TENB;
                                .TCENB(1'd1), //  input  TCENB;
                                .TWENB(1'b1), //  input TWENB;
                                .TAB({8{1'd0}}), //  input [7:0] TAB;
                                .TDB({64{1'd0}}), //  input [3:0] TDB;
                                .RET1N(RET1N), //  input  RET1N;
                                .SIA(2'd0), //  input [1:0] SIA;
                                .SEA(1'd0), //  input  SEA;
                                .DFTRAMBYP(1'd0), //  input  DFTRAMBYP;
                                .SIB(2'd0), //  input [1:0] SIB;
                                .SEB(1'd0), //  input  SEB;
                                .COLLDISN(1'd1) //  input  COLLDISN;
                                , .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB()
                                );
            SRAMdpw64d256  SRAMdpw64d256_5  (
                                .QB(dout_z0[319:256]), //  output [3:0] QB;
                                .CLKA(clk),//  input  CLKA;
                                .CENA(fifocontroler_we_n_toRAM), //  input  CENA;
                                .WENA(fifocontroler_we_n_toRAM), //  input WENA;
                                .AA(addra), //  input [7:0] AA;
                                .DA(din[319:256]), //  input [3:0] DA;
                                .CLKB(clk), //  input  CLKB;
                                .CENB(1'd0), //  input  CENB;
                                .WENB(1'd1), //  input WENB;
                                .AB(addrb), //  input [7:0] AB;
                                .DB({64{1'd0}}), //  input [3:0] DB;
                                .EMAA(EMAA), //  input [2:0] EMAA;
                                .EMAWA(EMAWA), //  input [1:0] EMAWA;
                                .EMAB(EMAB), //  input [2:0] EMAB;
                                .EMAWB(EMAWB), //  input [1:0] EMAWB;
                                .TENA(1'd1), //  input  TENA;
                                .TCENA(1'd1), //  input  TCENA;
                                .TWENA(1'b1), //  input TWENA;
                                .TAA({8{1'd0}}), //  input [7:0] TAA;
                                .TDA({64{1'd0}}), //  input [3:0] TDA;
                                .TENB(1'd1), //  input  TENB;
                                .TCENB(1'd1), //  input  TCENB;
                                .TWENB(1'b1), //  input TWENB;
                                .TAB({8{1'd0}}), //  input [7:0] TAB;
                                .TDB({64{1'd0}}), //  input [3:0] TDB;
                                .RET1N(RET1N), //  input  RET1N;
                                .SIA(2'd0), //  input [1:0] SIA;
                                .SEA(1'd0), //  input  SEA;
                                .DFTRAMBYP(1'd0), //  input  DFTRAMBYP;
                                .SIB(2'd0), //  input [1:0] SIB;
                                .SEB(1'd0), //  input  SEB;
                                .COLLDISN(1'd1) //  input  COLLDISN;
                                , .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB()
                                );
            SRAMdpw64d256  SRAMdpw64d256_6  (
                                .QB(dout_z0[383:320]), //  output [3:0] QB;
                                .CLKA(clk),//  input  CLKA;
                                .CENA(fifocontroler_we_n_toRAM), //  input  CENA;
                                .WENA(fifocontroler_we_n_toRAM), //  input WENA;
                                .AA(addra), //  input [7:0] AA;
                                .DA(din[383:320]), //  input [3:0] DA;
                                .CLKB(clk), //  input  CLKB;
                                .CENB(1'd0), //  input  CENB;
                                .WENB(1'd1), //  input WENB;
                                .AB(addrb), //  input [7:0] AB;
                                .DB({64{1'd0}}), //  input [3:0] DB;
                                .EMAA(EMAA), //  input [2:0] EMAA;
                                .EMAWA(EMAWA), //  input [1:0] EMAWA;
                                .EMAB(EMAB), //  input [2:0] EMAB;
                                .EMAWB(EMAWB), //  input [1:0] EMAWB;
                                .TENA(1'd1), //  input  TENA;
                                .TCENA(1'd1), //  input  TCENA;
                                .TWENA(1'b1), //  input TWENA;
                                .TAA({8{1'd0}}), //  input [7:0] TAA;
                                .TDA({64{1'd0}}), //  input [3:0] TDA;
                                .TENB(1'd1), //  input  TENB;
                                .TCENB(1'd1), //  input  TCENB;
                                .TWENB(1'b1), //  input TWENB;
                                .TAB({8{1'd0}}), //  input [7:0] TAB;
                                .TDB({64{1'd0}}), //  input [3:0] TDB;
                                .RET1N(RET1N), //  input  RET1N;
                                .SIA(2'd0), //  input [1:0] SIA;
                                .SEA(1'd0), //  input  SEA;
                                .DFTRAMBYP(1'd0), //  input  DFTRAMBYP;
                                .SIB(2'd0), //  input [1:0] SIB;
                                .SEB(1'd0), //  input  SEB;
                                .COLLDISN(1'd1) //  input  COLLDISN;
                                , .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB()
                                );
            SRAMdpw64d256  SRAMdpw64d256_7  (
                                .QB(dout_z0[447:384]), //  output [3:0] QB;
                                .CLKA(clk),//  input  CLKA;
                                .CENA(fifocontroler_we_n_toRAM), //  input  CENA;
                                .WENA(fifocontroler_we_n_toRAM), //  input WENA;
                                .AA(addra), //  input [7:0] AA;
                                .DA(din[447:384]), //  input [3:0] DA;
                                .CLKB(clk), //  input  CLKB;
                                .CENB(1'd0), //  input  CENB;
                                .WENB(1'd1), //  input WENB;
                                .AB(addrb), //  input [7:0] AB;
                                .DB({64{1'd0}}), //  input [3:0] DB;
                                .EMAA(EMAA), //  input [2:0] EMAA;
                                .EMAWA(EMAWA), //  input [1:0] EMAWA;
                                .EMAB(EMAB), //  input [2:0] EMAB;
                                .EMAWB(EMAWB), //  input [1:0] EMAWB;
                                .TENA(1'd1), //  input  TENA;
                                .TCENA(1'd1), //  input  TCENA;
                                .TWENA(1'b1), //  input TWENA;
                                .TAA({8{1'd0}}), //  input [7:0] TAA;
                                .TDA({64{1'd0}}), //  input [3:0] TDA;
                                .TENB(1'd1), //  input  TENB;
                                .TCENB(1'd1), //  input  TCENB;
                                .TWENB(1'b1), //  input TWENB;
                                .TAB({8{1'd0}}), //  input [7:0] TAB;
                                .TDB({64{1'd0}}), //  input [3:0] TDB;
                                .RET1N(RET1N), //  input  RET1N;
                                .SIA(2'd0), //  input [1:0] SIA;
                                .SEA(1'd0), //  input  SEA;
                                .DFTRAMBYP(1'd0), //  input  DFTRAMBYP;
                                .SIB(2'd0), //  input [1:0] SIB;
                                .SEB(1'd0), //  input  SEB;
                                .COLLDISN(1'd1) //  input  COLLDISN;
                                , .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB()
                                );
            SRAMdpw64d256  SRAMdpw64d256_8  (
                                .QB(dout_z0[511:448]), //  output [3:0] QB;
                                .CLKA(clk),//  input  CLKA;
                                .CENA(fifocontroler_we_n_toRAM), //  input  CENA;
                                .WENA(fifocontroler_we_n_toRAM), //  input WENA;
                                .AA(addra), //  input [7:0] AA;
                                .DA(din[511:448]), //  input [3:0] DA;
                                .CLKB(clk), //  input  CLKB;
                                .CENB(1'd0), //  input  CENB;
                                .WENB(1'd1), //  input WENB;
                                .AB(addrb), //  input [7:0] AB;
                                .DB({64{1'd0}}), //  input [3:0] DB;
                                .EMAA(EMAA), //  input [2:0] EMAA;
                                .EMAWA(EMAWA), //  input [1:0] EMAWA;
                                .EMAB(EMAB), //  input [2:0] EMAB;
                                .EMAWB(EMAWB), //  input [1:0] EMAWB;
                                .TENA(1'd1), //  input  TENA;
                                .TCENA(1'd1), //  input  TCENA;
                                .TWENA(1'b1), //  input TWENA;
                                .TAA({8{1'd0}}), //  input [7:0] TAA;
                                .TDA({64{1'd0}}), //  input [3:0] TDA;
                                .TENB(1'd1), //  input  TENB;
                                .TCENB(1'd1), //  input  TCENB;
                                .TWENB(1'b1), //  input TWENB;
                                .TAB({8{1'd0}}), //  input [7:0] TAB;
                                .TDB({64{1'd0}}), //  input [3:0] TDB;
                                .RET1N(RET1N), //  input  RET1N;
                                .SIA(2'd0), //  input [1:0] SIA;
                                .SEA(1'd0), //  input  SEA;
                                .DFTRAMBYP(1'd0), //  input  DFTRAMBYP;
                                .SIB(2'd0), //  input [1:0] SIB;
                                .SEB(1'd0), //  input  SEB;
                                .COLLDISN(1'd1) //  input  COLLDISN;
                                , .CENYA(), .WENYA(), .AYA(), .CENYB(), .WENYB(), .AYB(), .QA(), .SOA(), .SOB()
                                );
      end
    else if(CHOOSED_WIDTH == 1 && CHOOSED_DEPTH == 64)
	  begin:DWsdpw1d64
        DW_ram_r_w_s_dff #(.data_width(1), .depth(64), .rst_mode(0))
					DWsdpw1d64 (
								.clk(clk), 
								.rst_n(~srst), 
								.cs_n(1'd0),
								.wr_n(fifocontroler_we_n_toRAM), 
								.rd_addr({{(ADDRESS_WIDTH_OF_RAM-ADDRESS_WIDTH){1'd0}},addrb}), 
								.wr_addr({{(ADDRESS_WIDTH_OF_RAM-ADDRESS_WIDTH){1'd0}},addra}),
								.data_in({{(CHOOSED_WIDTH-WIDTH){1'd0}},din}), 
								.data_out({dout_z0}) 
								);
	  end
    else if(CHOOSED_WIDTH == 1 && CHOOSED_DEPTH == 512)
	  begin:DWsdpw1d512
        DW_ram_r_w_s_dff #(.data_width(1), .depth(512), .rst_mode(0))
					DWsdpw1d512 (
								.clk(clk), 
								.rst_n(~srst), 
								.cs_n(1'd0),
								.wr_n(fifocontroler_we_n_toRAM), 
								.rd_addr({{(ADDRESS_WIDTH_OF_RAM-ADDRESS_WIDTH){1'd0}},addrb}), 
								.wr_addr({{(ADDRESS_WIDTH_OF_RAM-ADDRESS_WIDTH){1'd0}},addra}),
								.data_in({{(CHOOSED_WIDTH-WIDTH){1'd0}},din}), 
								.data_out({dout_z0}) 
								);
	  end
    else if(CHOOSED_WIDTH == 2 && CHOOSED_DEPTH == 256)
	  begin:DWsdpw2d256
        DW_ram_r_w_s_dff #(.data_width(2), .depth(256), .rst_mode(0))
					DWsdpw2d256 (
								.clk(clk), 
								.rst_n(~srst), 
								.cs_n(1'd0),
								.wr_n(fifocontroler_we_n_toRAM), 
								.rd_addr({{(ADDRESS_WIDTH_OF_RAM-ADDRESS_WIDTH){1'd0}},addrb}), 
								.wr_addr({{(ADDRESS_WIDTH_OF_RAM-ADDRESS_WIDTH){1'd0}},addra}),
								.data_in({{(CHOOSED_WIDTH-WIDTH){1'd0}},din}), 
								.data_out({dout_z0}) 
								);
	  end
    else if(CHOOSED_WIDTH == 8 && CHOOSED_DEPTH == 16)
	  begin:RGFdpw8d16
        RGFdpw8d16 RGFdpw8d16(
								.QA({dout_z0}), 
								.CLKA(clk), 
								.CENA(1'd0), 
								.AA({{(ADDRESS_WIDTH_OF_RAM-ADDRESS_WIDTH){1'd0}},addrb}), 
								.CLKB(clk), 
								.CENB(fifocontroler_we_n_toRAM), 
								.AB({{(ADDRESS_WIDTH_OF_RAM-ADDRESS_WIDTH){1'd0}},addra}), 
								.DB({{(CHOOSED_WIDTH-WIDTH){1'd0}},din}), 
								.EMAA(EMAA), 
								.EMAB(EMAB), 
								.RET1N(RET1N), 
								.COLLDISN(1'd1)
								);
	  end
    else if(CHOOSED_WIDTH == 8 && CHOOSED_DEPTH == 32)
	  begin:RGFdpw8d32
        RGFdpw8d32 RGFdpw8d32(
								.QA({dout_z0}), 
								.CLKA(clk), 
								.CENA(1'd0), 
								.AA({{(ADDRESS_WIDTH_OF_RAM-ADDRESS_WIDTH){1'd0}},addrb}), 
								.CLKB(clk), 
								.CENB(fifocontroler_we_n_toRAM), 
								.AB({{(ADDRESS_WIDTH_OF_RAM-ADDRESS_WIDTH){1'd0}},addra}), 
								.DB({{(CHOOSED_WIDTH-WIDTH){1'd0}},din}), 
								.EMAA(EMAA), 
								.EMAB(EMAB), 
								.RET1N(RET1N), 
								.COLLDISN(1'd1)
								);
	  end
    else if(CHOOSED_WIDTH == 16 && CHOOSED_DEPTH == 2048)
	  begin:SRAMdpw16d2048
        SRAMdpw16d2048  SRAMdpw16d2048  (
                                .CENYA(), //  output  CENYA;
                                .WENYA(), //  output  WENYA;
                                .AYA(), //  output [7:0] AYA;
                                .CENYB(), //  output  CENYB;
                                .WENYB(), //  output  WENYB;
                                .AYB(), //  output [7:0] AYB;
                                .QA(), //  output [3:0] QA;
                                .QB({dout_z0}), //  output [3:0] QB;
                                .SOA(), //  output [1:0] SOA;
                                .SOB(), //  output [1:0] SOB;
                                .CLKA(clk),//  input  CLKA;
                                .CENA(fifocontroler_we_n_toRAM), //  input  CENA;
                                .WENA(fifocontroler_we_n_toRAM), //  input WENA;
                                .AA({{(ADDRESS_WIDTH_OF_RAM-ADDRESS_WIDTH){1'd0}},addra}), //  input [7:0] AA;
                                .DA({{(CHOOSED_WIDTH-WIDTH){1'd0}},din}), //  input [3:0] DA;
                                .CLKB(clk), //  input  CLKB;
                                .CENB(1'd0), //  input  CENB;
                                .WENB(1'd1), //  input WENB;
                                .AB({{(ADDRESS_WIDTH_OF_RAM-ADDRESS_WIDTH){1'd0}},addrb}), //  input [7:0] AB;
                                .DB({WIDTH{1'd0}}), //  input [3:0] DB;
                                .EMAA(EMAA), //  input [2:0] EMAA;
                                .EMAWA(EMAWA), //  input [1:0] EMAWA;
                                .EMAB(EMAB), //  input [2:0] EMAB;
                                .EMAWB(EMAWB), //  input [1:0] EMAWB;
                                .TENA(1'd1), //  input  TENA;
                                .TCENA(1'd1), //  input  TCENA;
                                .TWENA(1'b1), //  input TWENA;
                                .TAA({ADDRESS_WIDTH{1'd0}}), //  input [7:0] TAA;
                                .TDA({WIDTH{1'd0}}), //  input [3:0] TDA;
                                .TENB(1'd1), //  input  TENB;
                                .TCENB(1'd1), //  input  TCENB;
                                .TWENB(1'b1), //  input TWENB;
                                .TAB({ADDRESS_WIDTH{1'd0}}), //  input [7:0] TAB;
                                .TDB({WIDTH{1'd0}}), //  input [3:0] TDB;
                                .RET1N(RET1N), //  input  RET1N;
                                .SIA(2'd0), //  input [1:0] SIA;
                                .SEA(1'd0), //  input  SEA;
                                .DFTRAMBYP(1'd0), //  input  DFTRAMBYP;
                                .SIB(2'd0), //  input [1:0] SIB;
                                .SEB(1'd0), //  input  SEB;
                                .COLLDISN(1'd1) //  input  COLLDISN;
                                );
	  end
    else if(CHOOSED_WIDTH == 32 && CHOOSED_DEPTH == 256)
	  begin:RGFdpw32d256
        RGFdpw32d256 RGFdpw32d256(
								.QA({dout_z0}), 
								.CLKA(clk), 
								.CENA(1'd0), 
								.AA({{(ADDRESS_WIDTH_OF_RAM-ADDRESS_WIDTH){1'd0}},addrb}), 
								.CLKB(clk), 
								.CENB(fifocontroler_we_n_toRAM), 
								.AB({{(ADDRESS_WIDTH_OF_RAM-ADDRESS_WIDTH){1'd0}},addra}), 
								.DB({{(CHOOSED_WIDTH-WIDTH){1'd0}},din}), 
								.EMAA(EMAA), 
								.EMAB(EMAB), 
								.RET1N(RET1N), 
								.COLLDISN(1'd1)
								);
	  end
    else if(CHOOSED_WIDTH == 38 && CHOOSED_DEPTH == 32)
	  begin:RGFdpw38d32
        RGFdpw38d32 RGFdpw38d32(
								.QA({dout_z0}), 
								.CLKA(clk), 
								.CENA(1'd0), 
								.AA({{(ADDRESS_WIDTH_OF_RAM-ADDRESS_WIDTH){1'd0}},addrb}), 
								.CLKB(clk), 
								.CENB(fifocontroler_we_n_toRAM), 
								.AB({{(ADDRESS_WIDTH_OF_RAM-ADDRESS_WIDTH){1'd0}},addra}), 
								.DB({{(CHOOSED_WIDTH-WIDTH){1'd0}},din}), 
								.EMAA(EMAA), 
								.EMAB(EMAB), 
								.RET1N(RET1N), 
								.COLLDISN(1'd1)
								);
	  end
    else if(CHOOSED_WIDTH == 38 && CHOOSED_DEPTH == 512)
	  begin:SRAMdpw38d512
        SRAMdpw38d512  SRAMdpw38d512  (
                                .CENYA(), //  output  CENYA;
                                .WENYA(), //  output  WENYA;
                                .AYA(), //  output [7:0] AYA;
                                .CENYB(), //  output  CENYB;
                                .WENYB(), //  output  WENYB;
                                .AYB(), //  output [7:0] AYB;
                                .QA(), //  output [3:0] QA;
                                .QB({dout_z0}), //  output [3:0] QB;
                                .SOA(), //  output [1:0] SOA;
                                .SOB(), //  output [1:0] SOB;
                                .CLKA(clk),//  input  CLKA;
                                .CENA(fifocontroler_we_n_toRAM), //  input  CENA;
                                .WENA(fifocontroler_we_n_toRAM), //  input WENA;
                                .AA({{(ADDRESS_WIDTH_OF_RAM-ADDRESS_WIDTH){1'd0}},addra}), //  input [7:0] AA;
                                .DA({{(CHOOSED_WIDTH-WIDTH){1'd0}},din}), //  input [3:0] DA;
                                .CLKB(clk), //  input  CLKB;
                                .CENB(1'd0), //  input  CENB;
                                .WENB(1'd1), //  input WENB;
                                .AB({{(ADDRESS_WIDTH_OF_RAM-ADDRESS_WIDTH){1'd0}},addrb}), //  input [7:0] AB;
                                .DB({WIDTH{1'd0}}), //  input [3:0] DB;
                                .EMAA(EMAA), //  input [2:0] EMAA;
                                .EMAWA(EMAWA), //  input [1:0] EMAWA;
                                .EMAB(EMAB), //  input [2:0] EMAB;
                                .EMAWB(EMAWB), //  input [1:0] EMAWB;
                                .TENA(1'd1), //  input  TENA;
                                .TCENA(1'd1), //  input  TCENA;
                                .TWENA(1'b1), //  input TWENA;
                                .TAA({ADDRESS_WIDTH{1'd0}}), //  input [7:0] TAA;
                                .TDA({WIDTH{1'd0}}), //  input [3:0] TDA;
                                .TENB(1'd1), //  input  TENB;
                                .TCENB(1'd1), //  input  TCENB;
                                .TWENB(1'b1), //  input TWENB;
                                .TAB({ADDRESS_WIDTH{1'd0}}), //  input [7:0] TAB;
                                .TDB({WIDTH{1'd0}}), //  input [3:0] TDB;
                                .RET1N(RET1N), //  input  RET1N;
                                .SIA(2'd0), //  input [1:0] SIA;
                                .SEA(1'd0), //  input  SEA;
                                .DFTRAMBYP(1'd0), //  input  DFTRAMBYP;
                                .SIB(2'd0), //  input [1:0] SIB;
                                .SEB(1'd0), //  input  SEB;
                                .COLLDISN(1'd1) //  input  COLLDISN;
                                );
	  end
    else if(CHOOSED_WIDTH == 38 && CHOOSED_DEPTH == 1024)
	  begin:SRAMdpw38d1024
        SRAMdpw38d1024  SRAMdpw38d1024  (
                                .CENYA(), //  output  CENYA;
                                .WENYA(), //  output  WENYA;
                                .AYA(), //  output [7:0] AYA;
                                .CENYB(), //  output  CENYB;
                                .WENYB(), //  output  WENYB;
                                .AYB(), //  output [7:0] AYB;
                                .QA(), //  output [3:0] QA;
                                .QB({dout_z0}), //  output [3:0] QB;
                                .SOA(), //  output [1:0] SOA;
                                .SOB(), //  output [1:0] SOB;
                                .CLKA(clk),//  input  CLKA;
                                .CENA(fifocontroler_we_n_toRAM), //  input  CENA;
                                .WENA(fifocontroler_we_n_toRAM), //  input WENA;
                                .AA({{(ADDRESS_WIDTH_OF_RAM-ADDRESS_WIDTH){1'd0}},addra}), //  input [7:0] AA;
                                .DA({{(CHOOSED_WIDTH-WIDTH){1'd0}},din}), //  input [3:0] DA;
                                .CLKB(clk), //  input  CLKB;
                                .CENB(1'd0), //  input  CENB;
                                .WENB(1'd1), //  input WENB;
                                .AB({{(ADDRESS_WIDTH_OF_RAM-ADDRESS_WIDTH){1'd0}},addrb}), //  input [7:0] AB;
                                .DB({WIDTH{1'd0}}), //  input [3:0] DB;
                                .EMAA(EMAA), //  input [2:0] EMAA;
                                .EMAWA(EMAWA), //  input [1:0] EMAWA;
                                .EMAB(EMAB), //  input [2:0] EMAB;
                                .EMAWB(EMAWB), //  input [1:0] EMAWB;
                                .TENA(1'd1), //  input  TENA;
                                .TCENA(1'd1), //  input  TCENA;
                                .TWENA(1'b1), //  input TWENA;
                                .TAA({ADDRESS_WIDTH{1'd0}}), //  input [7:0] TAA;
                                .TDA({WIDTH{1'd0}}), //  input [3:0] TDA;
                                .TENB(1'd1), //  input  TENB;
                                .TCENB(1'd1), //  input  TCENB;
                                .TWENB(1'b1), //  input TWENB;
                                .TAB({ADDRESS_WIDTH{1'd0}}), //  input [7:0] TAB;
                                .TDB({WIDTH{1'd0}}), //  input [3:0] TDB;
                                .RET1N(RET1N), //  input  RET1N;
                                .SIA(2'd0), //  input [1:0] SIA;
                                .SEA(1'd0), //  input  SEA;
                                .DFTRAMBYP(1'd0), //  input  DFTRAMBYP;
                                .SIB(2'd0), //  input [1:0] SIB;
                                .SEB(1'd0), //  input  SEB;
                                .COLLDISN(1'd1) //  input  COLLDISN;
                                );
	  end
    else if(CHOOSED_WIDTH == 40 && CHOOSED_DEPTH == 256)
	  begin:RGFdpw40d256
        RGFdpw40d256 RGFdpw40d256(
								.QA({dout_z0}), 
								.CLKA(clk), 
								.CENA(1'd0), 
								.AA({{(ADDRESS_WIDTH_OF_RAM-ADDRESS_WIDTH){1'd0}},addrb}), 
								.CLKB(clk), 
								.CENB(fifocontroler_we_n_toRAM), 
								.AB({{(ADDRESS_WIDTH_OF_RAM-ADDRESS_WIDTH){1'd0}},addra}), 
								.DB({{(CHOOSED_WIDTH-WIDTH){1'd0}},din}), 
								.EMAA(EMAA), 
								.EMAB(EMAB), 
								.RET1N(RET1N), 
								.COLLDISN(1'd1)
								);
	  end
    else if(CHOOSED_WIDTH == 40 && CHOOSED_DEPTH == 1024)
	  begin:SRAMdpw40d1024
        SRAMdpw40d1024  SRAMdpw40d1024  (
                                .CENYA(), //  output  CENYA;
                                .WENYA(), //  output  WENYA;
                                .AYA(), //  output [7:0] AYA;
                                .CENYB(), //  output  CENYB;
                                .WENYB(), //  output  WENYB;
                                .AYB(), //  output [7:0] AYB;
                                .QA(), //  output [3:0] QA;
                                .QB({dout_z0}), //  output [3:0] QB;
                                .SOA(), //  output [1:0] SOA;
                                .SOB(), //  output [1:0] SOB;
                                .CLKA(clk),//  input  CLKA;
                                .CENA(fifocontroler_we_n_toRAM), //  input  CENA;
                                .WENA(fifocontroler_we_n_toRAM), //  input WENA;
                                .AA({{(ADDRESS_WIDTH_OF_RAM-ADDRESS_WIDTH){1'd0}},addra}), //  input [7:0] AA;
                                .DA({{(CHOOSED_WIDTH-WIDTH){1'd0}},din}), //  input [3:0] DA;
                                .CLKB(clk), //  input  CLKB;
                                .CENB(1'd0), //  input  CENB;
                                .WENB(1'd1), //  input WENB;
                                .AB({{(ADDRESS_WIDTH_OF_RAM-ADDRESS_WIDTH){1'd0}},addrb}), //  input [7:0] AB;
                                .DB({WIDTH{1'd0}}), //  input [3:0] DB;
                                .EMAA(EMAA), //  input [2:0] EMAA;
                                .EMAWA(EMAWA), //  input [1:0] EMAWA;
                                .EMAB(EMAB), //  input [2:0] EMAB;
                                .EMAWB(EMAWB), //  input [1:0] EMAWB;
                                .TENA(1'd1), //  input  TENA;
                                .TCENA(1'd1), //  input  TCENA;
                                .TWENA(1'b1), //  input TWENA;
                                .TAA({ADDRESS_WIDTH{1'd0}}), //  input [7:0] TAA;
                                .TDA({WIDTH{1'd0}}), //  input [3:0] TDA;
                                .TENB(1'd1), //  input  TENB;
                                .TCENB(1'd1), //  input  TCENB;
                                .TWENB(1'b1), //  input TWENB;
                                .TAB({ADDRESS_WIDTH{1'd0}}), //  input [7:0] TAB;
                                .TDB({WIDTH{1'd0}}), //  input [3:0] TDB;
                                .RET1N(RET1N), //  input  RET1N;
                                .SIA(2'd0), //  input [1:0] SIA;
                                .SEA(1'd0), //  input  SEA;
                                .DFTRAMBYP(1'd0), //  input  DFTRAMBYP;
                                .SIB(2'd0), //  input [1:0] SIB;
                                .SEB(1'd0), //  input  SEB;
                                .COLLDISN(1'd1) //  input  COLLDISN;
                                );
	  end
endgenerate

reg [ADDRESS_WIDTH-1:0] addra_z1;
reg [WIDTH-1:0] din_z1;
always@(posedge clk or posedge srst)
begin
    if(srst)
      begin
        addra_z1 <= {ADDRESS_WIDTH{1'd0}};
        din_z1 <= {WIDTH{1'd0}};
      end
    else
      begin
        if(wr_en)
          begin
            addra_z1 <= addra;
            din_z1 <= din;
          end
        else
          begin
            addra_z1 <= addra_z1;
            din_z1 <= din_z1;
          end
      end
end
reg [WIDTH-1:0] dout_z1,dout_z2,dout_z3,dout_z4;
reg             rd_en_z1;
always@(posedge clk or posedge srst)
begin
    if(srst)
        rd_en_z1 <= 1'd0;
    else
        rd_en_z1 <= rd_en;
end
reg             wr_en_z1;
always@(posedge clk or posedge srst)
begin
    if(srst)
        wr_en_z1 <= 1'd0;
    else
        wr_en_z1 <= wr_en;
end
generate 
    if(OUTPUT_DELAY == 0 && FIRST_WORD_FALL_THROUGH == 0 && DWorSMIC == "DW")
      begin:DWOD0
        always@(posedge clk or posedge srst)
          begin
            if(srst)
                dout_z1 <= {WIDTH{1'd0}};
            else if(rd_en)
                dout_z1 <= dout_z0;
            else
                dout_z1 <= dout_z1;
          end
        assign dout = (rd_en)?dout_z0:dout_z1;
      end
    else if(OUTPUT_DELAY == 1 && FIRST_WORD_FALL_THROUGH == 0 && DWorSMIC == "DW")
      begin:DWOD1
        always@(posedge clk or posedge srst)
          begin
			if(srst)
				dout_z1 <= {WIDTH{1'd0}};
            else if(rd_en && (addra_z1 == addrb) && wr_en_z1)
                dout_z1 <= din_z1;
            else if(rd_en)
                dout_z1 <= dout_z0;
            else
                dout_z1 <= dout_z1;
          end  
        assign dout = dout_z1;
      end
    else if(OUTPUT_DELAY == 2 && FIRST_WORD_FALL_THROUGH == 0 && DWorSMIC == "DW")
      begin:DWOD2
        always@(posedge clk or posedge srst)
          begin
            if(srst)
              begin
                dout_z1 <= {WIDTH{1'd0}};
                dout_z2 <= {WIDTH{1'd0}};
              end  
            else if(rd_en && (addra_z1 == addrb) && wr_en_z1)
              begin
                dout_z1 <= din_z1;
                dout_z2 <= dout_z1;
              end  
            else if(rd_en)
              begin
                dout_z1 <= dout_z0;
                dout_z2 <= dout_z1;
              end  
            else
              begin
                dout_z1 <= dout_z1;
                dout_z2 <= dout_z1;
              end
          end  
        assign dout = dout_z2;
      end
    else if(OUTPUT_DELAY == 3 && FIRST_WORD_FALL_THROUGH == 0 && DWorSMIC == "DW")
      begin:DWOD3
        always@(posedge clk or posedge srst)
          begin
            if(srst)
              begin
                dout_z1 <= {WIDTH{1'd0}};
                dout_z2 <= {WIDTH{1'd0}};
                dout_z3 <= {WIDTH{1'd0}};
              end  
            else if(rd_en && (addra_z1 == addrb) && wr_en_z1)
              begin
                dout_z1 <= din_z1;
                dout_z2 <= dout_z1;
                dout_z3 <= dout_z2;
              end  
            else if(rd_en)
              begin
                dout_z1 <= dout_z0;
                dout_z2 <= dout_z1;
                dout_z3 <= dout_z2;
              end  
            else
              begin
                dout_z1 <= dout_z1;
                dout_z2 <= dout_z1;
                dout_z3 <= dout_z2;
              end  
          end
        assign dout = dout_z3;
      end
    else if(OUTPUT_DELAY == 4 && FIRST_WORD_FALL_THROUGH == 0 && DWorSMIC == "DW")
      begin:DWOD4
        always@(posedge clk or posedge srst)
          begin
            if(srst)
              begin
                dout_z1 <= {WIDTH{1'd0}};
                dout_z2 <= {WIDTH{1'd0}};
                dout_z3 <= {WIDTH{1'd0}};
                dout_z4 <= {WIDTH{1'd0}};
              end  
            else if(rd_en && (addra_z1 == addrb) && wr_en_z1)
              begin
                dout_z1 <= din_z1;
                dout_z2 <= dout_z1;
                dout_z3 <= dout_z2;
                dout_z4 <= dout_z3;
              end  
            else if(rd_en)
              begin
                dout_z1 <= dout_z0;
                dout_z2 <= dout_z1;
                dout_z3 <= dout_z2;
                dout_z4 <= dout_z3;
              end  
            else
              begin
                dout_z1 <= dout_z1;
                dout_z2 <= dout_z1;
                dout_z3 <= dout_z2;
                dout_z4 <= dout_z3;
              end  
          end
        assign dout = dout_z4;
      end
    else if(OUTPUT_DELAY == 1 && FIRST_WORD_FALL_THROUGH == 0)
      begin:OD1
        always@(posedge clk or posedge srst)
          begin
            if(srst)
                dout_z1 <= {WIDTH{1'd0}};
            else if(rd_en_z1)
                dout_z1 <= dout_z0;
            else
                dout_z1 <= dout_z1;
          end
        assign dout = (rd_en_z1)?dout_z0:dout_z1;
      end
    else if(OUTPUT_DELAY == 2 && FIRST_WORD_FALL_THROUGH == 0)
      begin:OD2
        always@(posedge clk or posedge srst)
          begin
			if(srst)
				dout_z1 <= {WIDTH{1'd0}};
            else if(rd_en && (addra_z1 == addrb) && wr_en_z1)
                dout_z1 <= din_z1;
            else if(rd_en_z1)
                dout_z1 <= dout_z0;
            else
                dout_z1 <= dout_z1;
          end  
        assign dout = dout_z1;
      end
    else if(OUTPUT_DELAY == 3 && FIRST_WORD_FALL_THROUGH == 0)
      begin:OD3
        always@(posedge clk or posedge srst)
          begin
            if(srst)
              begin
                dout_z1 <= {WIDTH{1'd0}};
                dout_z2 <= {WIDTH{1'd0}};
              end  
//            else if(rd_en && (addra_z1 == addrb) && wr_en_z1)
//              begin
//                dout_z1 <= din_z1;
//                dout_z2 <= dout_z1;
//              end  
            else if(rd_en_z1)
              begin
                dout_z1 <= dout_z0;
                dout_z2 <= dout_z1;
              end  
            else
              begin
                dout_z1 <= dout_z1;
                dout_z2 <= dout_z1;
              end
          end  
        assign dout = dout_z2;
      end
    else if(OUTPUT_DELAY == 4 && FIRST_WORD_FALL_THROUGH == 0)
      begin:OD4
        always@(posedge clk or posedge srst)
          begin
            if(srst)
              begin
                dout_z1 <= {WIDTH{1'd0}};
                dout_z2 <= {WIDTH{1'd0}};
                dout_z3 <= {WIDTH{1'd0}};
              end  
//            else if(rd_en && (addra_z1 == addrb) && wr_en_z1)
//              begin
//                dout_z1 <= din_z1;
//                dout_z2 <= dout_z1;
//                dout_z3 <= dout_z2;
//              end  
            else if(rd_en_z1)
              begin
                dout_z1 <= dout_z0;
                dout_z2 <= dout_z1;
                dout_z3 <= dout_z2;
              end  
            else
              begin
                dout_z1 <= dout_z1;
                dout_z2 <= dout_z1;
                dout_z3 <= dout_z2;
              end  
          end
        assign dout = dout_z3;
      end
    else if(OUTPUT_DELAY == 0 && FIRST_WORD_FALL_THROUGH == 1 && DWorSMIC == "DW")
      begin:DWOD0FT1
        assign dout = dout_z0;
      end
    else if(OUTPUT_DELAY == 1 && FIRST_WORD_FALL_THROUGH == 1 && DWorSMIC == "DW")
      begin:DWOD1FT1
        always@(posedge clk or posedge srst)
          begin
			if(srst)
				dout_z1 <= {WIDTH{1'd0}};
			else	
				dout_z1 <= dout_z0;
          end  
        assign dout = dout_z1;
      end
    else if(OUTPUT_DELAY == 2 && FIRST_WORD_FALL_THROUGH == 1 && DWorSMIC == "DW")
      begin:DWOD2FT1
        always@(posedge clk or posedge srst)
          begin
            if(srst)
              begin
                dout_z1 <= {WIDTH{1'd0}};
                dout_z2 <= {WIDTH{1'd0}};
              end  
            else
              begin
                dout_z1 <= dout_z0;
                dout_z2 <= dout_z1;
              end  
          end  
        assign dout = dout_z2;
      end
    else if(OUTPUT_DELAY == 3 && FIRST_WORD_FALL_THROUGH == 1 && DWorSMIC == "DW")
      begin:DWOD3FT1
        always@(posedge clk or posedge srst)
          begin
            if(srst)
              begin
                dout_z1 <= {WIDTH{1'd0}};
                dout_z2 <= {WIDTH{1'd0}};
                dout_z3 <= {WIDTH{1'd0}};
              end  
            else
              begin
                dout_z1 <= dout_z0;
                dout_z2 <= dout_z1;
                dout_z3 <= dout_z2;
              end  
          end
        assign dout = dout_z3;
      end
    else if(OUTPUT_DELAY == 4 && FIRST_WORD_FALL_THROUGH == 1 && DWorSMIC == "DW")
      begin:DWOD4FT1
        always@(posedge clk or posedge srst)
          begin
            if(srst)
              begin
                dout_z1 <= {WIDTH{1'd0}};
                dout_z2 <= {WIDTH{1'd0}};
                dout_z3 <= {WIDTH{1'd0}};
                dout_z4 <= {WIDTH{1'd0}};
              end  
            else
              begin
                dout_z1 <= dout_z0;
                dout_z2 <= dout_z1;
                dout_z3 <= dout_z2;
                dout_z4 <= dout_z3;
              end  
          end
        assign dout = dout_z4;
      end
    else if(OUTPUT_DELAY == 1 && FIRST_WORD_FALL_THROUGH == 1)
      begin:OD1FT1
        assign dout = dout_z0;
      end
    else if(OUTPUT_DELAY == 2 && FIRST_WORD_FALL_THROUGH == 1)
      begin:OD2FT1
        always@(posedge clk or posedge srst)
          begin
			if(srst)
				dout_z1 <= {WIDTH{1'd0}};
			else	
				dout_z1 <= dout_z0;
          end  
        assign dout = dout_z1;
      end
    else if(OUTPUT_DELAY == 3 && FIRST_WORD_FALL_THROUGH == 1)
      begin:OD3FT1
        always@(posedge clk or posedge srst)
          begin
            if(srst)
              begin
                dout_z1 <= {WIDTH{1'd0}};
                dout_z2 <= {WIDTH{1'd0}};
              end  
            else
              begin
                dout_z1 <= dout_z0;
                dout_z2 <= dout_z1;
              end  
          end  
        assign dout = dout_z2;
      end
    else if(OUTPUT_DELAY == 4 && FIRST_WORD_FALL_THROUGH == 1)
      begin:OD4FT1
        always@(posedge clk or posedge srst)
          begin
            if(srst)
              begin
                dout_z1 <= {WIDTH{1'd0}};
                dout_z2 <= {WIDTH{1'd0}};
                dout_z3 <= {WIDTH{1'd0}};
              end  
            else
              begin
                dout_z1 <= dout_z0;
                dout_z2 <= dout_z1;
                dout_z3 <= dout_z2;
              end  
          end
        assign dout = dout_z3;
      end
endgenerate 

endmodule
