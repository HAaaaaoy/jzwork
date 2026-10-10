#include <fcntl.h>
#include <unistd.h>
#include <termios.h>
#include <stdio.h>

int main()
{
		int serial_fd = open("/dev/ttyS1", O_RDWR|O_NOCTTY);
		if (serial_fd == -1)
		{
			perror("Failed to open /dev/ttyS1");
			return -1;
		}
		
		struct termios serial_options;
		if (tcgetattr(serial_fd, &serial_options) == -1)
		{
			perror("tcgetattr failed");
			close(serial_fd);
			return -1;
		}
		
		
		//modify baud_rate 9600
		
		cfsetispeed(&serial_options, B9600);
		cfsetispeed(&serial_options, B9600);
		
		//8N1 config no jiaoyan 1 number stop flag
		serial_options.c_cflag &= ~PARENB;
		serial_options.c_cflag &= ~CSTOPB;
		serial_options.c_cflag &= ~CSIZE;
		serial_options.c_cflag |= CS8;
		serial_options.c_cflag &= ~CRTSCTS;
		serial_options.c_lflag &= ~(ICANON | ECHO | ECHOE | ISIG);
		serial_options.c_iflag &= ~(IXON | IXOFF | IXANY);
		
		//application config
		if (tcsetattr(serial_fd, TCSANOW, &serial_options) == -1)
		{
			perror("tcsetattr failed");
			close(serial_fd);
			return -1;
		}
		printf("[INFO] baud_rate has modify 9600");
		close(serial_fd);
		return 0;
}