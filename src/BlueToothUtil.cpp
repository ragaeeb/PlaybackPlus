#include "BlueToothUtil.h"

#include <btapi/btdevice.h>

namespace {

void bt_device_callback(const int event, const char *bt_addr, const char *event_data)
{
}

}

namespace canadainc {

void BlueToothUtil::activate(bool turnOn)
{
	bt_device_init(bt_device_callback);
	bt_ldev_set_power(turnOn);
	bt_device_deinit();
}


} /* namespace canadainc */
