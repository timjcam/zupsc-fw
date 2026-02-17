#include "xparameters.h"
#include "xiicps.h"
#include <sleep.h>
#include "xil_printf.h"
#include <stdio.h>
#include "FreeRTOS.h"
#include "task.h"

#include "pl_regs.h"
#include "local.h"
#include "zupsc.h"
#include "at24eeprom.h"





extern ScaleFactorType scalefactors[4];
extern float CONVDACBITSTOVOLTS;

/**
 * @brief Write 1 byte to AT24CM02
 */
int EepromWriteByte(u16 addr, u8 data)
{
    u8 buf[3];

	i2c_set_port_expander(I2C_PORTEXP0_ADDR,0x80);
	i2c_set_port_expander(I2C_PORTEXP1_ADDR,0x0);

    buf[0] = (u8)(addr >> 8);      // mem addr high
    buf[1] = (u8)(addr & 0xFF);    // mem addr low
    buf[2] = data;                 // data byte

    i2c_write(buf,3,EEPROM_ADDR);
    //int sent = XIicPs_MasterSendPolled(&Iic, buf, 3, EEPROM_ADDR_7B);
    //if (sent != 3) return XST_FAILURE;

    //while (XIicPs_BusIsBusy(&Iic)) { }  // ok for now

    usleep(10000);              // wait for internal write
    return;
}

/**
 * @brief Read 1 byte from AT24CM02
 */
uint8_t EepromReadByte(uint32_t addr) {
    uint8_t addr_buf[2];
    uint8_t data = 0;

	i2c_set_port_expander(I2C_PORTEXP0_ADDR,0x80);
	i2c_set_port_expander(I2C_PORTEXP1_ADDR,0x0);

    addr_buf[0] = (uint8_t)(addr >> 8);
    addr_buf[1] = (uint8_t)(addr & 0xFF);


    // 1. Send the 3-byte address pointer
    i2c_write(addr_buf,2,EEPROM_ADDR);
    //XIicPs_MasterSendPolled(&I2cInstance, addr_buf, 3, EEPROM_ADDR);

    // 2. Receive the data byte
    i2c_read(&data,1,EEPROM_ADDR);
    //XIicPs_MasterRecvPolled(&I2cInstance, &data, 1, EEPROM_ADDR);

    return data;
}



/* Writes exactly 256 bytes. mem_addr must be 0x..00 (page aligned). */
int EepromWrite256(u16 mem_addr, const u8 *src)
{
    u8 buf[2 + EEPROM_PAGE_SIZE];

	i2c_set_port_expander(I2C_PORTEXP0_ADDR,0x80);
	i2c_set_port_expander(I2C_PORTEXP1_ADDR,0x0);

    if (src == NULL) return XST_INVALID_PARAM;

    /* Must not cross page boundary */
    if ((mem_addr & (EEPROM_PAGE_SIZE - 1)) != 0) {
        return XST_INVALID_PARAM;   // not aligned
    }

    buf[0] = (u8)(mem_addr >> 8);
    buf[1] = (u8)(mem_addr & 0xFF);

    memcpy(&buf[2], src, EEPROM_PAGE_SIZE);

    /* Send 2-byte address + 256 bytes data */
    s32 st = i2c_write(buf, 2 + EEPROM_PAGE_SIZE, EEPROM_ADDR);
    if (st != XST_SUCCESS) return XST_FAILURE;

    /* wait internal write cycle */
    usleep(10000);

    return XST_SUCCESS;
}



int EepromRead256(u16 mem_addr, u8 *dst)
{
    u8 a[2];

	i2c_set_port_expander(I2C_PORTEXP0_ADDR,0x80);
	i2c_set_port_expander(I2C_PORTEXP1_ADDR,0x0);

    if (dst == NULL) return XST_INVALID_PARAM;

    a[0] = (u8)(mem_addr >> 8);
    a[1] = (u8)(mem_addr & 0xFF);

    if (i2c_write(a, 2, EEPROM_ADDR) != XST_SUCCESS) return XST_FAILURE;
    if (i2c_read(dst, EEPROM_PAGE_SIZE, EEPROM_ADDR) != XST_SUCCESS) return XST_FAILURE;

    return XST_SUCCESS;
}

void InitSettingsfromEeprom()
{
   u32 chan;
   u8 qspibuf[EEPROM_PAGE_SIZE];

   xil_printf("Reading AT24CM02 EEPROM...\r\n");
   for (chan=1; chan<=4; chan++) {
      EepromRead256(chan*256, qspibuf);
      xil_printf("DisperseData...\r\n");
      QspiDisperseData(chan,qspibuf);
   }
}


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






