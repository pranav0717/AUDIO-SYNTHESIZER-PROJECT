/* Copyright (C) 2011 Circuits At Home, LTD. All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

Contact information
-------------------

Circuits At Home, LTD
Web      :  http://www.circuitsathome.com
e-mail   :  support@circuitsathome.com
 */
/* USB functions */
#ifndef _usb_h_
#define _usb_h_

// WARNING: Do not change the order of includes, or stuff will break!
#include <inttypes.h>
#include <stddef.h>
#include <stdio.h>

// None of these should ever be included by a driver, or a user's sketch.
#include "../include/address.h"
//#include "../include/avrpins.h"
#include "../include/max3421e.h"
#include "../include/message.h"
#include "../include/parsetools.h"
#include "../include/printhex.h"
#include "../include/Port.h"
#include "../include/settings.h"
#include "../include/sink_parser.h"
#include "../include/SPI.h"
#include "../include/usb_ch9.h"
#include "../include/usbhost.h"
#include "../include/UsbCore.h"
#include "../include/confdescparser.h"
#include "../include/hexdump.h"

#endif //_usb_h_
