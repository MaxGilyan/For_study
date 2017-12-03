#include <stdio.h>
#include <stdlib.h>

int main (int argc, char **argv)
{
	char *mas = (char *) calloc(10, sizeof(char));
	int stack=0;
	char c;
	while ((c=getchar())!='\n')
	{
		if (stack>=10 && stack%10==0)
		{
			if (!(mas = (char *) realloc(mas, stack+10)))
			{
				printf ("Can't use realloc \n");
				exit(1);
			}
		}
		if (c=='{' || c=='[' || c=='(')
		{
			*(mas+(stack++))=c;
		}
		if ((c=='}' || c==']' || c==')') && stack==0)
		{
			stack=-1;
			break;
		}
		if (c=='}' && *(mas+(stack-1))=='{')
		{
			stack--;
		}
		if (c==']' && *(mas+(stack-1))=='[')
		{
			stack--;
		}
		if (c==')' && *(mas+(stack-1))=='(')
		{
			stack--;
		}
	}
	if (stack==0)
	{
		printf ("Sucsess \n");
	} else {
		printf ("Bad scopes \n");
	}

	free(mas);
	return 0;
}