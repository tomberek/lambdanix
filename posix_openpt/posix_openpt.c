#define _GNU_SOURCE
#include <fcntl.h>
#include <stdlib.h>
#include <stdio.h>
#include <termios.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <string.h>

int tcsetattr(int fd, int optional_actions,
                      const struct termios *termios_p)
{
    return 0;
}
int tcgetattr(int fd, struct termios *termios_p)
{
    return 0;
}

int unlockpt(int fd)
{
    return 0;
}
int grantpt(int fd)
{
    return 0;
}

int ind=0;
char a[1024][16];
char buf[16];
char *ptsname(int fd)
{
    return a[fd];
}

int posix_openpt(int flags)
{
    int r;
    sprintf(buf,"/dev/pts/%d",ind++);
    mode_t mode = S_IRUSR | S_IWUSR | S_IWGRP | S_IRGRP | S_IROTH | S_IWOTH;
    fprintf(stderr,"new pty: %s\n",buf);
    r = open(buf, O_RDWR | O_CREAT ,mode);
    strcpy(a[r],buf);
    return r;
}
