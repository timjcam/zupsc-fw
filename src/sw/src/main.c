#include <stdlib.h>
#include <unistd.h>


#include <FreeRTOS.h>
#include <xil_io.h>

#include <lwip/init.h>
#include <lwip/sockets.h>
#include <lwip/sys.h>
#include <netif/xadapter.h>
#include <xparameters_ps.h>

#include "xqspipsu.h"
#include "xiicps.h"
#include "xsysmonpsu.h"

#include "local.h"
#include "control.h"
#include "pl_regs.h"


#include "xuartps.h"

#include "zupsc.h"

#define SYSMON_DEVICE_ID XPAR_XSYSMONPSU_0_DEVICE_ID


psc_key* the_server;

struct ScaleFactorType scalefactors[4];

XQspiPsu QspiInstance;
XIicPs IicPsInstance;	    // all i2c devices
XSysMonPsu SysMonInstance;  // Instance of the Sysmon Device

uint32_t git_hash;

float CONVVOLTSTODACBITS;
float CONVDACBITSTOVOLTS;


static void client_event(void *pvt, psc_event evt, psc_client *ckey)
{
    if(evt!=PSC_CONN)
        return;
    // send some "static" information once when a new client connects.
    struct {
        uint32_t git_hash;
        uint32_t serial;
    } msg = {
        .git_hash = htonl(git_hash),
        .serial = 0, // TODO: read from EEPROM
    };
    (void)pvt;

    psc_send_one(ckey, 0x100, sizeof(msg), &msg);
}

static void client_msg(void *pvt, psc_client *ckey, uint16_t msgid, uint32_t msglen, void *msg)
{
    (void)pvt;

	//xil_printf("In Client_Msg:  MsgID=%d   MsgLen=%d\r\n",msgid,msglen);


    //blink front panel LED
    Xil_Out32(XPAR_M_AXI_BASEADDR + IOC_ACCESS_REG, 1);
    Xil_Out32(XPAR_M_AXI_BASEADDR + IOC_ACCESS_REG, 0);

    switch(msgid) {
        case 0:
        	glob_settings(msg);
        	break;

        case 1:
        case 2:
        case 3:
        case 4:
         	chan_settings(msgid,msg,msglen);
            break;
        case 101:
        	write_ramptable(1,msg,msglen);
            break;
        case 102:
        case 103:
        case 104:
            break;
    }



}

static void on_startup(void *pvt, psc_key *key)
{
    (void)pvt;
    (void)key;
    lstats_setup();
    brdstats_setup();
    sadata_setup();
    snapshot_setup();
    console_setup();
}

static void realmain(void *arg)
{
    (void)arg;

    printf("Main thread running\n");

    {
        net_config conf = {};
        sdcard_handle(&conf);
        //InitSettingsfromQspi();
        net_setup(&conf);

    }

    discover_setup();
    //tftp_setup();

    const psc_config conf = {
        .port = 3000,
        .start = on_startup,
        .conn = client_event,
        .recv = client_msg,
    };
    
    psc_run(&the_server, &conf);
    while(1) {
        fprintf(stderr, "ERROR: PSC server loop returns!\n");
        sys_msleep(1000);
    }
}


void print_firmware_version()
{

    time_t epoch_time;
    struct tm *human_time;
    char timebuf[80];

    xil_printf("Module ID Number: %x\r\n", Xil_In32(XPAR_M_AXI_BASEADDR + ID));
    xil_printf("Module Version Number: %x\r\n", Xil_In32(XPAR_M_AXI_BASEADDR + VERSION));
    xil_printf("Project ID Number: %x\r\n", Xil_In32(XPAR_M_AXI_BASEADDR + PRJ_ID));
    xil_printf("Project Version Number: %x\r\n", Xil_In32(XPAR_M_AXI_BASEADDR + PRJ_VERSION));
    //compare to git commit with command: git rev-parse --short HEAD
    xil_printf("Git Checksum: %x\r\n", Xil_In32(XPAR_M_AXI_BASEADDR + PRJ_SHASUM));
    epoch_time = Xil_In32(XPAR_M_AXI_BASEADDR + PRJ_TIMESTAMP);
    human_time = localtime(&epoch_time);
    strftime(timebuf, sizeof(timebuf), "%Y-%m-%d %H:%M:%S", human_time);
    xil_printf("Project Compilation Timestamp: %s\r\n", timebuf);
}


s32 init_sysmon() {

	s32 Status;
    XSysMonPsu_Config *SysMonConfig;

	// Initialize the SYSMON driver
	SysMonConfig = XSysMonPsu_LookupConfig(SYSMON_DEVICE_ID);
	if (SysMonConfig == NULL) {
		return XST_FAILURE;
	}

	Status = XSysMonPsu_CfgInitialize(&SysMonInstance, SysMonConfig, SysMonConfig->BaseAddress);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	// Self-Test the System Monitor/ADC device
	Status = XSysMonPsu_SelfTest(&SysMonInstance);
	if (Status != XST_SUCCESS) {
		xil_printf("SysMonPsu self-test failed.\n");
		return XST_FAILURE;
	}

    return XST_SUCCESS;
}






int main(void) {

	u32 i, base;
	u32 ts_s, ts_ns;



    xil_printf("Power Supply Controller...\r\n");
    print_firmware_version();





	//Xil_DCacheDisable();
	//Xil_ICacheDisable();

    //Set 10KHz trigger frequency
    //Step Size = 2^n * fout / fclk
    //          = 2^32 * 9.961722 KHz / 100MHz
    //          = 427852.7
	//10 KHz
	//Xil_Out32(XPAR_M_AXI_BASEADDR + NCO_STEPSIZE_REG, 427853);
	//100 KHz
	Xil_Out32(XPAR_M_AXI_BASEADDR + NCO_STEPSIZE_REG, 8589935); // changed from 4294967 should be 200kHz now



    //Set DAC DDS Frequency trigger frequency
    //Step Size = 2^n * fout / fclk
    //          = 2^32 * 1 KHz / 100MHz
    //          = 42950
	Xil_Out32(XPAR_M_AXI_BASEADDR + DAC_DDS_FREQ_REG + 1*CHBASEADDR, 42950);


	xil_printf("Init I2c...\r\n");
	init_i2c();
	usleep(100);
	xil_printf("Init Sysmon...\r\n");
	init_sysmon();


    // oscillator for EVR reference clock
	xil_printf("Init lmk61e2...\r\n");
	i2c_set_port_expander(I2C_PORTEXP0_ADDR,0x0);
	i2c_set_port_expander(I2C_PORTEXP1_ADDR,0x40);
	xil_printf("Hello\r\n");
    write_lmk61e2();


	// Qspi data is now in EEPROM
	xil_printf("Reading AT24CM02\r\n");
	i2c_set_port_expander(I2C_PORTEXP0_ADDR,0x80);
	i2c_set_port_expander(I2C_PORTEXP1_ADDR,0);
	xil_printf("Initialize Settings from EEPROM...\r\n");
	InitSettingsfromEeprom();

	//usleep(100);

	i2c_set_port_expander(I2C_PORTEXP1_ADDR,4);
	i2c_configure_ltc2991();
	i2c_get_ltc2991();


	ReadHardwareFlavor();

    //Temp - Reenable writes from AXI Master when reading out.
    Xil_Out32(XPAR_M_AXI_BASEADDR + DIGOUT_SPARE_REG + 1*CHBASEADDR, 1);


	//EVR reset
    xil_printf("Resetting EVR GTX...\r\n");
	Xil_Out32(XPAR_M_AXI_BASEADDR + EVR_RESET_REG, 0xFF);
	usleep(100);
	Xil_Out32(XPAR_M_AXI_BASEADDR + EVR_RESET_REG, 0);

	// Set FOFB IP Address
    //xil_printf("Setting FOFB IP Address to 10.0.142.100...\r\n");
	//Xil_Out32(XPAR_M_AXI_BASEADDR + FOFB_IPADDR_REG, 0x0A008E64);

	//Set Fault Enable Register - Move to gateware
	//for (i=1;i<5;i++) {
	//       base = XPAR_M_AXI_BASEADDR + i * CHBASEADDR;
	//       Xil_Out32(base + FAULT_MASK_REG,0x1FEF);
	//}

	//read Timestamp
	  for (i=0;i<5;i++) {
	     ts_s = Xil_In32(XPAR_M_AXI_BASEADDR + EVR_TS_S_REG);
	     ts_ns = Xil_In32(XPAR_M_AXI_BASEADDR + EVR_TS_NS_REG);
	     xil_printf("ts= %d    %d\r\n",ts_s,ts_ns);
	     sleep(1);
	  }

    sys_thread_new("main", realmain, NULL, THREAD_STACKSIZE, DEFAULT_THREAD_PRIO);

    // Run threads.  Does not return.
    vTaskStartScheduler();
    // never reached
    return 42;
}
