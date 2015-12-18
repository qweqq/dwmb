#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <syslog.h>
#include <sys/wait.h>
#include <signal.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include "rfid.h"
#include "bcm2835.h"


uint8_t HW_init(uint32_t spi_speed) {
	uint16_t sp;

	sp=(uint16_t)(250000L/spi_speed);
	if (!bcm2835_init()) {
		printf("error initializing\n");
		return 0;
	}

	bcm2835_spi_begin();
	bcm2835_spi_setBitOrder(BCM2835_SPI_BIT_ORDER_MSBFIRST);
	bcm2835_spi_setDataMode(BCM2835_SPI_MODE0);
	bcm2835_spi_setClockDivider(sp);
	bcm2835_spi_chipSelect(BCM2835_SPI_CS0);
	bcm2835_spi_setChipSelectPolarity(BCM2835_SPI_CS0, LOW);
	return 1;
}

int main(int argc, char *argv[]) {
	uint8_t SN[10];
	uint16_t CType=0;
	uint8_t SN_len=0;
	char status;
	char message[100];
	int fd;
	char* pipe_name;

	uint32_t spi_speed=5000L;

	if (argc < 2) {
		fd = 1;
	} else {
		pipe_name = argv[1];
		umask(0);
		mkfifo(pipe_name, 0644);
		if ((fd = open(pipe_name, O_WRONLY)) < 0) {
			perror("can't open pipe");
			return 1;
		}
	}


	if (!HW_init(spi_speed)) {
		sprintf(message, "can't open SPI\n");
		write(1, message, strlen(message));
		return 1;
	}

	InitRc522();

	for (;;) {
		status = find_tag(&CType);
		if (status==TAG_NOTAG) {
			usleep(200000);
		} else if (status == TAG_OK || status == TAG_COLLISION) {
			if (select_tag_sn(SN,&SN_len) == TAG_OK) {
				sprintf(message, "tag %04x ", CType);
				for (int i = 0; i < SN_len; i++) {
					sprintf(message + strlen(message), "%02x", SN[i]);
				}
				sprintf(message + strlen(message), "\n");

				PcdHalt();
			} else {
				sprintf(message, "error\n");
			}
			write(fd, message, strlen(message));
		}
	}

	bcm2835_spi_end();
	bcm2835_close();

	close(fd);
	return 0;

}
