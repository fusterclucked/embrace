#include <assert.h>
#include <iso646.h>
#include <stdarg.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>

typedef unsigned char YYCTYPE;

#define SIZE 4096
YYCTYPE YYBUFFER[SIZE];

YYCTYPE* YYCURSOR = YYBUFFER;
YYCTYPE* YYLIMIT = YYBUFFER;
YYCTYPE* YYCTXMARKER;

typedef struct Token Token;
struct Token
	YYCTYPE* text;
	char type;
;

#include "offside.h"

FILE* file;
size_t lineno = 1;

void YYFILL (size_t needed)
	assert (needed <= SIZE);

	size_t read = fread (YYBUFFER, 1, SIZE, file);

	if ( read <= 0 )
		*YYCURSOR = '\0';
	else
		YYLIMIT = YYBUFFER + read;
		YYCURSOR = YYBUFFER;

///*!re2c

re2c:indent:top = 1;

ANY = [\x00-\xFF];

*/

#define ACCEPT(t) this->type = (t); return true

bool read (Token* this)
	this->text = YYCURSOR;

	///*!re2c

	'\x00' { return false; }

	'\n' '\t'* / . { lineno++; ACCEPT ('\n'); }

	'\n' '\t'* { lineno++; ACCEPT (' '); }

	' '* { ACCEPT (' '); }

	'#' .* { ACCEPT (' '); }

	'/*' { goto comment_multi; }

	'//' .* { ACCEPT (' '); }

	[0-9]+ { ACCEPT (' '); }

	'"' { goto quote_double; }

	'\'' { goto quote_single; }

	[A-Z_a-z]+ { ACCEPT ('a'); }

	',' { ACCEPT (','); }

	':' { ACCEPT (':'); }

	';' { ACCEPT (';'); }

	'=' { ACCEPT ('='); }

	'{' { ACCEPT ('{'); }

	'}' { ACCEPT ('}'); }

	[!%&()*+\-./<>?\[\\\]^|~] { ACCEPT ('+'); }

	ANY
		fprintf (stderr, "xcc: error: line %i: invalid char '%c'\n", lineno, *(this->text));
		return false;

	*/

	comment_multi:

	do
		///*!re2c

		'*\/' { ACCEPT (' '); }

		ANY { continue; }

		*/
	while ( true );

	quote_double:

	do
		///*!re2c

		'"' { ACCEPT ('"'); }

		ANY { continue; }

		*/
	while ( true );

	quote_single:

	do
		///*!re2c

		'\'' { ACCEPT ('\''); }

		'\\' . { continue; }

		ANY { continue; }

		*/
	while ( true );

int main (int argc, char* argv [])
	if ( argc != 2 )
		fprintf (stderr, "usage: xcc <path>\n");
		return EXIT_FAILURE;

	const char* path = argv[1];
	file = fopen (path, "r");

	if ( file == NULL )
		fprintf (stderr, "xcc: error: invalid file '%s'\n", path);
		return EXIT_FAILURE;

	Token token;
	Offside offside;

	offside_open (&offside);

	while ( read (&token) )
		if ( token.type != ' ' )
			offside_write (&offside, &token);
		fprintf (stdout, "%.*s", YYCURSOR - token.text, token.text);

	offside_write_end (&offside);

	return EXIT_SUCCESS;
