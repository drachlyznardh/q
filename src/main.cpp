
#include <cstdlib>
#include <cstdio>

int main (int argc, char **argv)
{
	std::printf("Q v%s started\n", VERSION_NUMBER);

	std::printf("Running from %s,", argv[0]);
	if (argc < 2) std::printf(" no args\n");
	else
	{
		for (int i = 1; i < argc; i++) std::printf(", %s", argv[i]);
		std::printf("\n");
	}

	std::printf("Q v%s stopped\n", VERSION_NUMBER);
	return EXIT_SUCCESS;
}

