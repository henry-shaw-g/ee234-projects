
/*******************************************************************
*
* CAUTION: This file is automatically generated by HSI.
* Version: 2023.2
* DO NOT EDIT.
*
* Copyright (C) 2010-2024 Xilinx, Inc. All Rights Reserved.
* SPDX-License-Identifier: MIT 

* 
* Description: Driver configuration
*
*******************************************************************/

#include "xparameters.h"
#include "xgpio.h"

/*
* The configuration table for devices
*/

XGpio_Config XGpio_ConfigTable[XPAR_XGPIO_NUM_INSTANCES] =
{
	{
		XPAR_GPIO_BTN_DEVICE_ID,
		XPAR_GPIO_BTN_BASEADDR,
		XPAR_GPIO_BTN_INTERRUPT_PRESENT,
		XPAR_GPIO_BTN_IS_DUAL
	},
	{
		XPAR_GPIO_HDMI_DEVICE_ID,
		XPAR_GPIO_HDMI_BASEADDR,
		XPAR_GPIO_HDMI_INTERRUPT_PRESENT,
		XPAR_GPIO_HDMI_IS_DUAL
	},
	{
		XPAR_GPIO_LED_DEVICE_ID,
		XPAR_GPIO_LED_BASEADDR,
		XPAR_GPIO_LED_INTERRUPT_PRESENT,
		XPAR_GPIO_LED_IS_DUAL
	},
	{
		XPAR_GPIO_SW_DEVICE_ID,
		XPAR_GPIO_SW_BASEADDR,
		XPAR_GPIO_SW_INTERRUPT_PRESENT,
		XPAR_GPIO_SW_IS_DUAL
	}
};

