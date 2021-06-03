#include <stdio.h>
#include <errno.h>
#include <getopt.h>
#include <urjtag.h>

int program_jtag(const char *svf_file, const char *drivername);

int main(int argc, char **argv)
{
	int opt;
	char *svf, *driver;
	svf = driver = NULL;
	if (argc < 1)
		return ENOENT;
	while ((opt = getopt(argc, argv, "f:d:v")) != -1) {
		switch (opt) {
               case 'f':
                   svf = optarg;
                   break;
               case 'd':
                   driver = optarg;
                   break;
               default: /* '?' */
                   fprintf(stderr, "Usage: %s [-f svf] [-d driver]\n",
                           argv[0]);
                   return EINVAL;
               }
	}
	if(svf != NULL && driver != NULL)
		return program_jtag(svf, driver);
	return 0;
}

int program_jtag(const char *svf_file, const char *drivername)
{
	int ret = 1;
    urj_chain_t *chain;
    const urj_cable_driver_t *driver;
	chain = urj_tap_chain_alloc ();
	driver = urj_tap_cable_find (drivername);
    urj_tap_cable_usb_connect (chain, driver, NULL);
	int ndevs = urj_tap_detect(chain, 8);
    if(ndevs == URJ_STATUS_OK) {
		FILE *svf = fopen(svf_file, "r");
		if(svf != NULL) {
			urj_svf_run (chain, svf, 0, 0);
			if(URJ_STATUS_OK)
				ret = 0;
			fclose (svf);
		}
	}
	urj_tap_chain_free(chain);
	return ret;
}
