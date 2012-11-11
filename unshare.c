#include <syscall.h>
#include <stdio.h>
#include <sched.h>
#include <sys/un.h>
#include <sys/wait.h>
#include <sys/types.h>

int jail_process(void* args)
{
	char** cmdline = args;
	execvp(cmdline[0], &cmdline[0]);
}

int main(int argc, char *argv[])
{
	char** cmdline = &argv[1];
	char* args = NULL;
	if (cmdline[0] && cmdline[0][0] == '-' && argc)
	{
		args = argv[1];
		cmdline = &argv[2];
		argc--;
	}

	if (args && strstr(args, "h"))
	{
		printf("Usage: %s [-options] command [args]\n\n", argv[0]);
		printf("Options:\n");
		printf(" -m, --mount       unshare mounts namespace\n");
		printf(" -u, --uts         unshare UTS namespace (hostname etc)\n");
		printf(" -i, --ipc         unshare System V IPC namespace\n");
		printf(" -n, --net         unshare network namespace\n\n");
		printf(" -h, --help     display this help and exit\n");
		printf(" -V, --version  output version information and exit\n");
		printf(" note: when -i is used PID isolation is also performed\n");
		return 0;
	}

	if (argc < 2 || strlen(cmdline[0]) == 0)
	{
		printf("Usage: %s [-options] command [args]\n", argv[0]);
		return 1;
	}

	if (args && strstr(args, "V"))
	{
		printf("unshare with PID \n", argv[0]);
		return 0;
	}
	int cloneflags=0;

	if (args && strstr(args, "m"))
	{
		unshare(CLONE_NEWNS);
	}
	if (args && strstr(args, "n"))
	{
		unshare(CLONE_NEWNET);
	}
	if (args && strstr(args, "u"))
	{
		unshare(CLONE_NEWUTS);
	}
	if (args && strstr(args, "i"))
	{
		unshare(CLONE_NEWIPC);
		cloneflags |= CLONE_NEWPID;
	}

	char stack[10240];
	pid_t pid = clone(jail_process, &stack, cloneflags, cmdline);
	if (pid == -1)
	{
		perror("Error launching jail");
		return 1;
	}
	int ret = 0;
	while(wait(&ret) != pid);
	return WEXITSTATUS(ret);
}
