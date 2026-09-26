#pragma once

// Load libudev at runtime to support both libudev.so.0 and libudev.so.1.
#include <dlfcn.h>

// Declare udev structures needed in this module. They are passed by pointers
// to udev functions and not used directly.
struct udev_device;
struct udev_list_entry;
struct udev_enumerate;
struct udev;

typedef const char* 			(*hid_wrapper_udev_device_get_devnode_type)(struct udev_device *udev_device);
typedef const char* 			(*hid_wrapper_udev_device_get_syspath_type)(struct udev_device *udev_device);
typedef struct udev_device* 	(*hid_wrapper_udev_device_get_parent_with_subsystem_devtype_type)(struct udev_device *udev_device, const char *subsystem, const char *devtype);
typedef const char*				(*hid_wrapper_udev_device_get_sysattr_value_type)(struct udev_device *udev_device, const char *sysattr);
typedef struct udev_device*		(*hid_wrapper_udev_device_new_from_devnum_type)(struct udev *udev, char type, dev_t devnum);
typedef struct udev_device* 	(*hid_wrapper_udev_device_new_from_syspath_type)(struct udev *udev, const char *syspath);
typedef struct udev_device* 	(*hid_wrapper_udev_device_unref_type)(struct udev_device *udev_device);
typedef int 					(*hid_wrapper_udev_enumerate_add_match_subsystem_type)(struct udev_enumerate *udev_enumerate, const char *subsystem);
typedef struct udev_list_entry* (*hid_wrapper_udev_enumerate_get_list_entry_type)(struct udev_enumerate *udev_enumerate);
typedef struct udev_enumerate*  (*hid_wrapper_udev_enumerate_new_type)(struct udev *udev);
typedef int 					(*hid_wrapper_udev_enumerate_scan_devices_type)(struct udev_enumerate *udev_enumerate);
typedef struct udev_enumerate* 	(*hid_wrapper_udev_enumerate_unref_type)(struct udev_enumerate *udev_enumerate);
typedef const char*				(*hid_wrapper_udev_list_entry_get_name_type)(struct udev_list_entry *list_entry);
typedef struct udev_list_entry* (*hid_wrapper_udev_list_entry_get_next_type)(struct udev_list_entry *list_entry);
typedef struct udev*			(*hid_wrapper_udev_new_type)(void);
typedef struct udev*			(*hid_wrapper_udev_unref_type)(struct udev *udev);

static void  																   *hid_wrapper_handle 											= NULL;
static hid_wrapper_udev_device_get_devnode_type 						hid_wrapper_udev_device_get_devnode 						= NULL;
static hid_wrapper_udev_device_get_syspath_type 						hid_wrapper_udev_device_get_syspath 						= NULL;
static hid_wrapper_udev_device_get_parent_with_subsystem_devtype_type 	hid_wrapper_udev_device_get_parent_with_subsystem_devtype 	= NULL;
static hid_wrapper_udev_device_get_sysattr_value_type					hid_wrapper_udev_device_get_sysattr_value 					= NULL;
static hid_wrapper_udev_device_new_from_devnum_type 					hid_wrapper_udev_device_new_from_devnum 					= NULL;
static hid_wrapper_udev_device_new_from_syspath_type					hid_wrapper_udev_device_new_from_syspath 					= NULL;
static hid_wrapper_udev_device_unref_type 								hid_wrapper_udev_device_unref 								= NULL;
static hid_wrapper_udev_enumerate_add_match_subsystem_type 				hid_wrapper_udev_enumerate_add_match_subsystem 				= NULL;
static hid_wrapper_udev_enumerate_get_list_entry_type 					hid_wrapper_udev_enumerate_get_list_entry 					= NULL;
static hid_wrapper_udev_enumerate_new_type 								hid_wrapper_udev_enumerate_new 								= NULL;
static hid_wrapper_udev_enumerate_scan_devices_type 					hid_wrapper_udev_enumerate_scan_devices 					= NULL;
static hid_wrapper_udev_enumerate_unref_type 							hid_wrapper_udev_enumerate_unref 							= NULL;
static hid_wrapper_udev_list_entry_get_name_type 						hid_wrapper_udev_list_entry_get_name 						= NULL;
static hid_wrapper_udev_list_entry_get_next_type 						hid_wrapper_udev_list_entry_get_next 						= NULL;
static hid_wrapper_udev_new_type 										hid_wrapper_udev_new 										= NULL;
static hid_wrapper_udev_unref_type 										hid_wrapper_udev_unref 										= NULL;

static void hid_wrapper_udev_close()
{
	if (hid_wrapper_handle)
		dlclose(hid_wrapper_handle);
	hid_wrapper_handle 											= NULL;
	hid_wrapper_udev_device_get_devnode 						= NULL;
	hid_wrapper_udev_device_get_syspath 						= NULL;
	hid_wrapper_udev_device_get_parent_with_subsystem_devtype 	= NULL;
	hid_wrapper_udev_device_get_sysattr_value 					= NULL;
	hid_wrapper_udev_device_new_from_devnum 					= NULL;
	hid_wrapper_udev_device_new_from_syspath 					= NULL;
	hid_wrapper_udev_device_unref 								= NULL;
	hid_wrapper_udev_enumerate_add_match_subsystem 				= NULL;
	hid_wrapper_udev_enumerate_get_list_entry 					= NULL;
	hid_wrapper_udev_enumerate_new 								= NULL;
	hid_wrapper_udev_enumerate_scan_devices 					= NULL;
	hid_wrapper_udev_enumerate_unref 							= NULL;
	hid_wrapper_udev_list_entry_get_name 						= NULL;
	hid_wrapper_udev_list_entry_get_next 						= NULL;
	hid_wrapper_udev_new 										= NULL;
	hid_wrapper_udev_unref 										= NULL;
}

static const char *hid_wrapper_libudev_paths[] = {
    "libudev.so.1", "libudev.so.0"
};

static int hid_wrapper_udev_init()
{
	int i;

	if (hid_wrapper_handle != NULL)
		return 0;

	// Search for the libudev0 or libudev1 library.
	for (i = 0; i < sizeof(hid_wrapper_libudev_paths) / sizeof(hid_wrapper_libudev_paths[0]); ++ i)
	  	if ((hid_wrapper_handle = dlopen(hid_wrapper_libudev_paths[i], RTLD_NOW | RTLD_GLOBAL)) != NULL)
	  		break;

	if (hid_wrapper_handle == NULL) {
		// Error, close the shared library handle and finish.
		hid_wrapper_udev_close();
		return -1;
	}

	// Resolve the functions.
	hid_wrapper_udev_device_get_devnode 						= (hid_wrapper_udev_device_get_devnode_type)						dlsym(hid_wrapper_handle, "udev_device_get_devnode");
	hid_wrapper_udev_device_get_syspath 						= (hid_wrapper_udev_device_get_syspath_type)						dlsym(hid_wrapper_handle, "udev_device_get_syspath");
	hid_wrapper_udev_device_get_parent_with_subsystem_devtype 	= (hid_wrapper_udev_device_get_parent_with_subsystem_devtype_type)	dlsym(hid_wrapper_handle, "udev_device_get_parent_with_subsystem_devtype");
	hid_wrapper_udev_device_get_sysattr_value 					= (hid_wrapper_udev_device_get_sysattr_value_type)					dlsym(hid_wrapper_handle, "udev_device_get_sysattr_value");
	hid_wrapper_udev_device_new_from_devnum 					= (hid_wrapper_udev_device_new_from_devnum_type)					dlsym(hid_wrapper_handle, "udev_device_new_from_devnum");
	hid_wrapper_udev_device_new_from_syspath 					= (hid_wrapper_udev_device_new_from_syspath_type)					dlsym(hid_wrapper_handle, "udev_device_new_from_syspath");
	hid_wrapper_udev_device_unref 								= (hid_wrapper_udev_device_unref_type)								dlsym(hid_wrapper_handle, "udev_device_unref");
	hid_wrapper_udev_enumerate_add_match_subsystem 				= (hid_wrapper_udev_enumerate_add_match_subsystem_type)				dlsym(hid_wrapper_handle, "udev_enumerate_add_match_subsystem");
	hid_wrapper_udev_enumerate_get_list_entry 					= (hid_wrapper_udev_enumerate_get_list_entry_type)					dlsym(hid_wrapper_handle, "udev_enumerate_get_list_entry");
	hid_wrapper_udev_enumerate_new    	 	 					= (hid_wrapper_udev_enumerate_new_type)								dlsym(hid_wrapper_handle, "udev_enumerate_new");
	hid_wrapper_udev_enumerate_scan_devices	 					= (hid_wrapper_udev_enumerate_scan_devices_type)					dlsym(hid_wrapper_handle, "udev_enumerate_scan_devices");
	hid_wrapper_udev_enumerate_unref	 						= (hid_wrapper_udev_enumerate_unref_type)							dlsym(hid_wrapper_handle, "udev_enumerate_unref");
	hid_wrapper_udev_list_entry_get_name 						= (hid_wrapper_udev_list_entry_get_name_type)						dlsym(hid_wrapper_handle, "udev_list_entry_get_name");
	hid_wrapper_udev_list_entry_get_next 						= (hid_wrapper_udev_list_entry_get_next_type)						dlsym(hid_wrapper_handle, "udev_list_entry_get_next");
	hid_wrapper_udev_new 										= (hid_wrapper_udev_new_type)										dlsym(hid_wrapper_handle, "udev_new");
	hid_wrapper_udev_unref 										= (hid_wrapper_udev_unref_type)										dlsym(hid_wrapper_handle, "udev_unref");

	// Were all the funcions resolved?
	if (hid_wrapper_handle 											== NULL ||
		hid_wrapper_udev_device_get_devnode 						== NULL ||
		hid_wrapper_udev_device_get_syspath 						== NULL ||
		hid_wrapper_udev_device_get_parent_with_subsystem_devtype 	== NULL ||
		hid_wrapper_udev_device_get_sysattr_value 					== NULL ||
		hid_wrapper_udev_device_new_from_devnum 					== NULL ||
		hid_wrapper_udev_device_new_from_syspath 					== NULL ||
		hid_wrapper_udev_device_unref 								== NULL ||
		hid_wrapper_udev_enumerate_add_match_subsystem 				== NULL ||
		hid_wrapper_udev_enumerate_get_list_entry 					== NULL ||
		hid_wrapper_udev_enumerate_new 								== NULL ||
		hid_wrapper_udev_enumerate_scan_devices 					== NULL ||
		hid_wrapper_udev_enumerate_unref 							== NULL ||
		hid_wrapper_udev_list_entry_get_name 						== NULL ||
		hid_wrapper_udev_list_entry_get_next 						== NULL ||
		hid_wrapper_udev_new 										== NULL ||
		hid_wrapper_udev_unref 										== NULL)
	{
		// Error, close the shared library handle and finish.
		hid_wrapper_udev_close();
		return -2;
	}

	// Success.
	return 0;
}

#define udev_device_get_devnode hid_wrapper_udev_device_get_devnode
#define udev_device_get_parent_with_subsystem_devtype hid_wrapper_udev_device_get_parent_with_subsystem_devtype
#define udev_device_get_sysattr_value hid_wrapper_udev_device_get_sysattr_value
#define udev_device_get_syspath hid_wrapper_udev_device_get_syspath
#define udev_device_new_from_devnum hid_wrapper_udev_device_new_from_devnum
#define udev_device_new_from_syspath hid_wrapper_udev_device_new_from_syspath
#define udev_device_unref hid_wrapper_udev_device_unref
#define udev_enumerate_add_match_subsystem hid_wrapper_udev_enumerate_add_match_subsystem
#define udev_enumerate_get_list_entry hid_wrapper_udev_enumerate_get_list_entry
#define udev_enumerate_new hid_wrapper_udev_enumerate_new
#define udev_enumerate_scan_devices hid_wrapper_udev_enumerate_scan_devices
#define udev_enumerate_unref hid_wrapper_udev_enumerate_unref
#define udev_list_entry_get_name hid_wrapper_udev_list_entry_get_name
#define udev_list_entry_get_next hid_wrapper_udev_list_entry_get_next
#define udev_new hid_wrapper_udev_new
#define udev_unref hid_wrapper_udev_unref
#define udev_list_entry_foreach(entry, first) \
    for (entry = first; entry != NULL; entry = udev_list_entry_get_next(entry))
