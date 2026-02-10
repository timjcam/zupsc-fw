/***************************** Include Files *********************************/
#include "xparameters.h"
#include "xqspipsu.h"
#include "xil_printf.h"
#include <string.h>
#include "local.h"
#include "pl_regs.h"
#include "qspi_flash.h"

/* Your globals */
extern XQspiPsu QspiInstance;
extern ScaleFactorType scalefactors[4];
extern float CONVDACBITSTOVOLTS;

/*
 * Notes:
 * - This is a simple, conservative SPI flash command flow using:
 *   - 0x03 READ
 *   - 0x02 PAGE PROGRAM
 *   - 0x06 WREN
 *   - 0x05 RDSR
 *   - 0xD8/0x20 sector erase depending on your defines
 *
 * - Your BSP uses message-based XQspiPsu_PolledTransfer().
 * - BusWidth/Flags macro names vary across Xilinx versions.
 *   The ones below are the common ones for XQspiPsu_Msg.
 *   If your build complains about any flag names, tell me which ones
 *   and I’ll map to your exact header names.
 */

static int QspiPsuTransfer_TxRx(const u8 *tx, u32 tx_len, u8 *rx, u32 rx_len, int hold_cs)
{
    XQspiPsu_Msg Msg[2];
    int n = 0;

    memset(Msg, 0, sizeof(Msg));

    if (tx && tx_len) {
        Msg[n].TxBfrPtr  = (u8 *)tx;
        Msg[n].RxBfrPtr  = NULL;
        Msg[n].ByteCount = tx_len;
        Msg[n].Flags     = XQSPIPSU_MSG_FLAG_TX | XQSPIPSU_MSG_FLAG_POLL;
        n++;
    }

    if (rx && rx_len) {
        Msg[n].TxBfrPtr  = NULL;
        Msg[n].RxBfrPtr  = rx;
        Msg[n].ByteCount = rx_len;
        Msg[n].Flags     = XQSPIPSU_MSG_FLAG_RX | XQSPIPSU_MSG_FLAG_POLL;
        n++;
    }

    return XQspiPsu_PolledTransfer(&QspiInstance, Msg, n);
}

static int QspiPsuWriteEnable(void)
{
    u8 cmd = FLASH_WRITE_ENABLE_CMD;
    return QspiPsuTransfer_TxRx(&cmd, 1, NULL, 0, 0);
}

static int QspiPsuReadStatus(u8 *sr)
{
    u8 cmd[2] = { FLASH_READ_STATUS_CMD, 0x00 };
    u8 rsp[2] = { 0 };

    /* Send 2 bytes, read 2 bytes back; status is in rsp[1] for this style */
    int st = QspiPsuTransfer_TxRx(cmd, sizeof(cmd), rsp, sizeof(rsp), 0);
    if (st != XST_SUCCESS) return st;

    *sr = rsp[1];
    return XST_SUCCESS;
}

static int QspiPsuWaitWhileBusy(void)
{
    u8 sr;
    while (1) {
        int st = QspiPsuReadStatus(&sr);
        if (st != XST_SUCCESS) return st;
        if ((sr & 0x01) == 0) break;  /* WIP bit cleared */
    }
    return XST_SUCCESS;
}

/***************************** Your existing logic ****************************/

void InitSettingsfromQspi(void)
{
    u32 chan;
    u8 readbuf[FLASH_PAGE_SIZE];

    /* global values - hardcode for now */
    Xil_Out32(XPAR_M_AXI_BASEADDR + EVR_INJ_EVENTNUM_REG, 10);
    Xil_Out32(XPAR_M_AXI_BASEADDR + EVR_PM_EVENTNUM_REG, 10);

    for (chan = 1; chan <= 4; chan++) {
        QspiFlashRead(chan * FLASH_SECTOR_SIZE, FLASH_PAGE_SIZE, readbuf);
        QspiDisperseData(chan, readbuf);
    }
}

/***************************** QSPI API (ZynqMP) ******************************/

int QspiFlashInit(void)
{
    XQspiPsu_Config *QspiConfig;
    int Status;

    QspiConfig = XQspiPsu_LookupConfig(XPAR_XQSPIPSU_0_DEVICE_ID);
    if (QspiConfig == NULL) {
        return XST_FAILURE;
    }

    Status = XQspiPsu_CfgInitialize(&QspiInstance, QspiConfig, QspiConfig->BaseAddress);
    if (Status != XST_SUCCESS) {
        return XST_FAILURE;
    }

    /* Conservative settings */
    XQspiPsu_SetOptions(&QspiInstance, XQSPIPSU_MANUAL_START_OPTION);
    XQspiPsu_SetClkPrescaler(&QspiInstance, XQSPIPSU_CLK_PRESCALE_8);

    /* Your BSP doesn't have CS0; it does have CS_BOTH */
    XQspiPsu_Select(&QspiInstance, XQSPIPSU_SELECT_FLASH_CS_BOTH);

    return XST_SUCCESS;
}

void QspiFlashRead(u32 Address, u32 ByteCount, u8 *ReadBuf)
{
    /* Command + 24-bit address (0x03 read) */
    u8 cmd[4];

    cmd[0] = FLASH_READ_CMD;
    cmd[1] = (u8)((Address >> 16) & 0xFF);
    cmd[2] = (u8)((Address >>  8) & 0xFF);
    cmd[3] = (u8)((Address >>  0) & 0xFF);

    /*
     * Keep CS asserted between command+addr and read phase.
     * No "first 4 bytes garbage" on ZynqMP message API: you read exactly
     * ByteCount into ReadBuf.
     */
    (void)QspiPsuTransfer_TxRx(cmd, sizeof(cmd), ReadBuf, ByteCount, 1);
}

void QspiFlashWrite(u32 Address, u32 ByteCount, u8 *WriteBuf)
{
    int st;

    /* Write enable */
    st = QspiPsuWriteEnable();
    if (st != XST_SUCCESS) return;

    /*
     * PAGE PROGRAM typically needs:
     *   [CMD][ADDR_MSB][ADDR][ADDR_LSB][DATA...]
     * Your original code overwrote the first 4 bytes of WriteBuf.
     * We keep that behavior.
     */
    WriteBuf[0] = FLASH_WRITE_CMD;
    WriteBuf[1] = (u8)((Address >> 16) & 0xFF);
    WriteBuf[2] = (u8)((Address >>  8) & 0xFF);
    WriteBuf[3] = (u8)((Address >>  0) & 0xFF);

    /* Send command+addr+data, hold CS through the whole TX */
    (void)QspiPsuTransfer_TxRx(WriteBuf, ByteCount, NULL, 0, 0);

    /* Wait for program complete */
    (void)QspiPsuWaitWhileBusy();
}

void QspiFlashEraseSect(u32 sector)
{
    int st;
    u8 cmd[4];
    u32 Address = sector * FLASH_SECTOR_SIZE;

    st = QspiPsuWriteEnable();
    if (st != XST_SUCCESS) return;

    cmd[0] = FLASH_SECTOR_ERASE_CMD;
    cmd[1] = (u8)((Address >> 16) & 0xFF);
    cmd[2] = (u8)((Address >>  8) & 0xFF);
    cmd[3] = (u8)((Address >>  0) & 0xFF);

    /* Send erase command+addr */
    (void)QspiPsuTransfer_TxRx(cmd, sizeof(cmd), NULL, 0, 0);

    /* Wait for erase complete */
    (void)QspiPsuWaitWhileBusy();
}

/***************************** The rest of your file **************************/
/* QspiGatherData(), QspiPrintData(), QspiDisperseData() stay unchanged. */


void QspiGatherData(u32 chan, u8 *writebuf) {

    QspiData_t qspidata;
    u32 base;

    base = XPAR_M_AXI_BASEADDR + (chan) * CHBASEADDR;

    //DAC
    qspidata.dac_setpt_offset = (s32)Xil_In32(base + DAC_SETPT_OFFSET_REG);
    qspidata.dac_setpt_gain = (s32)Xil_In32(base + DAC_SETPT_GAIN_REG);

    // ADC's
    qspidata.dcct1_offset = (s32)Xil_In32(base + DCCT1_OFFSET_REG);
    qspidata.dcct1_gain = (s32)Xil_In32(base + DCCT1_GAIN_REG);
    qspidata.dcct2_offset = (s32)Xil_In32(base + DCCT2_OFFSET_REG);
    qspidata.dcct2_gain = (s32)Xil_In32(base + DCCT2_GAIN_REG);
    qspidata.dacmon_offset = (s32)Xil_In32(base + DACMON_OFFSET_REG);
    qspidata.dacmon_gain = (s32)Xil_In32(base + DACMON_GAIN_REG);
    qspidata.volt_offset = (s32)Xil_In32(base + VOLT_OFFSET_REG);
    qspidata.volt_gain = (s32)Xil_In32(base + VOLT_GAIN_REG);
    qspidata.gnd_offset = (s32)Xil_In32(base + GND_OFFSET_REG);
    qspidata.gnd_gain = (s32)Xil_In32(base + GND_GAIN_REG);
    qspidata.spare_offset = (s32)Xil_In32(base + SPARE_OFFSET_REG);
    qspidata.spare_gain = (s32)Xil_In32(base + SPARE_GAIN_REG);
    qspidata.reg_offset = (s32)Xil_In32(base + REG_OFFSET_REG);
    qspidata.reg_gain = (s32)Xil_In32(base + REG_GAIN_REG);
    qspidata.error_offset = (s32)Xil_In32(base + ERR_OFFSET_REG);
    qspidata.error_gain = (s32)Xil_In32(base + ERR_GAIN_REG);

    //Faults
    qspidata.ovc1_thresh = (s32)Xil_In32(base + OVC1_THRESH_REG);
    qspidata.ovc2_thresh = (s32)Xil_In32(base + OVC2_THRESH_REG);
    qspidata.ovv_thresh = Xil_In32(base + OVV_THRESH_REG);
    qspidata.err1_thresh = Xil_In32(base + ERR1_THRESH_REG);
    qspidata.err2_thresh = Xil_In32(base + ERR2_THRESH_REG);
    qspidata.ignd_thresh = Xil_In32(base + IGND_THRESH_REG);

    //Count Limits
    qspidata.ovc1_cntlim = Xil_In32(base + OVC1_CNTLIM_REG);
    qspidata.ovc2_cntlim = Xil_In32(base + OVC2_CNTLIM_REG);
    qspidata.ovv_cntlim = Xil_In32(base + OVV_CNTLIM_REG);
    qspidata.err1_cntlim = Xil_In32(base + ERR1_CNTLIM_REG);
    qspidata.err2_cntlim = Xil_In32(base + ERR2_CNTLIM_REG);
    qspidata.ignd_cntlim = Xil_In32(base + IGND_CNTLIM_REG);
    qspidata.dcct_cntlim = Xil_In32(base + DCCT_CNTLIM_REG);
    qspidata.flt1_cntlim = Xil_In32(base + FLT1_CNTLIM_REG);
    qspidata.flt2_cntlim = Xil_In32(base + FLT2_CNTLIM_REG);
    qspidata.flt3_cntlim = Xil_In32(base + FLT3_CNTLIM_REG);
    qspidata.on_cntlim = Xil_In32(base + ON_CNTLIM_REG);
    qspidata.heartbeat_cntlim = Xil_In32(base + HEARTBEAT_CNTLIM_REG);

    qspidata.fault_mask = Xil_In32(base + FAULT_MASK_REG);

    //ScaleFactors
    qspidata.sf_ampspersec = scalefactors[chan-1].ampspersec;
    qspidata.sf_dac_dccts = scalefactors[chan-1].dac_dccts;
    qspidata.sf_vout = scalefactors[chan-1].vout;
    qspidata.sf_ignd = scalefactors[chan-1].ignd;
    qspidata.sf_spare = scalefactors[chan-1].spare;
    qspidata.sf_regulator = scalefactors[chan-1].regulator;
    qspidata.sf_error = scalefactors[chan-1].error;

    xil_printf("Current QSPI Data...\r\n");
    QspiPrintData(&qspidata, chan);
    //copy the structure to the PSC msg buffer
    memcpy(writebuf,&qspidata,sizeof(qspidata));

}



void QspiPrintData(QspiData_t *data, u32 chan)
{
    xil_printf("QspiData Contents:\r\n");
    xil_printf("header            = 0x%08X\r\n", data->header);
    printf("dac_setpt_offset  = %f\r\n", data->dac_setpt_offset * CONVDACBITSTOVOLTS * scalefactors[chan-1].dac_dccts);
    printf("dac_setpt_gain    = %f\r\n", data->dac_setpt_gain  / GAIN20BITFRACT);
    printf("dcct1_offset      = %f\r\n", data->dcct1_offset * CONVDACBITSTOVOLTS * scalefactors[chan-1].dac_dccts);
    printf("dcct1_gain        = %f\r\n", data->dcct1_gain  / GAIN20BITFRACT);
    printf("dcct2_offset      = %f\r\n", data->dcct2_offset  * CONVDACBITSTOVOLTS * scalefactors[chan-1].dac_dccts);
    printf("dcct2_gain        = %f\r\n", data->dcct2_gain  / GAIN20BITFRACT);
    printf("dacmon_offset     = %f\r\n", data->dacmon_offset * CONV16BITSTOVOLTS * scalefactors[chan-1].dac_dccts);
    printf("dacmon_gain       = %f\r\n", data->dacmon_gain  / GAIN20BITFRACT);
    printf("volt_offset       = %f\r\n", data->volt_offset * CONV16BITSTOVOLTS * scalefactors[chan-1].vout);
    printf("volt_gain         = %f\r\n", data->volt_gain  / GAIN20BITFRACT);
    printf("gnd_offset        = %f\r\n", data->gnd_offset * CONV16BITSTOVOLTS * scalefactors[chan-1].ignd);
    printf("gnd_gain          = %f\r\n", data->gnd_gain  / GAIN20BITFRACT);
    printf("spare_offset      = %f\r\n", data->spare_offset * CONV16BITSTOVOLTS * scalefactors[chan-1].spare);
    printf("spare_gain        = %f\r\n", data->spare_gain  / GAIN20BITFRACT);
    printf("reg_offset        = %f\r\n", data->reg_offset * CONV16BITSTOVOLTS * scalefactors[chan-1].regulator);
    printf("reg_gain          = %f\r\n", data->reg_gain  / GAIN20BITFRACT);
    printf("error_offset      = %f\r\n", data->error_offset * CONV16BITSTOVOLTS * scalefactors[chan-1].error);
    printf("error_gain        = %f\r\n", data->error_gain / GAIN20BITFRACT);
    printf("ovc1_thresh       = %f\r\n", data->ovc1_thresh * CONVDACBITSTOVOLTS * scalefactors[chan-1].dac_dccts);
    printf("ovc2_thresh       = %f\r\n", data->ovc2_thresh * CONVDACBITSTOVOLTS * scalefactors[chan-1].dac_dccts);
    printf("ovv_thresh        = %f\r\n", data->ovv_thresh * CONV16BITSTOVOLTS * scalefactors[chan-1].vout);
    printf("err1_thresh       = %f\r\n", data->err1_thresh * CONV16BITSTOVOLTS * scalefactors[chan-1].error);
    printf("err2_thresh       = %f\r\n", data->err2_thresh * CONV16BITSTOVOLTS * scalefactors[chan-1].error);
    printf("ignd_thresh       = %f\r\n", data->ignd_thresh * CONV16BITSTOVOLTS * scalefactors[chan-1].ignd);
    printf("ovc1_cntlim       = %f\r\n", data->ovc1_cntlim / SAMPLERATE);
    printf("ovc2_cntlim       = %f\r\n", data->ovc2_cntlim / SAMPLERATE);
    printf("ovv_cntlim        = %f\r\n", data->ovv_cntlim / SAMPLERATE);
    printf("err1_cntlim       = %f\r\n", data->err1_cntlim / SAMPLERATE);
    printf("err2_cntlim       = %f\r\n", data->err2_cntlim / SAMPLERATE);
    printf("ignd_cntlim       = %f\r\n", data->ignd_cntlim / SAMPLERATE);
    printf("dcct_cntlim       = %f\r\n", data->dcct_cntlim / SAMPLERATE);
    printf("flt1_cntlim       = %f\r\n", data->flt1_cntlim / SAMPLERATE);
    printf("flt2_cntlim       = %f\r\n", data->flt2_cntlim / SAMPLERATE);
    printf("flt3_cntlim       = %f\r\n", data->flt3_cntlim / SAMPLERATE);
    printf("on_cntlim         = %f\r\n", data->on_cntlim / SAMPLERATE);
    printf("heartbeat_cntlim  = %f\r\n", data->heartbeat_cntlim / SAMPLERATE);
    xil_printf("fault_mask        = 0x%08X\r\n", data->fault_mask);

    // Now print the floats using printf
    printf("sf_ampspersec     = %.6f\r\n", data->sf_ampspersec);
    printf("sf_dac_dccts      = %.6f\r\n", data->sf_dac_dccts);
    printf("sf_vout           = %.6f\r\n", data->sf_vout);
    printf("sf_ignd           = %.6f\r\n", data->sf_ignd);
    printf("sf_spare          = %.6f\r\n", data->sf_spare);
    printf("sf_regulator      = %.6f\r\n", data->sf_regulator);
    printf("sf_error          = %.6f\r\n", data->sf_error);
}




void QspiDisperseData(u32 chan, u8 *readbuf)
{

    QspiData_t qspidata;
    u32 base;

    //copy the qspi buffer to the qspi data structure
    memcpy(&qspidata,readbuf,sizeof(qspidata));


    base = XPAR_M_AXI_BASEADDR + (chan) * CHBASEADDR;

    Xil_Out32(base + DAC_SETPT_OFFSET_REG, qspidata.dac_setpt_offset);
    Xil_Out32(base + DAC_SETPT_GAIN_REG, qspidata.dac_setpt_gain);

    Xil_Out32(base + DCCT1_OFFSET_REG, qspidata.dcct1_offset);
    Xil_Out32(base + DCCT1_GAIN_REG, qspidata.dcct1_gain);
    Xil_Out32(base + DCCT2_OFFSET_REG, qspidata.dcct2_offset);
    Xil_Out32(base + DCCT2_GAIN_REG, qspidata.dcct2_gain);
    Xil_Out32(base + DACMON_OFFSET_REG, qspidata.dacmon_offset);
    Xil_Out32(base + DACMON_GAIN_REG, qspidata.dacmon_gain);
    Xil_Out32(base + VOLT_OFFSET_REG, qspidata.volt_offset);
    Xil_Out32(base + VOLT_GAIN_REG, qspidata.volt_gain);
    Xil_Out32(base + GND_OFFSET_REG, qspidata.gnd_offset);
    Xil_Out32(base + GND_GAIN_REG, qspidata.gnd_gain);
    Xil_Out32(base + SPARE_OFFSET_REG, qspidata.spare_offset);
    Xil_Out32(base + SPARE_GAIN_REG, qspidata.spare_gain);
    Xil_Out32(base + REG_OFFSET_REG, qspidata.reg_offset);
    Xil_Out32(base + REG_GAIN_REG, qspidata.reg_gain);
    Xil_Out32(base + ERR_OFFSET_REG, qspidata.error_offset);
    Xil_Out32(base + ERR_GAIN_REG, qspidata.error_gain);

    Xil_Out32(base + OVC1_THRESH_REG, qspidata.ovc1_thresh);
    Xil_Out32(base + OVC2_THRESH_REG, qspidata.ovc2_thresh);
    Xil_Out32(base + OVV_THRESH_REG, qspidata.ovv_thresh);
    Xil_Out32(base + ERR1_THRESH_REG, qspidata.err1_thresh);
    Xil_Out32(base + ERR2_THRESH_REG, qspidata.err2_thresh);
    Xil_Out32(base + IGND_THRESH_REG, qspidata.ignd_thresh);

    Xil_Out32(base + OVC1_CNTLIM_REG, qspidata.ovc1_cntlim);
    Xil_Out32(base + OVC2_CNTLIM_REG, qspidata.ovc2_cntlim);
    Xil_Out32(base + OVV_CNTLIM_REG, qspidata.ovv_cntlim);
    Xil_Out32(base + ERR1_CNTLIM_REG, qspidata.err1_cntlim);
    Xil_Out32(base + ERR2_CNTLIM_REG, qspidata.err2_cntlim);
    Xil_Out32(base + IGND_CNTLIM_REG, qspidata.ignd_cntlim);
    Xil_Out32(base + DCCT_CNTLIM_REG, qspidata.dcct_cntlim);
    Xil_Out32(base + FLT1_CNTLIM_REG, qspidata.flt1_cntlim);
    Xil_Out32(base + FLT2_CNTLIM_REG, qspidata.flt2_cntlim);
    Xil_Out32(base + FLT3_CNTLIM_REG, qspidata.flt3_cntlim);
    Xil_Out32(base + ON_CNTLIM_REG, qspidata.on_cntlim);
    Xil_Out32(base + HEARTBEAT_CNTLIM_REG, qspidata.heartbeat_cntlim);

    Xil_Out32(base + FAULT_MASK_REG, qspidata.fault_mask);

    scalefactors[chan-1].ampspersec = qspidata.sf_ampspersec;
    scalefactors[chan-1].dac_dccts = qspidata.sf_dac_dccts;
    scalefactors[chan-1].vout = qspidata.sf_vout;
    scalefactors[chan-1].ignd = qspidata.sf_ignd;
    scalefactors[chan-1].spare = qspidata.sf_spare;
    scalefactors[chan-1].regulator = qspidata.sf_regulator;
    scalefactors[chan-1].error = qspidata.sf_error;

    //QspiPrintData(&qspidata, chan);


    //Xil_Out32(base + FAULT_CLEAR_REG, 0x1);
    //usleep(1000);
    //Xil_Out32(base + FAULT_CLEAR_REG, 0);


}





