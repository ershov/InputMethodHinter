#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <fcntl.h>
#include <libgen.h>

void daemonize() {
  pid_t pid;

  if ((pid = fork()) < 0) exit(EXIT_FAILURE);
  else if (pid > 0) exit(EXIT_SUCCESS);

  if (setsid() < 0) exit(EXIT_FAILURE);

  if ((pid = fork()) < 0) exit(EXIT_FAILURE);
  else if (pid > 0) exit(EXIT_SUCCESS);

  close(STDIN_FILENO);
  close(STDOUT_FILENO);
  close(STDERR_FILENO);

  if (chdir("/") < 0) exit(EXIT_FAILURE);

  umask(0);
}

char *get_exec_path(char *argv0, char *file_name) {
  char *dir_name = dirname(argv0);
  size_t dir_len = strlen(dir_name);
  size_t file_len = strlen(file_name);
  char *rel_path = malloc(dir_len + file_len + 2);
  if (rel_path == NULL) exit(EXIT_FAILURE);
  strcpy(rel_path, dir_name);
  rel_path[dir_len] = '/';
  strcpy(rel_path + dir_len + 1, file_name);
  char *abs_path = realpath(rel_path, NULL);
  free(rel_path);
  return abs_path;
}

int is_binary_running(const char *fullpath) {
  char command[500];
  if (snprintf(command, 500, "pgrep -q -u `id -u` -f %s", fullpath) >= 500) return 0;
  int result = system(command);
  return result == 0;
}

int main(int argc, char **argv) {
  char *args[] = {get_exec_path(argv[0], "InputMethodHinter-console"), NULL};
  if (is_binary_running(args[0])) exit(EXIT_SUCCESS);
  daemonize();
  execvp(args[0], args);
  return 0;
}
