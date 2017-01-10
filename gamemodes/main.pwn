#include <a_samp>
#include <a_mysql>
#include <foreach>

#define DL_LOGIN                          100
#define DL_REGIST                         101
#define DL_INFO                           102
#define DL_MENU                           103
#define DL_MISSON_CLAN                    104
#define DL_MISSON_ITEM                    105
#define DL_MISSON_CAR                     106

#define DL_CLAN_INSERT                    1040
#define DL_CLAN_INSERT_COLOR              10400
#define DL_CLAN_INSERT_COLOR_RANDOM       10401
#define DL_CLAN_INSERT_COLOR_CHOICE       10402

#define DL_CLAN_LIST                      1041
#define DL_CLAN_RANK                      1042
#define DL_CLAN_SETUP                     1043
#define DL_CLAN_DELETE                    1044

#define DL_CLAN_SETUP_INVITE              10430
#define DL_CLAN_SETUP_MEMBER              10431

#define DL_CLAN_SETUP_MEMBER_SETUP        104310
#define DL_CLAN_SETUP_MEMBER_SETUP_RANK   104311
#define DL_CLAN_SETUP_MEMBER_SETUP_KICK   104312

#define COL_SYS  0xAFAFAF99
#define DIALOG_TITLE "{8D8DFF}�������ڸ���"
#define DIALOG_ENTER "Ȯ��"
#define DIALOG_PREV "�ڷ�"

/* IS CHECK */
#define IS_CLEN_HAVE   500
#define IS_CLEN_NOT    501
#define IS_CLEN_LEADER 502

/*ZONE BASE */
#define USED_ZONE 932
#define USED_VEHICLE 500
#define USED_HOUSE 500
#define USED_CLAN 100

#define PRESSED(%0) \
	(((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))

new FALSE = false;
#define formatMsg(%0,%1,%2)\
    do{\
	    new _str[256];\
        format(_str,256,%2);\
        SendClientMessage(%0,%1,_str);\
	}\
	while(FALSE)

main(){}

forward check(playerid);
forward regist(playerid, pass[]);
forward save(playerid);
forward load(playerid);
forward ServerThread();

/* variable */
new infoMessege[3][502] = {
	"{8D8DFF}��弳��{FFFFFF}\n\n������ �ڸ��� ����Դϴ�.\n������ �������� ������ ������ ����Դϴ�.\n\n{8D8DFF}���ӹ��{FFFFFF}\n\n�������ڸ��� ���� ������ �����ϴ�.",
	"{8D8DFF}�����ʶ�{FFFFFF}\n\n�̸�\t\t%s\nŬ��\t\t%s\n����\t\t%d\n����ġ\t\t%d\n�Ӵ�\t\t%d\n���\t\t%d\n����\t\t%d",
	"{FFFFFF}github.com/u4bi\n���̿�"
};

new Float:SPAWN_MODEL[54][3] = {
{966.1048,-989.9128,37.2340},
{962.3964,-1116.9700,23.2486},
{950.3869,-1300.3815,13.6064},
{920.7906,-1455.4015,12.9489},
{924.9973,-1625.6708,13.1147},
{927.0760,-1721.5812,13.1130},
{971.6392,-1783.2766,13.6663},
{1055.4865,-1827.3129,13.1389},
{1156.0485,-1842.3470,13.1321},
{1290.2769,-1654.4058,13.1165},
{1339.3270,-1405.3234,12.8955},
{1342.7333,-1144.6208,23.0736},
{1455.6702,-931.4559,36.4865},
{1731.4502,-996.1880,37.0469},
{2003.4839,-997.8493,30.4699},
{2167.6299,-1008.4839,62.3470},
{2318.4614,-1081.1084,48.7639},
{2478.3054,-1041.4218,65.4280},
{2559.4429,-1046.9205,68.9830},
{2639.7302,-1105.1461,68.2334},
{2643.7573,-1265.6605,49.4164},
{2646.8152,-1648.6918,10.2685},
{2762.2893,-1899.5236,10.6282},
{2781.6448,-1955.9955,13.1126},
{2866.5471,-2002.4600,10.6712},
{2541.8572,-2048.5984,24.6788},
{2264.0598,-2059.6448,12.9434},
{2217.0745,-1908.1469,12.9306},
{2197.6003,-1720.4226,12.9003},
{2214.3330,-1496.7076,23.3969},
{2224.3547,-1338.9926,23.5501},
{2346.3220,-1300.1836,23.5530},
{2050.4668,-1510.7344,2.9247},
{1738.6357,-1519.4613,16.4589},
{1622.8074,-1879.1394,24.7065},
{1878.2582,-2101.2280,13.1126},
{1962.1466,-2162.7034,12.9478},
{2529.6860,-2359.3992,13.1846},
{2709.0210,-2403.9048,13.0419},
{2759.2827,-2450.5840,13.0941},
{2450.6238,-2658.6941,13.1995},
{2220.2039,-2527.2659,12.9367},
{2431.5249,-1571.0193,23.3151},
{1928.6094,-1339.6660,16.7498},
{1645.4243,-1296.1215,15.0287},
{1499.8965,-1302.9801,13.5986},
{1433.9067,-1548.1550,12.9369},
{1478.5696,-1722.9683,13.1144},
{2039.7603,-1707.0786,13.1175},
{2292.6577,-1485.3090,22.5775},
{2242.8240,-1142.7300,25.3468},
{2032.0940,-1063.1873,24.3020},
{1685.1388,-1062.4604,23.4700},
{1188.4440,-1331.1532,13.5488}
};

enum ZONE_MODEL{
	ID,
	OWNER_CLAN,
	Float:MIN_X,
	Float:MIN_Y,
	Float:MAX_X,
	Float:MAX_Y
}
new ZONE[USED_ZONE][ZONE_MODEL];

enum USER_MODEL{
 	ID,
	NAME[MAX_PLAYER_NAME],
	PASS[24],
	USERIP[16],
	CLANID,
	ADMIN,
	MONEY,
	LEVEL,
	EXP,
	KILLS,
	DEATHS,
	SKIN,
	WEP1, AMMO1,
	WEP2, AMMO2,
	WEP3, AMMO3,
	INTERIOR,
	WORLD,
	Float:POS_X,
	Float:POS_Y,
	Float:POS_Z,
	Float:ANGLE,
 	Float:HP,
 	Float:AM
}
new USER[MAX_PLAYERS][USER_MODEL];

enum VEHICLE_MODEL{
 	ID,
	NAME[MAX_PLAYER_NAME],
	MODEL,
 	COLOR1,
 	COLOR2,
	Float:POS_X,
	Float:POS_Y,
	Float:POS_Z,
	Float:ANGLE
}
new VEHICLE[USED_VEHICLE][VEHICLE_MODEL];

enum HOUSE_MODEL{
 	ID,
 	NAME[MAX_PLAYER_NAME],
 	OPEN,
	Float:ENTER_POS_X,
	Float:ENTER_POS_Y,
	Float:ENTER_POS_Z,
	Float:LEAVE_POS_X,
	Float:LEAVE_POS_Y,
	Float:LEAVE_POS_Z
}
new HOUSE[USED_HOUSE][HOUSE_MODEL];

enum CLAN_MODEL{
 	ID,
 	NAME[50],
 	LEADER_NAME[MAX_PLAYER_NAME],
 	KILLS,
 	DEATHS,
    COLOR
}
new CLAN[USED_CLAN][CLAN_MODEL];

enum INGAME_MODEL{
	bool:LOGIN,
	Float:SPAWN_POS_X,
	Float:SPAWN_POS_Y,
	Float:SPAWN_POS_Z,
	Float:SPAWN_ANGLE,
	ENTER_ZONE
}
new INGAME[MAX_PLAYERS][INGAME_MODEL];

enum MISSON_MODEL{
	NAME[24],
	Float:POS_Y,
	Float:POS_X,
	Float:POS_Z
}
new MISSON[3][MISSON_MODEL];

enum CLAN_SETUP_MODEL{
	NAME[50],
	MEMBER
}
new CLAN_SETUP[MAX_PLAYERS][CLAN_SETUP_MODEL];

/* global variable */
new missonTick=0;

/* static */
static mysql;

public OnGameModeExit(){return 1;}
public OnGameModeInit(){
	dbcon();
	data();
    mode();
	server();
	thread();
    return 1;
}
public OnPlayerRequestClass(playerid, classid){

    if(INGAME[playerid][LOGIN]) return SendClientMessage(playerid,COL_SYS,"    �̹� �α��� �ϼ̽��ϴ�.");

    join(playerid, check(playerid));
    showZone(playerid);
	SetPlayerColor(playerid, 0x00000099);
    return 1;
}
public OnPlayerKeyStateChange(playerid, newkeys, oldkeys){
	if (PRESSED(KEY_YES)){
	    searchMissonRange(playerid);
	}
    return 1;
}
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]){

	if(!response){
		switch(dialogid){
			case DL_LOGIN, DL_REGIST:return Kick(playerid);
			case DL_MISSON_CLAN, DL_MISSON_ITEM, DL_MISSON_CAR :return 0;
			case DL_CLAN_INSERT, DL_CLAN_LIST, DL_CLAN_RANK, DL_CLAN_SETUP, DL_CLAN_DELETE :return showMisson(playerid, 0);
			case DL_CLAN_INSERT_COLOR : return showDialog(playerid, DL_CLAN_INSERT);
			case DL_CLAN_INSERT_COLOR_RANDOM, DL_CLAN_INSERT_COLOR_CHOICE :return showDialog(playerid, DL_CLAN_INSERT_COLOR);
			case DL_CLAN_SETUP_INVITE, DL_CLAN_SETUP_MEMBER : return showDialog(playerid, DL_CLAN_SETUP);
			case DL_CLAN_SETUP_MEMBER_SETUP : return showDialog(playerid, DL_CLAN_SETUP_MEMBER);
			case DL_CLAN_SETUP_MEMBER_SETUP_RANK, DL_CLAN_SETUP_MEMBER_SETUP_KICK : return showDialog(playerid, DL_CLAN_SETUP_MEMBER_SETUP);
		}
	}
	
    switch(dialogid){
		/* CORE */
		case DL_LOGIN  : checked(playerid, inputtext);
        case DL_REGIST : regist(playerid, inputtext);
        case DL_INFO   : info(playerid,listitem);

        /* MISSON */
        case DL_MISSON_CLAN : clan(playerid,listitem);
        case DL_MISSON_ITEM : item(playerid,listitem);
        case DL_MISSON_CAR  : car(playerid,listitem);

        /* CLAN */
        case DL_CLAN_INSERT : clanInsert(playerid, inputtext);
        case DL_CLAN_LIST   : clanList(playerid);
        case DL_CLAN_RANK   : clanRank(playerid);
        case DL_CLAN_SETUP  : clanSetup(playerid, listitem);
        case DL_CLAN_DELETE : clanDelete(playerid);
        
        /* CLAN INSERT */
        case DL_CLAN_INSERT_COLOR : clanInsertColor(playerid, listitem);
        case DL_CLAN_INSERT_COLOR_RANDOM : clanInsertColorRandom(playerid);
        case DL_CLAN_INSERT_COLOR_CHOICE : clanInsertColorChoice(playerid, inputtext);
        
        /* CLAN SETUP */
        case DL_CLAN_SETUP_INVITE : clanInvite(playerid, inputtext);
        case DL_CLAN_SETUP_MEMBER : clanMember(playerid, listitem);
        
        /* CLAN MEMBER SETUP */
        case DL_CLAN_SETUP_MEMBER_SETUP : clanMemberSetup(playerid,listitem);
		case DL_CLAN_SETUP_MEMBER_SETUP_RANK : clanMemberRank(playerid,listitem);
		case DL_CLAN_SETUP_MEMBER_SETUP_KICK : clanMemberKick(playerid);
        
    }
    return 1;
}
/* OnDialogResponse stock
   @ info()
   @ clan(playerid,listitem)
   @ item(playerid,listitem)
   @ car(playerid,listitem)
*/
stock info(playerid, listitem){
	new result[502];
	if(listitem ==1) format(result,sizeof(result), infoMessege[listitem],USER[playerid][NAME],CLAN[USER[playerid][CLANID]-1][NAME],USER[playerid][LEVEL],USER[playerid][EXP],USER[playerid][MONEY],USER[playerid][KILLS],USER[playerid][DEATHS]);
	else format(result,sizeof(result), infoMessege[listitem]);
	ShowPlayerDialog(playerid, DL_MENU, DIALOG_STYLE_MSGBOX, DIALOG_TITLE,result, "�ݱ�", "");
}

stock clan(playerid,listitem){
    formatMsg(playerid, COL_SYS, "Ŭ�� ���� %d - %d",playerid, listitem);
    
	switch(listitem){
        case 0 : showDialog(playerid, DL_CLAN_INSERT);
        case 1 : showDialog(playerid, DL_CLAN_LIST);
        case 2 : showDialog(playerid, DL_CLAN_RANK);
        case 3 : showDialog(playerid, DL_CLAN_SETUP);
        case 4 : showDialog(playerid, DL_CLAN_DELETE);
	}
}
stock item(playerid,listitem){
    formatMsg(playerid, COL_SYS, "������ ���� %d - %d",playerid, listitem);
}
stock car(playerid,listitem){
    formatMsg(playerid, COL_SYS, "���� �Ǹ��� %d - %d",playerid, listitem);
}

/* CLAN
   @ clanInsert(playerid, inputtext)
   @ clanList(playerid);
   @ clanRank(playerid);
   @ clanSetup(playerid, listitem);
   @ clanDelete(playerid);
*/
stock clanInsert(playerid, inputtext[]){
    formatMsg(playerid, COL_SYS, "Ŭ�� ���� %d - %s",playerid, inputtext);
    showDialog(playerid, DL_CLAN_INSERT_COLOR);
    return 0;
}
stock clanList(playerid){
    formatMsg(playerid, COL_SYS, "Ŭ�� ����Ʈ %d - %d",playerid);
}
stock clanRank(playerid){
    formatMsg(playerid, COL_SYS, "Ŭ�� ��ŷ %d - %d",playerid);
}
stock clanSetup(playerid, listitem){
	formatMsg(playerid, COL_SYS, "Ŭ�� ���� %d - %d",playerid, listitem);
	
	switch(listitem){
        case 0 : showDialog(playerid, DL_CLAN_SETUP_INVITE);
        case 1 : showDialog(playerid, DL_CLAN_SETUP_MEMBER);
	}
	return 0;
}
stock clanDelete(playerid){
	formatMsg(playerid, COL_SYS, "Ŭ�� ��ü %d",playerid);
	return 0;
}

/* CLAN INSERT
   @ clanInsertColor(playerid, listitem)
   @ clanInsertColorRandom(playerid)
   @ clanInsertColorChoice(playerid, inputtext)
*/
stock clanInsertColor(playerid, listitem){
	formatMsg(playerid, COL_SYS, "Ŭ�� ���� �÷� %d - %d",playerid, listitem);
	switch(listitem){
		case 0 : showDialog(playerid, DL_CLAN_INSERT_COLOR_RANDOM);
		case 1 : showDialog(playerid, DL_CLAN_INSERT_COLOR_CHOICE);
	}
}

stock clanInsertColorRandom(playerid){
    formatMsg(playerid, COL_SYS, "Ŭ�� ���� �÷� ���� %d",playerid);
}
stock clanInsertColorChoice(playerid, inputtext[]){
    formatMsg(playerid, COL_SYS, "Ŭ�� ���� �÷� ���� %d - %s",playerid, inputtext);
}


/* CLAN SETUP
   @ clanInvite(playerid, inputtext)
   @ clanMember(playerid, listitem)
*/
stock clanInvite(playerid, inputtext[]){
	formatMsg(playerid, COL_SYS, "Ŭ�� �ʴ� %d - %s",playerid, inputtext);
}
stock clanMember(playerid, listitem){
	formatMsg(playerid, COL_SYS, "Ŭ���� ���� %d - %d",playerid, listitem);
	showDialog(playerid, DL_CLAN_SETUP_MEMBER_SETUP);
}

/* CLAN MEMBER SETUP
   @ clanMemberSetup(playerid, listitem);
   @ clanMemberRank(playerid, listitem);
   @ clanMemberKick(playerid);
*/
stock clanMemberSetup(playerid, listitem){
	formatMsg(playerid, COL_SYS, "Ŭ���� �������� %d - %d",playerid, listitem);
	
	switch(listitem){
        case 0 : showDialog(playerid, DL_CLAN_SETUP_MEMBER_SETUP_RANK);
        case 1 : showDialog(playerid, DL_CLAN_SETUP_MEMBER_SETUP_KICK);
	}
}

stock clanMemberRank(playerid, listitem){
	formatMsg(playerid, COL_SYS, "Ŭ���� �������� %d - %d",playerid, listitem);
}
stock clanMemberKick(playerid){
	formatMsg(playerid, COL_SYS, "Ŭ���� �����߹� %d",playerid);
}

public OnPlayerCommandText(playerid, cmdtext[]){
    if(!strcmp("/sav", cmdtext)){

        if(!INGAME[playerid][LOGIN]) return SendClientMessage(playerid,COL_SYS,"    �α����Ŀ� ��� �����մϴ�.");

        save(playerid);
        SendClientMessage(playerid,COL_SYS,"    ����Ǿ����ϴ�.");
        return 1;
    }
   	if(!strcmp("/help", cmdtext)){
		showDialog(playerid, DL_INFO);
        return 1;
 	}
    if(!strcmp("/check", cmdtext)){
 	    checkZone(playerid);
 	    return 1;
 	}
    if(!strcmp("/hold", cmdtext)){
 	    holdZone(playerid);
 	    return 1;
 	}
 	
    return 0;
}
public OnPlayerDisconnect(playerid, reason){

    if(INGAME[playerid][LOGIN]) save(playerid);

    cleaning(playerid);
    return 1;
}

public OnPlayerDeath(playerid, killerid, reason){
	death(playerid, killerid, reason);
	return 1;
}

/* REG/LOG CHECK MANAGER
   @checked(playerid, password[])
   @join(playerid, type)
*/
stock checked(playerid, password[]){

    if(strlen(password) == 0) return join(playerid, 1), SendClientMessage(playerid,COL_SYS,"    ��й�ȣ�� �Է����ּ���.");
    if(strcmp(password, USER[playerid][PASS])) return join(playerid, 1), SendClientMessage(playerid,COL_SYS,"    ��й�ȣ�� Ʋ���ϴ�.");

    SendClientMessage(playerid,COL_SYS,"    �α��� �Ͽ����ϴ�.");
    INGAME[playerid][LOGIN] = true;
    load(playerid);
    return 1;
}
stock join(playerid, type){
    switch(playerid, type){
        case 0 : showDialog(playerid, DL_REGIST);
        case 1 : showDialog(playerid, DL_LOGIN);
    }
    return 1;
}

/* SQL @ check(playerid)
       @ regist(playerid, pass)
       @ save(playerid)
	   @ load(playerid)
	   @ escape(str[])
*/
public check(playerid){
    new query[128], result;
    GetPlayerName(playerid, USER[playerid][NAME], MAX_PLAYER_NAME);

    mysql_format(mysql, query, sizeof(query), "SELECT ID, PASS FROM `user_info` WHERE `NAME` = '%s' LIMIT 1", escape(USER[playerid][NAME]));
    mysql_query(mysql, query);

    result = cache_num_rows();
    if(result){
        USER[playerid][ID]      = cache_get_field_content_int(0, "ID");
        cache_get_field_content(0, "PASS", USER[playerid][PASS], mysql, 24);
    }
    return result;
}
public regist(playerid, pass[]){
    GetPlayerIp(playerid, USER[playerid][USERIP], 16);
	format(USER[playerid][PASS],24, "%s",pass);
	new query[400];
	mysql_format(mysql, query, sizeof(query), "INSERT INTO `user_info` (`NAME`,`PASS`,`USERIP`,`ADMIN`,`CLANID`,`MONEY`,`LEVEL`,`EXP`,`KILLS`,`DEATHS`,`SKIN`,`WEP1`,`AMMO1`,`WEP2`,`AMMO2`,`WEP3`,`AMMO3`,`INTERIOR`,`WORLD`,`POS_X`,`POS_Y`,`POS_Z`,`ANGLE`,`HP`,`AM`) VALUES ('%s','%s','%s',%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%f,%f,%f,%f,%f,%f)",
	USER[playerid][NAME], USER[playerid][PASS], USER[playerid][USERIP],
	USER[playerid][ADMIN] = 0,
	USER[playerid][CLANID] = 0,
	USER[playerid][MONEY] = 1000,
	USER[playerid][LEVEL] = 1,
	USER[playerid][EXP] = 0,
	USER[playerid][KILLS] = 0,
	USER[playerid][DEATHS] = 0,
	USER[playerid][SKIN] = 170,
	USER[playerid][WEP1] = 24, USER[playerid][AMMO1] = 500,
	USER[playerid][WEP2] = 0, USER[playerid][AMMO2] = 0,
	USER[playerid][WEP3] = 0, USER[playerid][AMMO3] = 0,
	USER[playerid][INTERIOR] = 0,
    USER[playerid][WORLD] = 0,
	USER[playerid][POS_X] = 1913.1345,
 	USER[playerid][POS_Y] = -1710.5565,
	USER[playerid][POS_Z] = 13.4003,
	USER[playerid][ANGLE] = 89.3591,
	USER[playerid][HP] = 100.0,
	USER[playerid][AM] = 100.0);

	mysql_query(mysql, query);
	GetPlayerName(playerid, USER[playerid][NAME], MAX_PLAYER_NAME);
//ss
	USER[playerid][ID] = cache_insert_id();

	SendClientMessage(playerid,COL_SYS,"    ȸ�������� �Ͽ����ϴ�.");
	INGAME[playerid][LOGIN] = true;
	spawn(playerid);
}
public save(playerid){
	GetPlayerPos(playerid,USER[playerid][POS_X],USER[playerid][POS_Y],USER[playerid][POS_Z]);
	GetPlayerFacingAngle(playerid, USER[playerid][ANGLE]);

	new query[400];
	mysql_format(mysql, query, sizeof(query), "UPDATE `user_info` SET `ADMIN`=%d,`CLANID`=%d,`MONEY`=%d,`LEVEL`=%d,`EXP`=%d,`KILLS`=%d,`DEATHS`=%d,`SKIN`=%d,`WEP1`=%d,`AMMO1`=%d,`WEP2`=%d,`AMMO2`=%d,`WEP3`=%d,`AMMO3`=%d, `INTERIOR`=%d, `WORLD`=%d, `POS_X`=%f,`POS_Y`=%f,`POS_Z`=%f,`ANGLE`=%f,`HP`=%f,`AM`=%f WHERE `ID`=%d",
	USER[playerid][ADMIN],
	USER[playerid][CLANID],
	USER[playerid][MONEY],
	USER[playerid][LEVEL],
	USER[playerid][EXP],
	USER[playerid][KILLS],
	USER[playerid][DEATHS],
	USER[playerid][SKIN],
	USER[playerid][WEP1], USER[playerid][AMMO1],
	USER[playerid][WEP2], USER[playerid][AMMO2],
	USER[playerid][WEP3], USER[playerid][AMMO3],
	USER[playerid][INTERIOR],
    USER[playerid][WORLD],
	USER[playerid][POS_X],
	USER[playerid][POS_Y],
	USER[playerid][POS_Z],
	USER[playerid][ANGLE],
	USER[playerid][HP],
	USER[playerid][AM],
	USER[playerid][ID]);

	mysql_query(mysql, query);
}
public load(playerid){
	new query[400];
	mysql_format(mysql, query, sizeof(query), "SELECT * FROM `user_info` WHERE `ID` = %d LIMIT 1", USER[playerid][ID]);
	mysql_query(mysql, query);

	USER[playerid][USERIP]   = cache_get_field_content_int(0, "USERIP");
	USER[playerid][ADMIN]   = cache_get_field_content_int(0, "ADMIN");
	USER[playerid][CLANID]   = cache_get_field_content_int(0, "CLANID");
	USER[playerid][MONEY]   = cache_get_field_content_int(0, "MONEY");
	USER[playerid][LEVEL]   = cache_get_field_content_int(0, "LEVEL");
	USER[playerid][EXP]   = cache_get_field_content_int(0, "EXP");
	USER[playerid][KILLS]   = cache_get_field_content_int(0, "KILLS");
	USER[playerid][DEATHS]  = cache_get_field_content_int(0, "DEATHS");
	USER[playerid][SKIN]    = cache_get_field_content_int(0, "SKIN");
	USER[playerid][WEP1]    = cache_get_field_content_int(0, "WEP1");
	USER[playerid][AMMO1]    = cache_get_field_content_int(0, "AMMO1");
	USER[playerid][WEP2]    = cache_get_field_content_int(0, "WEP2");
	USER[playerid][AMMO2]    = cache_get_field_content_int(0, "AMMO2");
	USER[playerid][WEP3]    = cache_get_field_content_int(0, "WEP3");
	USER[playerid][AMMO3]    = cache_get_field_content_int(0, "AMMO3");
	USER[playerid][POS_X]   = cache_get_field_content_float(0, "POS_X");
	USER[playerid][POS_Y]   = cache_get_field_content_float(0, "POS_Y");
	USER[playerid][POS_Z]   = cache_get_field_content_float(0, "POS_Z");
	USER[playerid][ANGLE]   = cache_get_field_content_float(0, "ANGLE");
	USER[playerid][HP]      = cache_get_field_content_float(0, "HP");
	USER[playerid][AM]      = cache_get_field_content_float(0, "AM");
	spawn(playerid);
}
stock escape(str[]){
    new result[24];
    mysql_real_escape_string(str, result);
    return result;
}
/* INGAME FUNCTION
   @ spawn(playerid)
*/
stock spawn(playerid){
	SetSpawnInfo(playerid, USER[playerid][CLANID], USER[playerid][SKIN], USER[playerid][POS_X], USER[playerid][POS_Y], USER[playerid][POS_Z], USER[playerid][ANGLE], USER[playerid][WEP1], USER[playerid][AMMO1], USER[playerid][WEP2], USER[playerid][AMMO2], USER[playerid][WEP3], USER[playerid][AMMO3]);
	SpawnPlayer(playerid);
	ResetPlayerMoney(playerid);
	GivePlayerMoney(playerid, USER[playerid][MONEY]);
	SetPlayerHealth(playerid, USER[playerid][HP]);
	SetPlayerArmour(playerid, USER[playerid][AM]);
	
	if(USER[playerid][CLANID] == 0)SetPlayerColor(playerid, 0xE6E6E699);
    else SetPlayerColor(playerid, CLAN[USER[playerid][CLANID]-1][COLOR]);
}

/* INIT
   @ dbcon()
   @ data()
   @ mode()
   @ thread()
   @ server()
   @ cleaning(playerid)
*/
stock mode(){
	zoneSetup();
	loadMisson();
	#include "module/vehicles.pwn"
	textLabel_init();
	object_init();
}

stock thread(){ SetTimer("ServerThread", 500, true); }
stock server(){
	SetGameModeText("Blank Script");
	UsePlayerPedAnims();
	EnableStuntBonusForAll(0);
	DisableInteriorEnterExits();
	ShowPlayerMarkers(PLAYER_MARKERS_MODE_OFF);
	AddPlayerClass(0,0,0,0,0,0,0,0,0,0,0);
}
/* TODO : README.MD*/
stock dbcon(){
    new db_key[4][128] = {"hostname", "username", "database", "password"}, db_value[4][128];
    new File:cfg=fopen("database.cfg", io_read), temp[64], tick =0;

    while(fread(cfg, temp)){
        if(strcmp(temp, db_key[tick])){
            new pos = strfind(temp, "=");
            strdel(temp, 0, pos+1);
            new len = strlen(temp);
            if(tick != 3)strdel(temp, len-2, len);
            db_value[tick] = temp;
        }
        tick++;
    }

    mysql = mysql_connect(db_value[0], db_value[1], db_value[2], db_value[3]);
    mysql_set_charset("euckr");

    if(mysql_errno(mysql))print("DB�������");
}
stock data(){
	house_data();
	vehicle_data();
	zone_data();
	clan_data();
}
stock cleaning(playerid){
    new temp[USER_MODEL], temp2[INGAME_MODEL], temp3[CLAN_SETUP_MODEL];
    USER[playerid] = temp;
    INGAME[playerid] = temp2;
    CLAN_SETUP[playerid] = temp3;
}

/* DB DATA
   @ house_data()
   @ vehicle_data()
   @ clan_data()
   @ zone_data()
*/
stock house_data(){
	new query[400];
	mysql_format(mysql, query, sizeof(query), "SELECT * FROM `house_info`");
	mysql_query(mysql, query);
	if(!mysql_errno(mysql))print("�� DB ����");

	new rows, fields;
	cache_get_data(rows, fields);
	
    for(new i=0; i < rows; i++){
	    HOUSE[i][ID]            = cache_get_field_content_int(i, "ID");
	    HOUSE[i][OPEN]          = cache_get_field_content_int(i, "OPEM");
		cache_get_field_content(i, "NAME", HOUSE[i][NAME], mysql, 24);
        HOUSE[i][ENTER_POS_X]   = cache_get_field_content_float(i, "ENTER_POS_X");
        HOUSE[i][ENTER_POS_Y]   = cache_get_field_content_float(i, "ENTER_POS_Y");
        HOUSE[i][ENTER_POS_Z]   = cache_get_field_content_float(i, "ENTER_POS_Z");
        HOUSE[i][LEAVE_POS_X]   = cache_get_field_content_float(i, "LEAVE_POS_X");
        HOUSE[i][LEAVE_POS_Y]   = cache_get_field_content_float(i, "LEAVE_POS_Y");
        HOUSE[i][LEAVE_POS_Z]   = cache_get_field_content_float(i, "LEAVE_POS_Z");
    }
	

}
stock vehicle_data(){
	new query[400];
	mysql_format(mysql, query, sizeof(query), "SELECT * FROM `vehicle_info`");
	mysql_query(mysql, query);
	if(!mysql_errno(mysql))print("���� DB ����");
	new rows, fields;
	cache_get_data(rows, fields);
	
    for(new i=0; i < rows; i++){
	    VEHICLE[i][ID]           = cache_get_field_content_int(i, "ID");
		cache_get_field_content(i, "NAME", VEHICLE[i][NAME], mysql, 24);
	    VEHICLE[i][MODEL]        = cache_get_field_content_int(i, "MODEL");
	    VEHICLE[i][COLOR1]       = cache_get_field_content_int(i, "COLOR1");
	    VEHICLE[i][COLOR2]       = cache_get_field_content_int(i, "COLOR2");
    }
}
stock clan_data(){
	new query[400];
	mysql_format(mysql, query, sizeof(query), "SELECT * FROM `clan_info`");
	mysql_query(mysql, query);
	if(!mysql_errno(mysql))print("Ŭ�� DB ����");
	new rows, fields;
	cache_get_data(rows, fields);
	
    for(new i=0; i < rows; i++){
	    CLAN[i][ID]             = cache_get_field_content_int(i, "ID");
		cache_get_field_content(i, "NAME", CLAN[i][NAME], mysql, 50);
		cache_get_field_content(i, "LEADER_NAME", CLAN[i][LEADER_NAME], mysql, 24);
	    CLAN[i][KILLS]          = cache_get_field_content_int(i, "KILLS");
	    CLAN[i][DEATHS]         = cache_get_field_content_int(i, "DEATHS");
	    CLAN[i][COLOR]          = cache_get_field_content_int(i, "COLOR");
    }
}
stock zone_data(){
	new query[400];
	mysql_format(mysql, query, sizeof(query), "SELECT * FROM `zone_info`");
	mysql_query(mysql, query);
	if(!mysql_errno(mysql))print("���� DB ����");
	new rows, fields;
	cache_get_data(rows, fields);
	
    for(new i=0; i < rows; i++){
        ZONE[i][ID]             = cache_get_field_content_int(i, "ID");
        ZONE[i][OWNER_CLAN]             = cache_get_field_content_int(i, "OWNER_CLAN");
    }
}

/* SERVER THREAD*/
public ServerThread(){
    foreach (new i : Player){
	    eventMoney(i);
	    checkZone(i);
    }
}

/* stock
   @ zoneSetup()
   @ showZone(playerid)
   @ fixPos(playerid)
   @ eventMoney(playerid)
   @ giveMoney(playerid,money)
   @ death(playerid, killerid, reason)
   @ loadMisson()
   @ missonInit(name[24],Float:pos_x,Float:pos_y,Float:pos_z)
   @ object_init()
   @ textLabel_init()
   @ searchMissonRange(playerid)
   @ showMisson(playerid, type)
   @ showDialog(playerid, type)
   @ isPlayerZone(playerid, zoneid)
   @ checkZone(playerid)
   @ holdZone(playerid)
*/

stock zoneSetup(){
	new pos[4] = { -3000, 2800, -2800, 3000 };
	new fix = 200, tick = 0;

	for(new i = 0; i < USED_ZONE; i++){
		tick++;
		if(tick == 31){
			tick = 1;
			pos[0] = -3000;
			pos[1] = pos[1] - fix;
			pos[2] = -2800;
			pos[3] = pos[3] - fix;
		}
		ZONE[i][ID] = GangZoneCreate(pos[0], pos[1], pos[2], pos[3]);
		ZONE[i][MIN_X] = pos[0];
		ZONE[i][MIN_Y] = pos[1];
		ZONE[i][MAX_X] = pos[2];
		ZONE[i][MAX_Y] = pos[3];
		pos[0] = fix + pos[0];
		pos[2] = fix + pos[2];
	}
}

stock showZone(playerid){
	new zoneCol[2] = { 0xFFFFFF99, 0xAFAFAF99};
	new flag = 0, flag2 = 0, tick = 0;

	for(new i = 0; i < USED_ZONE; i++){
		tick++;
		if(tick == 31){
			tick = 1;
			flag2 = !flag2;
		}
		flag = !flag;
		if(flag == 1){
			if(flag2 == 1)GangZoneShowForPlayer(playerid, ZONE[i][ID], zoneCol[0]);
			else GangZoneShowForPlayer(playerid, ZONE[i][ID], zoneCol[1]);
		}
		else if(!flag2)GangZoneShowForPlayer(playerid, ZONE[i][ID], zoneCol[0]);
		else GangZoneShowForPlayer(playerid, ZONE[i][ID], zoneCol[1]);
        if(ZONE[i][OWNER_CLAN] != 0){
            GangZoneShowForPlayer(playerid, ZONE[i][ID], CLAN[ZONE[i][OWNER_CLAN]-1][COLOR]);
		}
	}
	return 0;
}

stock isPlayerZone(playerid, zoneid){
    new	Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);

    if(x > ZONE[zoneid][MIN_X] && x < ZONE[zoneid][MAX_X] && y > ZONE[zoneid][MIN_Y] && y < ZONE[zoneid][MAX_Y])return 1;
    
    return 0;
}

stock checkZone(playerid){
	for(new z = 0; z < USED_ZONE; z++){
        if(isPlayerZone(playerid, z)){
			if(INGAME[playerid][ENTER_ZONE] == z)return 0;
			
            INGAME[playerid][ENTER_ZONE] = z;
            formatMsg(playerid, COL_SYS, "%d�� ��", INGAME[playerid][ENTER_ZONE]);
        }
	}
	return 0;
}

stock holdZone(playerid){
	new zoneid = INGAME[playerid][ENTER_ZONE];

    ZONE[zoneid][OWNER_CLAN] = USER[playerid][CLANID];
    
    formatMsg(playerid, COL_SYS, " Ŭ�����̵� : %d",USER[playerid][CLANID]);
	formatMsg(playerid, COL_SYS, " �÷� : %d",CLAN[USER[playerid][CLANID]-1][COLOR]);
    
    GangZoneShowForAll(ZONE[zoneid][ID], CLAN[USER[playerid][CLANID]-1][COLOR]);

	formatMsg(playerid, COL_SYS, "%d�� �� - %d�� Ŭ�� - ���� �̸� : %s",zoneid, ZONE[zoneid][OWNER_CLAN], USER[playerid][NAME]);
	return 0;
}

stock fixPos(playerid){
    new ran = random(sizeof(SPAWN_MODEL));
	INGAME[playerid][SPAWN_POS_X] = SPAWN_MODEL[ran][0];
	INGAME[playerid][SPAWN_POS_Y] = SPAWN_MODEL[ran][1];
	INGAME[playerid][SPAWN_POS_Z] = SPAWN_MODEL[ran][2];
	INGAME[playerid][SPAWN_ANGLE] = 89.3591;
}

stock eventMoney(playerid){ giveMoney(playerid, 1);
}
stock giveMoney(playerid,money){
    ResetPlayerMoney(playerid);
    GivePlayerMoney(playerid, USER[playerid][MONEY]+=money);
}

stock death(playerid, killerid, reason){
	fixPos(playerid);
	USER[playerid][POS_X]   = INGAME[playerid][SPAWN_POS_X];
 	USER[playerid][POS_Y]   = INGAME[playerid][SPAWN_POS_Y];
	USER[playerid][POS_Z]   = INGAME[playerid][SPAWN_POS_Y];
	USER[playerid][ANGLE]   = INGAME[playerid][SPAWN_ANGLE];
	USER[playerid][DEATHS] -= 1;
	USER[playerid][HP]      = 100.0;
	USER[playerid][AM]      = 100.0;

    save(playerid);
	spawn(playerid);
	if(reason == 255) return 1;
	USER[killerid][KILLS] += 1;
    save(killerid);
	return 1;
}

stock loadMisson(){
	missonInit("Ŭ�� ����",1910.2273,-1714.3197,13.3307);
	missonInit("���� ����",1909.9907,-1707.3611,13.3251);
	missonInit("���� �Ǹ���",1909.9747,-1700.0070,13.3236);
}
stock missonInit(name[24],Float:pos_x,Float:pos_y,Float:pos_z){
	new num = missonTick++;
	format(MISSON[num][NAME], 24,"%s",name);
	MISSON[num][POS_X]=pos_x;
	MISSON[num][POS_Y]=pos_y;
	MISSON[num][POS_Z]=pos_z;
}

stock object_init(){
	CreateObject(1504, 1909.60229, -1713.55371, 12.30253,   0.00000, 0.00000, 269.91336);
	CreateObject(1505, 1909.58008, -1708.08728, 12.14866,   0.00000, 0.00000, 89.91272);
	CreateObject(1507, 1909.53870, -1699.33984, 12.30817,   0.00000, 0.00000, 269.92120);
}

stock textLabel_init(){
	for(new a = 0;a<3;a++){
		new str[40];
		format(str, sizeof(str),"%s (YŰ)",MISSON[a][NAME]);
		Create3DTextLabel(str, 0x8D8DFFFF, MISSON[a][POS_X], MISSON[a][POS_Y], MISSON[a][POS_Z], 7.0, 0, 0);
	}
}

stock searchMissonRange(playerid){
	new Float:x,Float:y,Float:z;

	for(new i=0; i < sizeof(MISSON); i++){
	    x=MISSON[i][POS_X];
	    y=MISSON[i][POS_Y];
	    z=MISSON[i][POS_Z];
		if(IsPlayerInRangeOfPoint(playerid,3.0,x,y,z)) showMisson(playerid, i);
	}
}
stock showMisson(playerid, type){
	switch(type){
		case 0: ShowPlayerDialog(playerid, DL_MISSON_CLAN, DIALOG_STYLE_LIST,DIALOG_TITLE,"{FFFFFF}Ŭ�� ����\nŬ�� ���\nŬ�� ��ŷ\nŬ�� ����\nŬ�� ��ü","Ȯ��", "�ݱ�");
		case 1: ShowPlayerDialog(playerid, DL_MISSON_ITEM, DIALOG_STYLE_LIST,DIALOG_TITLE,"{FFFFFF}���� ����\n���� �Ǹ�","Ȯ��", "�ݱ�");
		case 2: ShowPlayerDialog(playerid, DL_MISSON_CAR, DIALOG_STYLE_LIST,DIALOG_TITLE,"{FFFFFF}���� ����\n���� �Ǹ�","Ȯ��", "�ݱ�");
	}
	return 1;
}

stock showDialog(playerid, type){
    switch(type){
        case DL_LOGIN : ShowPlayerDialog(playerid, DL_LOGIN, DIALOG_STYLE_PASSWORD, DIALOG_TITLE, "{FFFFFF}�α����� ���ּ���", DIALOG_ENTER, "������");
        case DL_REGIST : ShowPlayerDialog(playerid, DL_REGIST, DIALOG_STYLE_PASSWORD, DIALOG_TITLE, "{FFFFFF}ȸ�������� ���ּ���.", DIALOG_ENTER, "������");

        case DL_INFO : ShowPlayerDialog(playerid, DL_INFO, DIALOG_STYLE_LIST, DIALOG_TITLE, "���� ����\n�� ������\n����\n", DIALOG_ENTER, DIALOG_PREV);
        case DL_CLAN_LIST : ShowPlayerDialog(playerid, DL_CLAN_LIST, DIALOG_STYLE_MSGBOX, DIALOG_TITLE, "{FFFFFF}Ŭ�� ���", DIALOG_ENTER, DIALOG_PREV);
        case DL_CLAN_RANK : ShowPlayerDialog(playerid, DL_CLAN_RANK, DIALOG_STYLE_MSGBOX, DIALOG_TITLE, "{FFFFFF}Ŭ�� ��ŷ", DIALOG_ENTER, DIALOG_PREV);
        case DL_CLAN_SETUP :{
            if(isClan(playerid, IS_CLEN_NOT)) return 0;
            if(isClan(playerid, IS_CLEN_LEADER)) return 0;
            
		    ShowPlayerDialog(playerid, DL_CLAN_SETUP, DIALOG_STYLE_LIST, DIALOG_TITLE, "{FFFFFF}Ŭ���� �ʴ�\nŬ���� ����", DIALOG_ENTER, DIALOG_PREV);
		}
        case DL_CLAN_DELETE :{
            if(isClan(playerid, IS_CLEN_LEADER)) return 0;
		    ShowPlayerDialog(playerid, DL_CLAN_DELETE, DIALOG_STYLE_MSGBOX, DIALOG_TITLE, "{FFFFFF}������ Ŭ���� ��ü�Ͻðڽ��ϱ�?", DIALOG_ENTER, DIALOG_PREV);
		}
        case DL_CLAN_INSERT :{
            if(isClan(playerid, IS_CLEN_HAVE)) return 0;
            
		    ShowPlayerDialog(playerid, DL_CLAN_INSERT, DIALOG_STYLE_INPUT, DIALOG_TITLE, "{FFFFFF}Ŭ������ �Է����ּ���.", DIALOG_ENTER, DIALOG_PREV);
        }
        case DL_CLAN_INSERT_COLOR : ShowPlayerDialog(playerid, DL_CLAN_INSERT_COLOR, DIALOG_STYLE_LIST, DIALOG_TITLE, "{FFFFFF}����������\n������", DIALOG_ENTER, DIALOG_PREV);
        case DL_CLAN_INSERT_COLOR_RANDOM : ShowPlayerDialog(playerid, DL_CLAN_INSERT_COLOR_RANDOM, DIALOG_STYLE_MSGBOX, DIALOG_TITLE, "{FFFFFF}�������� ���� �̾ƺִϴ�.", DIALOG_ENTER, DIALOG_PREV);
        case DL_CLAN_INSERT_COLOR_CHOICE : ShowPlayerDialog(playerid, DL_CLAN_INSERT_COLOR_CHOICE, DIALOG_STYLE_INPUT, DIALOG_TITLE, "{FFFFFF}Ŭ�� ������ �������ּ���.", DIALOG_ENTER, DIALOG_PREV);

        case DL_CLAN_SETUP_INVITE : ShowPlayerDialog(playerid, DL_CLAN_SETUP_INVITE, DIALOG_STYLE_INPUT, DIALOG_TITLE, "{FFFFFF}�ʴ��ϽǺ��� �г����� �Է����ּ���.", DIALOG_ENTER, DIALOG_PREV);
        case DL_CLAN_SETUP_MEMBER : ShowPlayerDialog(playerid, DL_CLAN_SETUP_MEMBER, DIALOG_STYLE_LIST, DIALOG_TITLE, "{FFFFFF}Ŭ����1\nŬ����2", DIALOG_ENTER, DIALOG_PREV);
        case DL_CLAN_SETUP_MEMBER_SETUP : ShowPlayerDialog(playerid, DL_CLAN_SETUP_MEMBER_SETUP, DIALOG_STYLE_LIST, DIALOG_TITLE, "{FFFFFF}���� ����\n���� �߹�", DIALOG_ENTER, DIALOG_PREV);
        case DL_CLAN_SETUP_MEMBER_SETUP_RANK : ShowPlayerDialog(playerid, DL_CLAN_SETUP_MEMBER_SETUP_RANK, DIALOG_STYLE_LIST, DIALOG_TITLE, "{FFFFFF}1���\n2���\n3���", DIALOG_ENTER, DIALOG_PREV);
        case DL_CLAN_SETUP_MEMBER_SETUP_KICK : ShowPlayerDialog(playerid, DL_CLAN_SETUP_MEMBER_SETUP_KICK, DIALOG_STYLE_MSGBOX, DIALOG_TITLE, "{FFFFFF}������ �߹��Ͻðڽ��ϱ�?", DIALOG_ENTER, DIALOG_PREV);
    }
    return 1;
}

stock isClan(playerid, type){
	switch(type){
		case IS_CLEN_HAVE   : if(USER[playerid][CLANID] != 0) return SendClientMessage(playerid,COL_SYS,"    ����� �̹� Ŭ���� �ҼӵǾ� �ֽ��ϴ�.");
		case IS_CLEN_NOT    : if(USER[playerid][CLANID] == 0)return SendClientMessage(playerid,COL_SYS,"    ����� Ŭ���� �ҼӵǾ� ���� �ʽ��ϴ�.");
		case IS_CLEN_LEADER : if(USER[playerid][NAME] != CLAN[USER[playerid][CLANID]-1][LEADER_NAME])return SendClientMessage(playerid,COL_SYS,"    Ŭ�� ������ �ƴմϴ�.");
	}
    return 0;
}

