#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <getopt.h>
#include <urjtag.h>

int program_jtag(const char *svf_file, const char *drivername, const char *bsdl_path, long frequency);

#ifdef _EXECUTABLE_
int main(int argc, char **argv)
{
    int opt;
    long frequency = 0;
    char *svf, *driver, *bsdl_path;
    svf = driver = NULL;
    if (argc < 1)
        return ENOENT;
    while ((opt = getopt(argc, argv, "i:b:f:d:v")) != -1) {
        switch (opt) {
        case 'i':
            svf = optarg;
            break;
        case 'f':
            frequency = atol(optarg);
            break;
        case 'd':
            driver = optarg;
            break;
        case 'b':
            bsdl_path = optarg;
            break;
        default: /* '?' */
            fprintf(stderr, "Usage: %s [-f svf] [-d driver] [-b bsdl_path]\n",
            argv[0]);
            return EINVAL;
        }
    }
    if(svf != NULL && driver != NULL)
        return program_jtag(svf, driver, bsdl_path, frequency);
    return 0;
}
#endif

int program_jtag(const char *svf_file, const char *drivername, const char *bsdl_path, long frequency)
{
    int ret = 1;
    urj_chain_t *chain;
    urj_part_t *part;
    const urj_cable_driver_t *driver;
    chain = urj_tap_chain_alloc ();
    if(bsdl_path != NULL)
        urj_bsdl_set_path (chain, bsdl_path);
    driver = urj_tap_cable_find (drivername);
    urj_cable_t *cable = urj_tap_cable_usb_connect (chain, driver, NULL);
    urj_tap_cable_set_frequency (cable, frequency);
    int err = urj_tap_detect(chain, 0);
    chain->active_part = 0;
    FILE *svf = fopen(svf_file, "r");
    if(svf != NULL) {
        while(err == URJ_STATUS_OK) {
            part = urj_tap_chain_active_part (chain);
            err = (part == NULL);
            if(err == URJ_STATUS_OK) {
                err = urj_svf_run (chain, svf, 0, frequency);
                if(err == URJ_STATUS_OK)
                    ret = 0;
            }
            chain->active_part++;
        }
        fclose (svf);
    }
    urj_tap_chain_free(chain);
    return ret;
}
